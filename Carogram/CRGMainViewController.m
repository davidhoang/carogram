//
//  CRGMainViewController.m
//  Carogram
//
//  Created by Jacob Moore on 1/21/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGMainViewController.h"
#import "CRGAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "WFInstagramAPI.h"
#import "WFIGImageCache.h"
#import "CRGUserFeedViewController.h"
#import "CRGPopularMediaViewController.h"
#import "CRGTagSearchViewController.h"
#import "CRGSplashProgressView.h"

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
@property (nonatomic) int currentViewControllerIndex;
@property (strong, nonatomic) UIViewController *currentViewController;
@property (strong, nonatomic) IBOutlet UIButton *popularMediaButton;
@property (strong, nonatomic) IBOutlet UIButton *userFeedButton;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) CRGSplashProgressView *splashView;
@end

@implementation CRGMainViewController {
    BOOL _showSplashViewOnViewLoad;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _currentViewControllerIndex = -1;
        _showSplashViewOnViewLoad = NO;
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
    
    self.currentViewControllerIndex = -1;
    [self showUserFeed:nil];
    
    if (_showSplashViewOnViewLoad) {
        self.splashView = [[CRGSplashProgressView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:self.splashView];
    }
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
    CRGAppDelegate *appDelegate = (CRGAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.currentUser = appDelegate.currentUser;
    if (nil != self.currentUser) [self loadProfilePicture];
    
    UIImage *patternImage = [UIImage imageNamed:@"title-bar-bg-tile"];
    self.titleBarView.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    
    self.searchBackgroundView.image =
    [[UIImage imageNamed:@"search-bg"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    
    self.searchTextField.font = [UIFont fontWithName:@"Gotham-Medium" size:14.];
    
    // Round account image view
    self.accountImageView.layer.opaque = YES;
    self.accountImageView.layer.masksToBounds = YES;
    
    // Add rounded border layer
    CALayer *roundedLayer = [CALayer layer];
    roundedLayer.frame = self.accountImageView.bounds;
    roundedLayer.opaque = YES;
    roundedLayer.masksToBounds = YES;
    roundedLayer.borderWidth = 1;
    roundedLayer.borderColor = [[UIColor colorWithRed:(85.0/255.0)
                                                green:(78.0/255.0)
                                                 blue:(59.0/255.0)
                                                alpha:1.0] CGColor];
    
    [self.accountImageView.layer addSublayer:roundedLayer];
}

- (void)showSplashViewOnViewLoad
{
    _showSplashViewOnViewLoad = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - Actions

- (IBAction)showUserFeed:(id)sender
{
    if (USER_FEED_INDEX == self.currentViewControllerIndex) return;
    self.currentViewControllerIndex = USER_FEED_INDEX;
    
    [self.userFeedButton setImage:[UIImage imageNamed:@"btn-user-feed-depressed"] forState:UIControlStateNormal];
    [self.popularMediaButton setImage:[UIImage imageNamed:@"btn-popular-media"] forState:UIControlStateNormal];
    
    CRGUserFeedViewController *userFeedController = self.viewControllers[USER_FEED_INDEX];
    if ((NSNull *)userFeedController == [NSNull null]) {
        userFeedController = [[CRGUserFeedViewController alloc] initWithNibName:nil bundle:nil];
        userFeedController.view.frame = self.contentFrame;
        userFeedController.delegate = self;
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

- (IBAction)showPopularMedia:(id)sender
{
    if (POPULAR_MEDIA_INDEX == self.currentViewControllerIndex) return;
    self.currentViewControllerIndex = POPULAR_MEDIA_INDEX;
    
    [self.popularMediaButton setImage:[UIImage imageNamed:@"btn-popular-media-depressed"] forState:UIControlStateNormal];
    [self.userFeedButton setImage:[UIImage imageNamed:@"btn-user-feed"] forState:UIControlStateNormal];
    
    CRGPopularMediaViewController *popularMediaController = self.viewControllers[POPULAR_MEDIA_INDEX];
    if ((NSNull *)popularMediaController == [NSNull null]) {
        popularMediaController = [[CRGPopularMediaViewController alloc] initWithNibName:nil bundle:nil];
        popularMediaController.view.frame = self.contentFrame;
        self.viewControllers[POPULAR_MEDIA_INDEX] = popularMediaController;
    }
    
    [self.currentViewController willMoveToParentViewController:nil];
    [self addChildViewController:popularMediaController];
    
    [self.currentViewController.view removeFromSuperview];
    [self.view insertSubview:popularMediaController.view belowSubview:self.titleBarView];
    
    [self.currentViewController removeFromParentViewController];
    [popularMediaController didMoveToParentViewController:self];
    
    self.currentViewController = popularMediaController;
}

- (IBAction)search:(id)sender
{
    [self.searchTextField resignFirstResponder];

    NSString *searchTag = self.searchTextField.text;
    if (! [searchTag length]) return;
    
    if ('#' == [searchTag characterAtIndex:0]) searchTag = [searchTag substringFromIndex:1];

    [self.popularMediaButton setImage:[UIImage imageNamed:@"btn-popular-media"] forState:UIControlStateNormal];
    [self.userFeedButton setImage:[UIImage imageNamed:@"btn-user-feed"] forState:UIControlStateNormal];

    CRGTagSearchViewController *tagSearchController = self.viewControllers[TAG_SEARCH_INDEX];
    if ((NSNull *)tagSearchController == [NSNull null]) {
        tagSearchController = [[CRGTagSearchViewController alloc] initWithNibName:nil bundle:nil];
        tagSearchController.view.frame = self.contentFrame;
        self.viewControllers[TAG_SEARCH_INDEX] = tagSearchController;
    }

    if (TAG_SEARCH_INDEX != self.currentViewControllerIndex) {
        self.currentViewControllerIndex = TAG_SEARCH_INDEX;
        
        [self.currentViewController willMoveToParentViewController:nil];
        [self addChildViewController:tagSearchController];
        
        [self.currentViewController.view removeFromSuperview];
        [self.view insertSubview:tagSearchController.view belowSubview:self.titleBarView];
        
        [self.currentViewController removeFromParentViewController];
        [tagSearchController didMoveToParentViewController:self];
        
        self.currentViewController = tagSearchController;
    }

    tagSearchController.searchTag = searchTag;
    [tagSearchController loadMediaCollection];
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
        CRGAppDelegate *appDelegate = (CRGAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate logout];
    }
}

#pragma mark - Key Value Observing

- (void)addKeyValueObservers
{
    CRGAppDelegate *appDelegate = (CRGAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate addObserver:self
                  forKeyPath:kCurrentUserKeyPath
                     options:NSKeyValueObservingOptionNew
                     context:&currentUserObserverContext];
}

- (void)removeKeyValueObservers
{
    CRGAppDelegate *appDelegate = (CRGAppDelegate *)[[UIApplication sharedApplication] delegate];
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
    [self setPopularMediaButton:nil];
    [self setUserFeedButton:nil];
    [self setSearchTextField:nil];
    [super viewDidUnload];
}

#pragma mark - CRGMediaViewControllerDelegate methods

- (void)mediaViewControllerDidLoadMediaCollection:(CRGMediaViewController *)mediaViewController
{
    if ([self.splashView superview] != nil) {
        [UIView animateWithDuration:.3 animations:^{
            self.splashView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.splashView removeFromSuperview];
            self.splashView = nil;
        }];
    }
}

@end

