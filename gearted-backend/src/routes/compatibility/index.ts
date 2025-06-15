import { Router } from 'express';
import * as compatibilityController from '../../controllers/compatibility/compatibility.controller';
import { cache } from '../../middleware/cache';
import { handleAsync } from '../../utils/asyncHandler';

const router = Router();

/**
 * @route   GET /v1/compatibility/:id1/:id2
 * @desc    Check compatibility between two equipment items
 */
router.get(
  '/:id1/:id2', 
  cache('compatibility', 1800), 
  handleAsync(compatibilityController.getCompatibility)
);

/**
 * @route   GET /v1/compatibility/equipment/:equipmentId
 * @desc    Get all equipment compatible with specified item
 */
router.get(
  '/equipment/:equipmentId', 
  cache('compatible-equipment', 1800), 
  handleAsync(compatibilityController.getCompatibleEquipment)
);

/**
 * @route   POST /v1/compatibility
 * @desc    Add a new compatibility rule
 */
router.post(
  '/', 
  handleAsync(compatibilityController.addCompatibilityRule)
);

export default router;
