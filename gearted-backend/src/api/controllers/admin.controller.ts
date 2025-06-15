import { Request, Response } from 'express';
import User from '../../models/user.model';
import Listing from '../../models/listing.model';
import Message from '../../models/message.model';
import Conversation from '../../models/conversation.model';

// Dashboard Statistics
export const getAdminStats = async (req: Request, res: Response) => {
  try {
    const [userCount, listingCount, messageCount] = await Promise.all([
      User.countDocuments(),
      Listing.countDocuments(),
      Message.countDocuments()
    ]);

    const stats = {
      users: userCount,
      listings: listingCount,
      messages: messageCount,
      recentUsers: await User.find()
        .sort({ createdAt: -1 })
        .limit(5)
        .select('username email createdAt'),
      recentListings: await Listing.find()
        .sort({ createdAt: -1 })
        .limit(5)
        .populate('sellerId', 'username email')
        .select('title price createdAt sellerId')
    };

    res.json(stats);
  } catch (error) {
    console.error('Admin stats error:', error);
    res.status(500).json({ message: 'Failed to fetch admin statistics' });
  }
};

// User Management
export const getUsers = async (req: Request, res: Response) => {
  try {
    const { page = 1, limit = 20, search, status } = req.query;
    const pageNum = parseInt(page as string);
    const limitNum = parseInt(limit as string);
    const skip = (pageNum - 1) * limitNum;

    // Build query
    const query: any = {};
    if (search) {
      query.$or = [
        { username: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }
    if (status) {
      query.status = status;
    }

    const [users, total] = await Promise.all([
      User.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum)
        .select('-password'),
      User.countDocuments(query)
    ]);

    res.json({
      users,
      pagination: {
        currentPage: pageNum,
        totalPages: Math.ceil(total / limitNum),
        totalItems: total,
        hasNextPage: pageNum < Math.ceil(total / limitNum),
        hasPrevPage: pageNum > 1
      }
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ message: 'Failed to fetch users' });
  }
};

export const getUserById = async (req: Request, res: Response) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Get user's listings and messages count
    const [listingsCount, conversationsCount] = await Promise.all([
      Listing.countDocuments({ sellerId: user._id }),
      Conversation.countDocuments({ 
        participants: user._id
      })
    ]);

    res.json({
      ...user.toObject(),
      stats: {
        listingsCount,
        conversationsCount
      }
    });
  } catch (error) {
    console.error('Get user by ID error:', error);
    res.status(500).json({ message: 'Failed to fetch user' });
  }
};

export const updateUser = async (req: Request, res: Response) => {
  try {
    const { username, email, phone, status } = req.body;
    
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { username, email, phone, status },
      { new: true, runValidators: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ message: 'Failed to update user' });
  }
};

export const suspendUser = async (req: Request, res: Response) => {
  try {
    const { reason } = req.body;
    
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { 
        status: 'suspended',
        suspendedAt: new Date(),
        suspensionReason: reason
      },
      { new: true }
    ).select('-password');

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Also suspend all active listings by this user
    await Listing.updateMany(
      { sellerId: user._id },
      { isSold: true }
    );

    res.json({ message: 'User suspended successfully', user });
  } catch (error) {
    console.error('Suspend user error:', error);
    res.status(500).json({ message: 'Failed to suspend user' });
  }
};

export const deleteUser = async (req: Request, res: Response) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Delete user's listings and conversations
    await Promise.all([
      Listing.deleteMany({ sellerId: user._id }),
      Conversation.deleteMany({ participants: user._id }),
      Message.deleteMany({ sender: user._id }),
      User.findByIdAndDelete(req.params.id)
    ]);

    res.json({ message: 'User and associated data deleted successfully' });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ message: 'Failed to delete user' });
  }
};

