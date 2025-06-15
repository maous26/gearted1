import { logger } from '../utils/logger';

// Event types for tracking
export enum AnalyticsEventType {
  // User events
  USER_SIGNUP = 'user_signup',
  USER_LOGIN = 'user_login',
  PROFILE_COMPLETED = 'profile_completed',
  PROFILE_UPDATED = 'profile_updated',
  
  // Listing events
  LISTING_CREATED = 'listing_created',
  LISTING_VIEWED = 'listing_viewed',
  LISTING_FAVORITED = 'listing_favorited',
  LISTING_SHARED = 'listing_shared',
  LISTING_CONTACTED = 'listing_contacted',
  
  // Search events
  SEARCH_PERFORMED = 'search_performed',
  FILTER_APPLIED = 'filter_applied',
  
  // Transaction events
  OFFER_MADE = 'offer_made',
  OFFER_ACCEPTED = 'offer_accepted',
  TRANSACTION_COMPLETED = 'transaction_completed',
  PAYMENT_COMPLETED = 'payment_completed',
  
  // Chat events
  MESSAGE_SENT = 'message_sent',
  CONVERSATION_STARTED = 'conversation_started',
  
  // Engagement events
  APP_OPENED = 'app_opened',
  PUSH_NOTIFICATION_OPENED = 'push_notification_opened',
  EMAIL_OPENED = 'email_opened',
}

// User segments for targeted campaigns
export interface UserSegment {
  id: string;
  name: string;
  criteria: Record<string, any>;
  description: string;
}

export const USER_SEGMENTS: UserSegment[] = [
  {
    id: 'new_users',
    name: 'Nouveaux utilisateurs',
    criteria: { days_since_signup: { $lte: 7 } },
    description: 'Utilisateurs inscrits il y a moins de 7 jours'
  },
  {
    id: 'active_searchers',
    name: 'Chercheurs actifs',
    criteria: { searches_last_7d: { $gte: 5 } },
    description: 'Utilisateurs ayant effectué 5+ recherches cette semaine'
  },
  {
    id: 'inactive_sellers',
    name: 'Vendeurs inactifs',
    criteria: { last_listing_date: { $lte: new Date(Date.now() - 30*24*60*60*1000) } },
    description: 'Vendeurs sans annonce depuis 30 jours'
  },
  {
    id: 'power_buyers',
    name: 'Acheteurs premium',
    criteria: { transactions_last_30d: { $gte: 3 }, total_spent: { $gte: 500 } },
    description: 'Acheteurs fréquents et de valeur'
  },
  {
    id: 'at_risk_users',
    name: 'Utilisateurs à risque',
    criteria: { last_activity: { $lte: new Date(Date.now() - 14*24*60*60*1000) } },
    description: 'Utilisateurs inactifs depuis 2 semaines'
  }
];

// Analytics event interface
export interface AnalyticsEvent {
  eventType: AnalyticsEventType;
  userId?: string;
  sessionId?: string;
  timestamp: Date;
  properties: Record<string, any>;
  metadata?: {
    userAgent?: string;
    ip?: string;
    platform?: string;
    version?: string;
  };
}

// Conversion funnels configuration
export interface ConversionFunnel {
  id: string;
  name: string;
  steps: AnalyticsEventType[];
  timeWindow: number; // in hours
}

export const CONVERSION_FUNNELS: ConversionFunnel[] = [
  {
    id: 'signup_to_first_listing',
    name: 'Inscription → Première annonce',
    steps: [
      AnalyticsEventType.USER_SIGNUP,
      AnalyticsEventType.PROFILE_COMPLETED,
      AnalyticsEventType.LISTING_CREATED
    ],
    timeWindow: 168 // 7 days
  },
  {
    id: 'search_to_purchase',
    name: 'Recherche → Achat',
    steps: [
      AnalyticsEventType.SEARCH_PERFORMED,
      AnalyticsEventType.LISTING_VIEWED,
      AnalyticsEventType.LISTING_CONTACTED,
      AnalyticsEventType.OFFER_MADE,
      AnalyticsEventType.TRANSACTION_COMPLETED
    ],
    timeWindow: 72 // 3 days
  },
  {
    id: 'view_to_favorite',
    name: 'Vue → Favori',
    steps: [
      AnalyticsEventType.LISTING_VIEWED,
      AnalyticsEventType.LISTING_FAVORITED
    ],
    timeWindow: 24 // 1 day
  }
];

// Price range helper
function getPriceRange(price: number): string {
  if (price < 50) return 'under_50';
  if (price < 100) return '50_100';
  if (price < 200) return '100_200';
  if (price < 500) return '200_500';
  return 'over_500';
}

class AnalyticsService {
  private static instance: AnalyticsService;
  
  private constructor() {}
  
  public static getInstance(): AnalyticsService {
    if (!AnalyticsService.instance) {
      AnalyticsService.instance = new AnalyticsService();
    }
    return AnalyticsService.instance;
  }
  
