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
@end

@implementation CRGMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _currentViewControllerIndex = -1;
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

- (IBAction)showUserFeed:(id)sender
{
    if (USER_FEED_INDEX == self.currentViewControllerIndex) return;
    self.currentViewControllerIndex = USER_FEED_INDEX;
    
    [self.userFeedButton setImage:[UIImage imageNamed:@"btn-home-depressed"] forState:UIControlStateNormal];
    [self.popularMediaButton setImage:[UIImage imageNamed:@"btn-popular"] forState:UIControlStateNormal];
    
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

- (IBAction)showPopularMedia:(id)sender
{
    if (POPULAR_MEDIA_INDEX == self.currentViewControllerIndex) return;
    self.currentViewControllerIndex = POPULAR_MEDIA_INDEX;
    
    [self.popularMediaButton setImage:[UIImage imageNamed:@"btn-popular-depressed"] forState:UIControlStateNormal];
    [self.userFeedButton setImage:[UIImage imageNamed:@"btn-home"] forState:UIControlStateNormal];
    
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

    [self.popularMediaButton setImage:[UIImage imageNamed:@"btn-popular"] forState:UIControlStateNormal];
    [self.userFeedButton setImage:[UIImage imageNamed:@"btn-home"] forState:UIControlStateNormal];

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

@end

