//
//  CRGSlideViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/29/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGSlideViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WFIGImageCache.h"
#import "UIFont+Carogram.h"
#import "SDWebImageManager.h"
#import "CRGProfileViewController.h"

static NSSet * ObservableKeys = nil;

static NSString * const MediaKeyPath = @"media";

@interface CRGSlideViewController ()
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
- (void)configureViews;
- (void)loadProfilePicture;
@end

@implementation CRGSlideViewController
@synthesize media = _media;
@synthesize ivPhoto = _ivPhoto;
@synthesize ivUser = _ivUser;
@synthesize lblCaption = _lblCaption;
@synthesize lblComments = _lblComments;
@synthesize lblLikes = _lblLikes;
@synthesize mediaView = _mediaView;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        ObservableKeys = [[NSSet alloc] initWithObjects:MediaKeyPath, nil];
        for (NSString *keyPath in ObservableKeys) {
            [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    return self;
}

- (void)dealloc
{
    for (NSString *keyPath in ObservableKeys) {
        [self removeObserver:self forKeyPath:keyPath context:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Round avatar image view
    self.ivUser.layer.opaque = YES;
    self.ivUser.layer.masksToBounds = YES;
    self.ivUser.layer.cornerRadius = 0;
    
    // Add rounded border layer
    CALayer *roundedLayer = [CALayer layer];
    roundedLayer.frame = CGRectMake(0, 0, self.ivUser.frame.size.width, self.ivUser.frame.size.height);
    roundedLayer.opaque = YES;
    roundedLayer.masksToBounds = YES;
    roundedLayer.cornerRadius = 0;
    roundedLayer.borderWidth = 1.0;
    roundedLayer.borderColor = [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3] CGColor];
    
    [self.ivUser.layer addSublayer:roundedLayer];
    
    [self configureViews];
}

- (void)viewDidUnload
{
    [self setIvPhoto:nil];   
    [self setIvUser:nil];
    [self setLblCaption:nil];
    [self setLblComments:nil];
    [self setLblLikes:nil];
    [self setMediaView:nil];
    [self setUsernameLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([ObservableKeys containsObject:keyPath]) {
        if ([keyPath isEqualToString:MediaKeyPath]) {
            [self configureViews];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)configureViews
{
    self.usernameLabel.font = [UIFont defaultFontOfSize:15];
    self.lblCaption.font = [UIFont defaultFontOfSize:12];
    self.lblComments.font = [UIFont defaultFontOfSize:15];
    self.lblLikes.font = [UIFont defaultFontOfSize:15];
    
    if (nil != self.media) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:self.media.imageURL]
                         options:0
                        progress:^(NSUInteger receivedSize, long long expectedSize) { }
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
         {
             if (image)
             {
                 [self.ivPhoto setImage:image];
             }
         }];
        [self loadProfilePicture];
        self.usernameLabel.text = self.media.user.username;
        [self.lblCaption setText:[self.media caption]];
        [self.lblComments setText:[NSString stringWithFormat:@"%d", [self.media commentsCount]]];
        [self.lblLikes setText:[NSString stringWithFormat:@"%d", [self.media likesCount]]];
    } else {
        self.usernameLabel.text = @"";
        [self.ivPhoto setImage:nil];
        [self.ivUser setImage:nil];
        [self.lblCaption setText:@""];
        [self.lblComments setText:@""];
        [self.lblLikes setText:@""];
    }
}

- (void)loadProfilePicture
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [WFIGImageCache getImageAtURL:[self.media.user profilePicture]];
        dispatch_async( dispatch_get_main_queue(), ^{
            if (image != nil) {
                self.ivUser.image = image;
            }
        });
    });
}

- (IBAction)touchMedia:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMedia:fromRect:)]) {
        [self.delegate didSelectMedia:self.media fromRect:self.mediaView.frame];
    }
}

- (IBAction)viewProfile:(id)sender {
    CRGProfileViewController *profileVC = (CRGProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"Profile"];
    profileVC.user = self.media.user;
    
    [self.navigationController pushViewController:profileVC animated:YES];
}

@end