// Listing Management
export const getListings = async (req: Request, res: Response) => {
  try {
    const { page = 1, limit = 20, search, status, category } = req.query;
    const pageNum = parseInt(page as string);
    const limitNum = parseInt(limit as string);
    const skip = (pageNum - 1) * limitNum;

    // Build query
    const query: any = {};
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } }
      ];
    }
    if (status) {
      query.status = status;
    }
    if (category) {
      query.category = category;
    }

    const [listings, total] = await Promise.all([
      Listing.find(query)
        .populate('sellerId', 'username email')
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum),
      Listing.countDocuments(query)
    ]);

    res.json({
      listings,
      pagination: {
        currentPage: pageNum,
        totalPages: Math.ceil(total / limitNum),
        totalItems: total,
        hasNextPage: pageNum < Math.ceil(total / limitNum),
        hasPrevPage: pageNum > 1
      }
    });
  } catch (error) {
    console.error('Get listings error:', error);
    res.status(500).json({ message: 'Failed to fetch listings' });
  }
};

export const getListingById = async (req: Request, res: Response) => {
  try {
    const listing = await Listing.findById(req.params.id)
      .populate('sellerId', 'username email phone');
    
    if (!listing) {
      return res.status(404).json({ message: 'Listing not found' });
    }

    res.json(listing);
  } catch (error) {
    console.error('Get listing by ID error:', error);
    res.status(500).json({ message: 'Failed to fetch listing' });
  }
};

export const updateListing = async (req: Request, res: Response) => {
  try {
    const listing = await Listing.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).populate('sellerId', 'username email');

    if (!listing) {
      return res.status(404).json({ message: 'Listing not found' });
    }

    res.json(listing);
  } catch (error) {
    console.error('Update listing error:', error);
    res.status(500).json({ message: 'Failed to update listing' });
  }
};

export const approveListing = async (req: Request, res: Response) => {
  try {
    const listing = await Listing.findByIdAndUpdate(
      req.params.id,
      { 
        isSold: false // Approve by making sure it's not sold
      },
      { new: true }
    ).populate('sellerId', 'username email');

    if (!listing) {
      return res.status(404).json({ message: 'Listing not found' });
    }

    res.json({ message: 'Listing approved successfully', listing });
  } catch (error) {
    console.error('Approve listing error:', error);
    res.status(500).json({ message: 'Failed to approve listing' });
  }
};

export const suspendListing = async (req: Request, res: Response) => {
  try {
    const { reason } = req.body;
    
    const listing = await Listing.findByIdAndUpdate(
      req.params.id,
      { 
        isSold: true // Suspend by marking as sold
      },
      { new: true }
    ).populate('sellerId', 'username email');

    if (!listing) {
      return res.status(404).json({ message: 'Listing not found' });
    }

    res.json({ message: `Listing suspended successfully. Reason: ${reason}`, listing });
  } catch (error) {
    console.error('Suspend listing error:', error);
    res.status(500).json({ message: 'Failed to suspend listing' });
  }
};

export const deleteListing = async (req: Request, res: Response) => {
  try {
    const listing = await Listing.findByIdAndDelete(req.params.id);
    if (!listing) {
      return res.status(404).json({ message: 'Listing not found' });
    }

    // Delete associated conversations and messages
    await Conversation.deleteMany({ listingId: listing._id });
    await Message.deleteMany({ 
      conversationId: { $in: await Conversation.find({ listingId: listing._id }).distinct('_id') }
    });

    res.json({ message: 'Listing deleted successfully' });
  } catch (error) {
    console.error('Delete listing error:', error);
    res.status(500).json({ message: 'Failed to delete listing' });
  }
};

// Message Management
export const getMessages = async (req: Request, res: Response) => {
  try {
    const { page = 1, limit = 20, search } = req.query;
    const pageNum = parseInt(page as string);
    const limitNum = parseInt(limit as string);
    const skip = (pageNum - 1) * limitNum;

    const query: any = {};
    if (search) {
      query.content = { $regex: search, $options: 'i' };
    }

    const [messages, total] = await Promise.all([
      Message.find(query)
        .populate('sender', 'username email')
        .populate({
          path: 'conversationId',
          populate: {
            path: 'participants',
            select: 'username email'
          }
        })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limitNum),
      Message.countDocuments(query)
    ]);

    res.json({
      messages,
      pagination: {
        currentPage: pageNum,
        totalPages: Math.ceil(total / limitNum),
        totalItems: total,
        hasNextPage: pageNum < Math.ceil(total / limitNum),
        hasPrevPage: pageNum > 1
      }
    });
  } catch (error) {
    console.error('Get messages error:', error);
    res.status(500).json({ message: 'Failed to fetch messages' });
  }
};

