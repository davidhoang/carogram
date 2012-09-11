//
//  CGViewController.h
//  Carogram
//
//  Created by Jacob Moore on 8/22/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WFInstagramAPI.h"
#import "MediaSelectorDelegate.h"
#import "PagingMediaViewController.h"

@interface CGViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate, MediaSelectorDelegate, PagingMediaScrollDelegate>

@property (strong, nonatomic) WFIGUser *currentUser;
@property (strong, nonatomic) IBOutlet UIView *titleBarView;
@property (strong, nonatomic) IBOutlet UIImageView *ivSearchBg;
@property (strong, nonatomic) IBOutlet UIButton *btnPopular;
@property (strong, nonatomic) IBOutlet UIButton *btnHome;
@property (strong, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *ivProgressBackground;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (IBAction)touchPopular:(id)sender;
- (IBAction)touchHome:(id)sender;
- (IBAction)touchUser:(id)sender;
- (void)refresh;
- (void)setProgressViewShown:(BOOL)shown;

@end
