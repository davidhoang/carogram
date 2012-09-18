//
//  UserFeedMediaController.h
//  Carogram
//
//  Created by Jacob Moore on 8/29/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFInstagramAPI.h"
#import "MediaSelectorDelegate.h"

@interface SlideViewController : UIViewController

@property (weak, nonatomic) id<MediaSelectorDelegate> delegate;
@property (strong, nonatomic) WFIGMedia *media;
@property (strong, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (strong, nonatomic) IBOutlet UIImageView *ivUser;
@property (strong, nonatomic) IBOutlet UILabel *lblCaption;
@property (strong, nonatomic) IBOutlet UILabel *lblComments;
@property (strong, nonatomic) IBOutlet UILabel *lblLikes;
@property (strong, nonatomic) IBOutlet UIView *mediaView;

- (IBAction)touchMedia:(id)sender;

@end
