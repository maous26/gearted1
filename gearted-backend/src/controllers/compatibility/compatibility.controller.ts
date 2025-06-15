import { Request, Response } from 'express';
import { pgPool } from '../../config/postgres';
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { Readable } from 'stream';
import { logger } from '../../utils/logger';

// Initialize S3 client
const s3Client = new S3Client({
  region: process.env.AWS_REGION
});

/**
 * Get compatibility between two equipment items
 */
export const getCompatibility = async (req: Request, res: Response) => {
  const client = await pgPool.connect();
  try {
    const { id1, id2 } = req.params;
    
    // Sort IDs to ensure consistent lookups
    const [sourceId, targetId] = [parseInt(id1), parseInt(id2)].sort((a, b) => a - b);
    
    // Track this compatibility check for analytics
    const sessionId = req.headers['x-session-id']?.toString() || 'anonymous';
    const userId = req.headers['x-user-id']?.toString() || null;
    
    await client.query(`
      INSERT INTO compatibility_analytics
      (source_equipment_id, target_equipment_id, user_id, source, session_id)
      VALUES ($1, $2, $3, $4, $5)
    `, [sourceId, targetId, userId, 'API', sessionId]);
    
    // Check the database for compatibility rules
    const { rows } = await client.query(`
      SELECT r.*, 
        s.name as source_name, s.model as source_model, s.image_url as source_image,
        t.name as target_name, t.model as target_model, t.image_url as target_image
      FROM compatibility_rules r
      JOIN equipment s ON r.source_equipment_id = s.id
      JOIN equipment t ON r.target_equipment_id = t.id
      WHERE (r.source_equipment_id = $1 AND r.target_equipment_id = $2)
      OR (r.source_equipment_id = $2 AND r.target_equipment_id = $1)
    `, [sourceId, targetId]);
    
    // Update check count and last checked timestamp
    if (rows.length > 0) {
      await client.query(`
        UPDATE compatibility_rules
        SET check_count = check_count + 1, last_checked_at = NOW()
        WHERE id = $1
      `, [rows[0].id]);
      
      return res.json({
        compatible: rows[0].compatibility_type === 'COMPATIBLE',
        type: rows[0].compatibility_type,
        confidence: rows[0].confidence_level,
        percentage: rows[0].compatibility_percentage,
        notes: rows[0].notes,
        modification: rows[0].modification_required,
        sourceEquipment: {
          id: rows[0].source_equipment_id,
          name: rows[0].source_name,
          model: rows[0].source_model,
          image: rows[0].source_image
        },
        targetEquipment: {
          id: rows[0].target_equipment_id,
          name: rows[0].target_name,
          model: rows[0].target_model,
          image: rows[0].target_image
        }
      });
    } else {
      // No compatibility rule found
      const [sourceEquipment] = (await client.query(`
        SELECT * FROM equipment WHERE id = $1
      `, [sourceId])).rows;
      
      const [targetEquipment] = (await client.query(`
        SELECT * FROM equipment WHERE id = $1
      `, [targetId])).rows;
      
      if (!sourceEquipment || !targetEquipment) {
        return res.status(404).json({ error: 'Equipment not found' });
      }
      
      // Return unknown compatibility
      return res.json({
        compatible: false,
        type: 'UNKNOWN',
        confidence: 'LOW',
        percentage: 0,
        notes: 'No compatibility information available for these items',
        sourceEquipment: {
          id: sourceEquipment.id,
          name: sourceEquipment.name,
          model: sourceEquipment.model,
          image: sourceEquipment.image_url
        },
        targetEquipment: {
          id: targetEquipment.id,
          name: targetEquipment.name,
          model: targetEquipment.model,
          image: targetEquipment.image_url
        }
      });
    }
  } catch (error) {
    logger.error(`Error checking compatibility: ${error instanceof Error ? error.message : String(error)}`);
    return res.status(500).json({ error: 'Failed to check compatibility' });
  } finally {
    client.release();
  }
};