  /**
   * Track an analytics event
   */
  async trackEvent(event: AnalyticsEvent): Promise<void> {
    try {
      // Enhanced properties based on event type
      const enhancedProperties = this.enhanceEventProperties(event);
      
      const enrichedEvent = {
        ...event,
        properties: enhancedProperties,
        timestamp: new Date()
      };
      
      // Store in database (implement with your preferred analytics DB)
      await this.storeEvent(enrichedEvent);
      
      // Send to external analytics services (Mixpanel, GA, etc.)
      await this.sendToExternalServices(enrichedEvent);
      
      logger.info(`Analytics event tracked: ${event.eventType} - User: ${event.userId} - Properties: ${JSON.stringify(enhancedProperties)}`);
      
    } catch (error) {
      logger.error(`Failed to track analytics event: ${event.eventType} - Error: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
  
  /**
   * Track listing creation with enhanced properties
   */
  async trackListingCreated(listing: any, userId: string): Promise<void> {
    await this.trackEvent({
      eventType: AnalyticsEventType.LISTING_CREATED,
      userId,
      timestamp: new Date(),
      properties: {
        category: listing.category,
        price: listing.price,
        price_range: getPriceRange(listing.price),
        has_images: listing.images?.length > 0,
        image_count: listing.images?.length || 0,
        has_description: !!listing.description && listing.description.length > 50,
        condition: listing.condition,
        location_provided: !!listing.location,
        shipping_available: listing.shippingAvailable
      }
    });
  }
  
  /**
   * Track search performed with enhanced properties
   */
  async trackSearchPerformed(searchParams: any, userId?: string, results?: any[]): Promise<void> {
    await this.trackEvent({
      eventType: AnalyticsEventType.SEARCH_PERFORMED,
      userId,
      timestamp: new Date(),
      properties: {
        query: searchParams.query,
        has_filters: Object.keys(searchParams.filters || {}).length > 0,
        filter_count: Object.keys(searchParams.filters || {}).length,
        category_filter: searchParams.filters?.category,
        price_min: searchParams.filters?.priceMin,
        price_max: searchParams.filters?.priceMax,
        location_filter: !!searchParams.filters?.location,
        results_count: results?.length || 0,
        has_results: (results?.length || 0) > 0
      }
    });
  }
  
  /**
   * Track transaction completion
   */
  async trackTransactionCompleted(transaction: any): Promise<void> {
    await this.trackEvent({
      eventType: AnalyticsEventType.TRANSACTION_COMPLETED,
      userId: transaction.buyerId,
      timestamp: new Date(),
      properties: {
        transaction_id: transaction._id,
        seller_id: transaction.sellerId,
        listing_id: transaction.listingId,
        amount: transaction.amount,
        payment_method: transaction.paymentMethod,
        transaction_value: transaction.amount,
        seller_rating: transaction.sellerRating,
        buyer_rating: transaction.buyerRating,
        shipping_method: transaction.shippingMethod,
        transaction_duration_hours: this.calculateTransactionDuration(transaction)
      }
    });
  }
  
  /**
   * Calculate user segments
   */
  async calculateUserSegments(userId: string): Promise<string[]> {
    const userSegments: string[] = [];
    
    // This would query your user analytics data
    // For now, returning sample segments
    return userSegments;
  }
  
  /**
   * Get conversion funnel metrics
   */
  async getFunnelMetrics(funnelId: string, dateRange: { start: Date; end: Date }): Promise<any> {
    const funnel = CONVERSION_FUNNELS.find(f => f.id === funnelId);
    if (!funnel) {
      throw new Error(`Funnel not found: ${funnelId}`);
    }
    
    // Implementation would calculate actual funnel metrics
    // Return sample data for now
    return {
      funnelId,
      totalUsers: 1000,
      stepConversions: funnel.steps.map((step, index) => ({
        step,
        users: Math.floor(1000 * Math.pow(0.7, index)),
        conversionRate: Math.pow(0.7, index)
      }))
    };
  }
  
  private enhanceEventProperties(event: AnalyticsEvent): Record<string, any> {
    const baseProperties = { ...event.properties };
    
    // Add common properties
    baseProperties.timestamp = event.timestamp;
    baseProperties.event_type = event.eventType;
    
    // Enhance based on event type
    switch (event.eventType) {
      case AnalyticsEventType.LISTING_CREATED:
        if (baseProperties.price) {
          baseProperties.price_range = getPriceRange(baseProperties.price);
        }
        break;
        
      case AnalyticsEventType.SEARCH_PERFORMED:
        baseProperties.search_duration = Date.now() - (baseProperties.searchStartTime || Date.now());
        break;
    }
    
    return baseProperties;
  }
  
  private async storeEvent(event: AnalyticsEvent): Promise<void> {
    // Store in MongoDB or your preferred analytics database
    // Implementation depends on your data model
  }
  
  private async sendToExternalServices(event: AnalyticsEvent): Promise<void> {
    // Send to Mixpanel, Google Analytics, etc.
    // Implementation depends on your external services
  }
  
  private calculateTransactionDuration(transaction: any): number {
    if (transaction.createdAt && transaction.completedAt) {
      return Math.floor((transaction.completedAt - transaction.createdAt) / (1000 * 60 * 60));
    }
    return 0;
  }
}

export default AnalyticsService.getInstance();
