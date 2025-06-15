import { Request, Response, NextFunction } from 'express';
import Listing, { ListingCondition } from '../models/listing.model';
import { logger } from '../utils/logger';

// Obtenir toutes les annonces avec pagination et filtrage
export const getListings = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      search = '', 
      category = '',
      subcategory = '',
      condition = '',
      minPrice,
      maxPrice,
      isExchangeable,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;
    
    // Construire le filtre
    const filter: any = {};
    
    // Recherche textuelle
    if (search) {
      filter.$text = { $search: search.toString() };
    }
    
    // Filtre par catégorie
    if (category) {
      filter.category = category;
    }
    
    // Filtre par sous-catégorie
    if (subcategory) {
      filter.subcategory = subcategory;
    }
    
    // Filtre par condition
    if (condition && Object.values(ListingCondition).includes(condition as ListingCondition)) {
      filter.condition = condition;
    }
    
    // Filtre par prix
    if (minPrice || maxPrice) {
      filter.price = {};
      if (minPrice) filter.price.$gte = Number(minPrice);
      if (maxPrice) filter.price.$lte = Number(maxPrice);
    }
    
    // Filtre par échange possible
    if (isExchangeable !== undefined) {
      filter.isExchangeable = isExchangeable === 'true';
    }
    
    // Ne pas inclure les annonces déjà vendues
    filter.isSold = false;
    
    // Pagination
    const pageNum = Number(page);
    const limitNum = Number(limit);
    const skip = (pageNum - 1) * limitNum;
    
    // Tri
    const sort: Record<string, 1 | -1> = {};
    sort[sortBy as string] = sortOrder === 'desc' ? -1 : 1;
    
    // Exécuter la requête
    const listings = await Listing.find(filter)
      .sort(sort)
      .skip(skip)
      .limit(limitNum)
      .populate('sellerId', 'username profileImage rating salesCount');
    
    // Compter le nombre total d'annonces
    const total = await Listing.countDocuments(filter);
    
    res.status(200).json({
      success: true,
      count: listings.length,
      total,
      totalPages: Math.ceil(total / limitNum),
      currentPage: pageNum,
      listings,
    });
  } catch (error) {
    logger.error(`Erreur lors de la récupération des annonces: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Obtenir une annonce par son ID
export const getListingById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    
    const listing = await Listing.findById(id)
      .populate('sellerId', 'username profileImage rating salesCount');
    
    if (!listing) {
      return res.status(404).json({
        success: false,
        message: 'Annonce non trouvée',
      });
    }
    
    res.status(200).json({
      success: true,
      listing,
    });
  } catch (error) {
    logger.error(`Erreur lors de la récupération de l'annonce: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Créer une nouvelle annonce
export const createListing = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { 
      title, 
      description, 
      price, 
      imageUrls, 
      condition, 
      category, 
      subcategory,
      tags, 
      isExchangeable 
    } = req.body;
    
    // L'ID du vendeur est extrait du middleware d'authentification
    const sellerId = (req as any).userId;
    
    const listing = new Listing({
      title,
      description,
      price,
      sellerId,
      imageUrls,
      condition,
      category,
      subcategory,
      tags,
      isExchangeable,
    });
    
    await listing.save();
    
    res.status(201).json({
      success: true,
      listing,
    });
  } catch (error) {
    logger.error(`Erreur lors de la création de l'annonce: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Mettre à jour une annonce
export const updateListing = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    const { 
      title, 
      description, 
      price, 
      imageUrls, 
      condition, 
      category, 
      tags, 
      isExchangeable 
    } = req.body;
    
    // Vérifier que l'annonce existe et appartient à l'utilisateur
    const listing = await Listing.findById(id);
    
    if (!listing) {
      return res.status(404).json({
        success: false,
        message: 'Annonce non trouvée',
      });
    }
    
    // Vérifier que l'utilisateur est le propriétaire de l'annonce
    if (listing.sellerId.toString() !== (req as any).userId) {
      return res.status(403).json({
        success: false,
        message: 'Vous n\'êtes pas autorisé à modifier cette annonce',
      });
    }
    
    // Mettre à jour l'annonce
    Object.assign(listing, {
      title,
      description,
      price,
      imageUrls,
      condition,
      category,
      tags,
      isExchangeable,
    });
    
    await listing.save();
    
    res.status(200).json({
      success: true,
      listing,
    });
  } catch (error) {
    logger.error(`Erreur lors de la mise à jour de l'annonce: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Supprimer une annonce
export const deleteListing = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    
    // Vérifier que l'annonce existe et appartient à l'utilisateur
    const listing = await Listing.findById(id);
    
    if (!listing) {
      return res.status(404).json({
        success: false,
        message: 'Annonce non trouvée',
      });
    }
    
    // Vérifier que l'utilisateur est le propriétaire de l'annonce
    if (listing.sellerId.toString() !== (req as any).userId) {
      return res.status(403).json({
        success: false,
        message: 'Vous n\'êtes pas autorisé à supprimer cette annonce',
      });
    }
    
    await Listing.findByIdAndDelete(id);
    
    res.status(200).json({
      success: true,
      message: 'Annonce supprimée avec succès',
    });
  } catch (error) {
    logger.error(`Erreur lors de la suppression de l'annonce: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};

// Marquer une annonce comme vendue
export const markAsSold = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    
    // Vérifier que l'annonce existe et appartient à l'utilisateur
    const listing = await Listing.findById(id);
    
    if (!listing) {
      return res.status(404).json({
        success: false,
        message: 'Annonce non trouvée',
      });
    }
    
    // Vérifier que l'utilisateur est le propriétaire de l'annonce
    if (listing.sellerId.toString() !== (req as any).userId) {
      return res.status(403).json({
        success: false,
        message: 'Vous n\'êtes pas autorisé à modifier cette annonce',
      });
    }
    
    // Marquer comme vendue
    listing.isSold = true;
    await listing.save();
    
    res.status(200).json({
      success: true,
      listing,
    });
  } catch (error) {
    logger.error(`Erreur lors du marquage de l'annonce comme vendue: ${error instanceof Error ? error.message : String(error)}`);
    next(error);
  }
};
