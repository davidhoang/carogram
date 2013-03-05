//
//  CRGOnboardViewController.h
//  Carogram
//
//  Created by Jacob Moore on 3/4/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CRGOnboardViewControllerDelegate;

@interface CRGOnboardViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) id<CRGOnboardViewControllerDelegate> delegate;

@end

@protocol CRGOnboardViewControllerDelegate <NSObject>

- (void)onboardViewControllerDidFinish:(CRGOnboardViewController *)onboardViewController;

@end
