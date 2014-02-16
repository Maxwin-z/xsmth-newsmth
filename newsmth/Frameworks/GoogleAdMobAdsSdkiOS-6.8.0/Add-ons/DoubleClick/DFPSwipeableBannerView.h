//
//  DFPSwipeableBannerView.h
//  Google Ads iOS SDK
//
//  Copyright (c) 2012 Google Inc. All rights reserved.
//

#import "DFPBannerView.h"
#import "GADSwipeableBannerViewDelegate.h"

@interface DFPSwipeableBannerView : DFPBannerView

// Set a delegate to be notified when the user activates and deactivates an ad.
// Remember to nil out the delegate before releasing this banner.
@property(nonatomic, assign) NSObject<GADSwipeableBannerViewDelegate> *swipeDelegate;

@end