/**
 * Get all equipment compatible with specified item
 */
export const getCompatibleEquipment = async (req: Request, res: Response) => {
  const client = await pgPool.connect();
  try {
    const { equipmentId } = req.params;
    const { category } = req.query;
    
    let query = `
      SELECT 
        e.*,
        m.name as manufacturer_name,
        c.name as category_name,
        r.compatibility_type,
        r.confidence_level,
        r.compatibility_percentage
      FROM compatibility_rules r
      JOIN equipment e ON (
        (r.source_equipment_id = $1 AND r.target_equipment_id = e.id) OR
        (r.target_equipment_id = $1 AND r.source_equipment_id = e.id)
      )
      JOIN manufacturers m ON e.manufacturer_id = m.id
      JOIN equipment_categories c ON e.category_id = c.id
      WHERE (r.compatibility_type = 'COMPATIBLE' OR r.compatibility_type = 'REQUIRES_MODIFICATION')
    `;
    
    const params = [parseInt(equipmentId)];
    
    // Add category filter if provided
    if (category) {
      query += ` AND c.id = $2`;
      params.push(parseInt(category as string));
    }
    
    // Add sorting
    query += ` ORDER BY r.compatibility_percentage DESC, e.name ASC`;
    
    const { rows } = await client.query(query, params);
    
    return res.json({
      count: rows.length,
      equipment: rows.map(item => ({
        id: item.id,
        name: item.name,
        model: item.model,
        manufacturer: item.manufacturer_name,
        category: item.category_name,
        image: item.image_url,
        compatibility: {
          type: item.compatibility_type,
          confidence: item.confidence_level,
          percentage: item.compatibility_percentage
        }
      }))
    });
  } catch (error) {
    logger.error(`Error getting compatible equipment: ${error instanceof Error ? error.message : String(error)}`);
    return res.status(500).json({ error: 'Failed to get compatible equipment' });
  } finally {
    client.release();
  }
};

/**
 * Add a new compatibility rule
 */
export const addCompatibilityRule = async (req: Request, res: Response) => {
  const client = await pgPool.connect();
  try {
    const { sourceId, targetId, compatibilityType, confidenceLevel, percentage, notes, modification } = req.body;
    
    // Validate required fields
    if (!sourceId || !targetId || !compatibilityType || !confidenceLevel) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    
    // Check if the equipment exists
    const sourceEquipment = await client.query('SELECT * FROM equipment WHERE id = $1', [sourceId]);
    const targetEquipment = await client.query('SELECT * FROM equipment WHERE id = $1', [targetId]);
    
    if (sourceEquipment.rows.length === 0 || targetEquipment.rows.length === 0) {
      return res.status(404).json({ error: 'Equipment not found' });
    }
    
    // Check if a rule already exists
    const existingRule = await client.query(`
      SELECT * FROM compatibility_rules
      WHERE (source_equipment_id = $1 AND target_equipment_id = $2)
      OR (source_equipment_id = $2 AND target_equipment_id = $1)
    `, [sourceId, targetId]);
    
    if (existingRule.rows.length > 0) {
      return res.status(409).json({ error: 'Compatibility rule already exists' });
    }
    
    // Create new rule
    const { rows } = await client.query(`
      INSERT INTO compatibility_rules (
        source_equipment_id, target_equipment_id, compatibility_type, 
        confidence_level, compatibility_percentage, notes, 
        modification_required, source_type, created_by
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `, [
      sourceId, 
      targetId, 
      compatibilityType,
      confidenceLevel,
      percentage || 0,
      notes || null,
      modification || null,
      req.body.sourceType || 'USER_TESTED',
      req.body.userId || 'system'
    ]);
    
    return res.status(201).json(rows[0]);
  } catch (error) {
    logger.error(`Error adding compatibility rule: ${error instanceof Error ? error.message : String(error)}`);
    return res.status(500).json({ error: 'Failed to add compatibility rule' });
  } finally {
    client.release();
  }
};
