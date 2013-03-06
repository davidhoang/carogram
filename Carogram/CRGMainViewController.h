//
//  CRGMainViewController.h
//  Carogram
//
//  Created by Jacob Moore on 1/21/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRGMediaViewController.h"
#import "CRGPopoverView.h"
#import <MessageUI/MessageUI.h>

@interface CRGMainViewController : UIViewController <CRGMediaViewControllerDelegate, CRGPopoverViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) WFIGUser *currentUser;

- (void)showSplashViewOnViewLoad;
- (void)showOnboardingViewAnimated:(BOOL)animated;

@end