export const deleteMessage = async (req: Request, res: Response) => {
  try {
    const message = await Message.findByIdAndDelete(req.params.id);
    if (!message) {
      return res.status(404).json({ message: 'Message not found' });
    }

    res.json({ message: 'Message deleted successfully' });
  } catch (error) {
    console.error('Delete message error:', error);
    res.status(500).json({ message: 'Failed to delete message' });
  }
};

// Reports Management (placeholder - implement when report model exists)
export const getReports = async (req: Request, res: Response) => {
  try {
    // Placeholder for reports functionality
    res.json({ reports: [], message: 'Reports feature not yet implemented' });
  } catch (error) {
    console.error('Get reports error:', error);
    res.status(500).json({ message: 'Failed to fetch reports' });
  }
};

export const resolveReport = async (req: Request, res: Response) => {
  try {
    // Placeholder for report resolution
    res.json({ message: 'Report resolution feature not yet implemented' });
  } catch (error) {
    console.error('Resolve report error:', error);
    res.status(500).json({ message: 'Failed to resolve report' });
  }
};

// Settings Management
export const getSettings = async (req: Request, res: Response) => {
  try {
    // Return basic app settings
    const settings = {
      siteName: 'Gearted',
      maintenanceMode: false,
      registrationEnabled: true,
      emailNotifications: true,
      adminEmail: 'admin@gearted.com',
      maxFileSize: '10MB',
      allowedFileTypes: ['jpg', 'jpeg', 'png', 'webp'],
      moderationEnabled: true
    };

    res.json(settings);
  } catch (error) {
    console.error('Get settings error:', error);
    res.status(500).json({ message: 'Failed to fetch settings' });
  }
};

export const updateSettings = async (req: Request, res: Response) => {
  try {
    // In a real app, you'd store these in a settings collection
    // For now, just return the updated settings
    res.json({ message: 'Settings updated successfully', settings: req.body });
  } catch (error) {
    console.error('Update settings error:', error);
    res.status(500).json({ message: 'Failed to update settings' });
  }
};

// Analytics
export const getAnalytics = async (req: Request, res: Response) => {
  try {
    const { period = '30d' } = req.query;
    
    // Calculate date range
    const now = new Date();
    let startDate = new Date();
    
    switch (period) {
      case '7d':
        startDate.setDate(now.getDate() - 7);
        break;
      case '30d':
        startDate.setDate(now.getDate() - 30);
        break;
      case '90d':
        startDate.setDate(now.getDate() - 90);
        break;
      default:
        startDate.setDate(now.getDate() - 30);
    }

    const [
      userGrowth,
      listingGrowth,
      messageGrowth,
      categoryStats,
      statusStats
    ] = await Promise.all([
      User.countDocuments({ createdAt: { $gte: startDate } }),
      Listing.countDocuments({ createdAt: { $gte: startDate } }),
      Message.countDocuments({ createdAt: { $gte: startDate } }),
      Listing.aggregate([
        { $group: { _id: '$category', count: { $sum: 1 } } },
        { $sort: { count: -1 } }
      ]),
      Listing.aggregate([
        { $group: { _id: '$status', count: { $sum: 1 } } }
      ])
    ]);

    res.json({
      period,
      userGrowth,
      listingGrowth,
      messageGrowth,
      categoryStats,
      statusStats,
      generatedAt: new Date()
    });
  } catch (error) {
    console.error('Get analytics error:', error);
    res.status(500).json({ message: 'Failed to fetch analytics' });
  }
};
