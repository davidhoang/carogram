//
//  CRGDetailsViewController.h
//  Carogram
//
//  Created by Jacob Moore on 9/3/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFInstagramAPI.h"
#import "CRGNewCommentViewController.h"
#import "CRGPopoverView.h"
#import <MessageUI/MessageUI.h>

@interface CRGDetailsViewController : UIViewController <CRGNewCommentViewControllerDelegate, UIAlertViewDelegate, CRGPopoverViewDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) WFIGMedia *media;
@property (strong, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (nonatomic) CGRect startRect;
@property (strong, nonatomic) IBOutlet UIView *mediaView;
@property (strong, nonatomic) IBOutlet UIImageView *ivUser;
@property (strong, nonatomic) IBOutlet UILabel *lblCaption;
@property (strong, nonatomic) IBOutlet UILabel *lblComments;
@property (strong, nonatomic) IBOutlet UILabel *lblLikes;
@property (strong, nonatomic) IBOutlet UIView *commentsView;
@property (strong, nonatomic) IBOutlet UIButton *btnComments;

- (IBAction)touchClose:(id)sender;

@end
