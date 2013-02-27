//
//  CRGMainViewController.h
//  Carogram
//
//  Created by Jacob Moore on 1/21/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRGMediaViewController.h"

@interface CRGMainViewController : UIViewController <UIActionSheetDelegate, CRGMediaViewControllerDelegate>

@property (strong, nonatomic) WFIGUser *currentUser;

- (void)showSplashViewOnViewLoad;

@end
