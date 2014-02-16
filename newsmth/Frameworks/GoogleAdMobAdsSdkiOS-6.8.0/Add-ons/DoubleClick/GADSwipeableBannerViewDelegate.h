//
//  GADSwipeableBannerViewDelegate.h
//  Google Ads iOS SDK
//
//  Copyright (c) 2012 Google Inc. All rights reserved.
//
//  The delegate will be notified when a user activates and deactivates an ad.
//  If the DFPSwipeableBannerView is contained within a UIScrollView, make sure
//  to set scrollEnabled = NO when -adViewDidActivateAd: is notified and to set
//  back to YES when -adViewDidDeactivateAd: is notified.
//

#import <Foundation/Foundation.h>

@class GADBannerView;

@protocol GADSwipeableBannerViewDelegate<NSObject>

@optional

- (void)adViewDidActivateAd:(GADBannerView *)banner;

- (void)adViewDidDeactivateAd:(GADBannerView *)banner;

@end
