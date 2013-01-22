//
//  CRGMainViewController.m
//  Carogram
//
//  Created by Jacob Moore on 1/21/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGMainViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "WFInstagramAPI.h"
#import "WFIGImageCache.h"
#import "CRGUserFeedViewController.h"

#define USER_FEED_INDEX     0
#define POPULAR_MEDIA_INDEX 1
#define TAG_SEARCH_INDEX    2

static int currentUserObserverContext;

@interface CRGMainViewController ()
@property (strong, nonatomic) IBOutlet UIView *titleBarView;
@property (strong, nonatomic) IBOutlet UIImageView *searchBackgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *accountImageView;
@property (strong, nonatomic) IBOutlet UIButton *accountButton;
@property (nonatomic) CGRect contentFrame;
@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (strong, nonatomic) UIViewController *currentViewController;
@end

@implementation CRGMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Management

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self setupTitleBarView];
    
    self.contentFrame = CGRectMake(0,
                                   self.titleBarView.bounds.size.height,
                                   self.view.bounds.size.width,
                                   self.view.bounds.size.height - self.titleBarView.bounds.size.height);
    
    self.viewControllers = [NSMutableArray new];
    [self.viewControllers addObject:[NSNull null]];
    [self.viewControllers addObject:[NSNull null]];
    [self.viewControllers addObject:[NSNull null]];
    
    [self showUserFeed];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addKeyValueObservers];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self removeKeyValueObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTitleBarView
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.currentUser = appDelegate.currentUser;
    if (nil != self.currentUser) [self loadProfilePicture];
    
    self.searchBackgroundView.image =
    [[UIImage imageNamed:@"search-bg"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    
    // Round account image view
    self.accountImageView.layer.opaque = YES;
    self.accountImageView.layer.masksToBounds = YES;
    self.accountImageView.layer.cornerRadius = 2.0;
    
    // Add rounded border layer
    CALayer *roundedLayer = [CALayer layer];
    roundedLayer.frame = CGRectMake(-1.0,
                                    -1.0,
                                    (self.accountImageView.frame.size.width + 2.0),
                                    (self.accountImageView.frame.size.height + 2.0));
    roundedLayer.opaque = YES;
    roundedLayer.masksToBounds = YES;
    roundedLayer.cornerRadius = 2.0;
    roundedLayer.borderWidth = 2.5;
    roundedLayer.borderColor = [[UIColor colorWithRed:(69.0/255.0)
                                                green:(73.0/255.0)
                                                 blue:(76.0/255.0)
                                                alpha:1.0] CGColor];
    
    [self.accountImageView.layer addSublayer:roundedLayer];
}

#pragma mark - Actions

- (IBAction)search:(id)sender {
    NSLog(@"searching...");
}

- (IBAction)showAccountPopup:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showFromRect:self.accountImageView.frame inView:self.view animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate logout];
    }
}

#pragma mark - Key Value Observing

- (void)addKeyValueObservers
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate addObserver:self
                  forKeyPath:kCurrentUserKeyPath
                     options:NSKeyValueObservingOptionNew
                     context:&currentUserObserverContext];
}

- (void)removeKeyValueObservers
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate removeObserver:self forKeyPath:kCurrentUserKeyPath context:&currentUserObserverContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (&currentUserObserverContext == context) {
        self.currentUser = (WFIGUser *)[change objectForKey:NSKeyValueChangeNewKey];
        [self loadProfilePicture];
    }  else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -

- (void)showUserFeed
{
    // TODO: select the home button "tab"

    CRGUserFeedViewController *userFeedController = self.viewControllers[USER_FEED_INDEX];
    if ((NSNull *)userFeedController == [NSNull null]) {
        userFeedController = [[CRGUserFeedViewController alloc] initWithNibName:nil bundle:nil];
        userFeedController.view.frame = self.contentFrame;
        self.viewControllers[USER_FEED_INDEX] = userFeedController;
    }
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self addChildViewController:userFeedController];
    
    [self.currentViewController.view removeFromSuperview];
    [self.view insertSubview:userFeedController.view belowSubview:self.titleBarView];
    
    [self.currentViewController removeFromParentViewController];
    [userFeedController didMoveToParentViewController:self];
    
    self.currentViewController = userFeedController;
}

- (void)loadProfilePicture
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [WFIGImageCache getImageAtURL:[self.currentUser profilePicture]];
        dispatch_async( dispatch_get_main_queue(), ^{
            if (image != nil) {
                self.accountImageView.image = image;
            }
        });
    });
}
        
- (void)viewDidUnload {
    [self setTitleBarView:nil];
    [super viewDidUnload];
}

@end

