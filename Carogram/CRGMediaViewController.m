//
//  CRGMediaViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/22/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGMediaViewController.h"
#import "CRGAppDelegate.h"
#import "CRGDetailsViewController.h"
#import "WFIGImageCache.h"
#import "CRGGridViewController.h"
#import "CRGPagingGridViewController.h"
#import "CRGPagingSlideViewController.h"

#define kRefreshDrag -67.

static int currentUserObserverContext;

@interface CRGMediaViewController ()
@property (strong, nonatomic) UIImageView *ivBackground;
@property (strong, nonatomic) UIImageView *ivRefreshIcon;
@property (strong, nonatomic) CRGPagingGridViewController *pagingGridViewController;
@property (strong, nonatomic) CRGPagingSlideViewController *pagingSlideViewController;
- (void)setupRefreshViews;
- (void)setupBackgroundView;
- (void)setupProgressView;
@end

@implementation CRGMediaViewController
@synthesize currentUser = _currentUser;
@synthesize titleBarView = _titleBarView;
@synthesize ivSearchBg = _ivSearchBg;
@synthesize btnPopular = _btnPopular;
@synthesize btnHome = _btnHome;
@synthesize ivPhoto = _ivPhoto;
@synthesize ivBackground = _ivBackground;
@synthesize scrollView = _scrollView;
@synthesize ivRefreshIcon = _ivRefreshIcon;
@synthesize ivProgressBackground = _ivProgressBackground;
@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize mediaCollection = _mediaCollection;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
    }
    return self;
}

#pragma mark - View Management

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    
    [self setupRefreshViews];
    [self setupBackgroundView];
    [self setupProgressView];
    [self showGridViewAtIndex:0];
    [self loadMediaCollection];
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

- (void)setupRefreshViews
{
    UIImageView *refreshBackground = [[UIImageView alloc] initWithFrame:self.view.frame];
    refreshBackground.image = [UIImage imageNamed:@"refresh-bg.jpg"];
    [refreshBackground setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self.view insertSubview:refreshBackground atIndex:0];
    
    self.ivRefreshIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-refresh"]];
    [self.ivRefreshIcon setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    self.ivRefreshIcon.layer.opacity = 0.5;
    
    CGRect refreshIconFrame = self.ivRefreshIcon.frame;
    refreshIconFrame.origin.x = 20;
    refreshIconFrame.origin.y = (self.view.frame.size.height / 2.) - (refreshIconFrame.size.height / 2.);
    self.ivRefreshIcon.frame = refreshIconFrame;
    [self.view insertSubview:self.ivRefreshIcon aboveSubview:refreshBackground];
}

- (void)setupBackgroundView
{
    self.ivBackground = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.ivBackground.image = [UIImage imageNamed:@"bg"];
    [self.ivBackground setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    // add shadow to background
    self.ivBackground.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.ivBackground.layer.shadowOffset = CGSizeMake(0,0);
    self.ivBackground.layer.shadowOpacity = 1.0;
    self.ivBackground.layer.shouldRasterize = YES;
    self.ivBackground.layer.shadowRadius = 8;
    
    [self.view insertSubview:self.ivBackground aboveSubview:self.ivRefreshIcon];
}

- (void)setupProgressView
{
    int x = (int)((self.view.frame.size.width/2.) - (127./2.));
    int y = (int)((self.view.frame.size.height/2.) - (107./2.));
    self.ivProgressBackground = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 127, 107)];
    self.ivProgressBackground.image =
    [[UIImage imageNamed:@"progress-bg"] stretchableImageWithLeftCapWidth:29 topCapHeight:30];
    [self.ivProgressBackground setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin
     |UIViewAutoresizingFlexibleLeftMargin
     |UIViewAutoresizingFlexibleBottomMargin
     |UIViewAutoresizingFlexibleRightMargin];
    [self.view insertSubview:self.ivProgressBackground aboveSubview:self.ivBackground];
    
    self.activityIndicatorView =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    x = (int)((self.view.frame.size.width/2.) - (self.activityIndicatorView.frame.size.width/2.));
    y = (int)((self.view.frame.size.height/2.) - (self.activityIndicatorView.frame.size.height/2.));
    self.activityIndicatorView.frame = CGRectMake(x,
                                                  y,
                                                  self.activityIndicatorView.frame.size.width,
                                                  self.activityIndicatorView.frame.size.height);
    [self.activityIndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin
     |UIViewAutoresizingFlexibleLeftMargin
     |UIViewAutoresizingFlexibleBottomMargin
     |UIViewAutoresizingFlexibleRightMargin];
    self.activityIndicatorView.color = [UIColor colorWithRed:(225./255.) green:(225./255.) blue:(225./255.) alpha:1];
    [self.view insertSubview:self.activityIndicatorView aboveSubview:self.ivProgressBackground];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"<CGVC> didReceiveMemoryWarning");
    if (self.pagingSlideViewController != nil && [self.pagingSlideViewController.view superview] == nil) {
        NSLog(@"setting pagingSlideVC to nil");
        self.pagingSlideViewController = nil;
    }
    if (self.pagingGridViewController != nil && [self.pagingGridViewController.view superview] == nil) {
        NSLog(@"setting pagingGridVC to nil");
        self.pagingGridViewController = nil;
    }
    [super didReceiveMemoryWarning];
}

#pragma mark -

- (void)showSlideViewAtIndex:(int)index
{
    if (self.pagingSlideViewController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        self.pagingSlideViewController =
            (CRGPagingSlideViewController *)[storyboard instantiateViewControllerWithIdentifier: @"PagingSlide"];
        self.pagingSlideViewController.delegate = self;
        self.pagingSlideViewController.mediaSelectorDelegate = self;
        self.pagingSlideViewController.mediaCollection = self.mediaCollection;
        self.pagingSlideViewController.view.frame = self.view.bounds; // self.contentFrame;
    }
    [self.pagingSlideViewController setCurrentPage:index animated:NO];
    
    [self.pagingGridViewController willMoveToParentViewController:nil];
    [self addChildViewController:self.pagingSlideViewController];

    [self.pagingGridViewController.view removeFromSuperview];
    [self.view addSubview:self.pagingSlideViewController.view];

    [self.pagingGridViewController removeFromParentViewController];
    [self.pagingSlideViewController didMoveToParentViewController:self];

    self.currentMediaController = self.pagingSlideViewController;
}

- (void)showGridViewAtIndex:(int)index
{
    if (self.pagingGridViewController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        self.pagingGridViewController =
            (CRGPagingGridViewController *)[storyboard instantiateViewControllerWithIdentifier: @"PagingGrid"];
        self.pagingGridViewController.delegate = self;
        self.pagingGridViewController.mediaSelectorDelegate = self;
        self.pagingGridViewController.mediaCollection = self.mediaCollection;
        self.pagingGridViewController.view.frame = self.view.bounds; // self.contentFrame;
    }
    [self.pagingGridViewController setCurrentPage:index animated:NO];
    
    [self.pagingSlideViewController willMoveToParentViewController:nil];
    [self addChildViewController:self.pagingGridViewController];

    [self.pagingSlideViewController.view removeFromSuperview];
    [self.view addSubview:self.pagingGridViewController.view];

    [self.pagingSlideViewController removeFromParentViewController];
    [self.pagingGridViewController didMoveToParentViewController:self];

    self.currentMediaController = self.pagingGridViewController;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)refresh
{
    [self loadMediaCollection];
}

- (void) loadMediaCollection { } // subclasses should override this method

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
        [self loadMediaCollection];
    }  else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -

- (void)setProgressViewShown:(BOOL)shown
{
    if (shown) {
        self.ivProgressBackground.hidden = NO;
        [self.activityIndicatorView startAnimating];
    } else {
        self.ivProgressBackground.hidden = YES;
        [self.activityIndicatorView stopAnimating];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex) {
        CRGAppDelegate *appDelegate = (CRGAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate logout];
    }
}

#pragma mark - PagingMediaScrollDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x < 1) {
        CGRect bgFrame = self.ivBackground.frame;
        bgFrame.origin.x = -scrollView.contentOffset.x;
        self.ivBackground.frame = bgFrame;
        
        CGRect progressBgFrame = self.ivProgressBackground.frame;
        progressBgFrame.origin.x = (int)((self.view.frame.size.width/2.) - (progressBgFrame.size.width/2.)) - scrollView.contentOffset.x;
        self.ivProgressBackground.frame = progressBgFrame;

        CGRect activityFrame = self.activityIndicatorView.frame;
        activityFrame.origin.x = (int)((self.view.frame.size.width/2.) - (activityFrame.size.width/2.)) - scrollView.contentOffset.x;
        self.activityIndicatorView.frame = activityFrame;
    }
    
    if (scrollView.contentOffset.x <= kRefreshDrag) {
        self.ivRefreshIcon.layer.opacity = 1.0;
    } else {
        self.ivRefreshIcon.layer.opacity = 0.5;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x <= kRefreshDrag) {
        [self refresh];
    }
}

- (void)pagingMediaViewController:(CRGPagingMediaViewController *)pagingMediaViewController didZoomInAtIndex:(int)index
{
    if (self.currentMediaController == self.pagingGridViewController) {
        [self showSlideViewAtIndex:index];
    }
}

- (void)pagingMediaViewController:(CRGPagingMediaViewController *)pagingMediaViewController didZoomOutAtIndex:(int)index
{
    if (self.currentMediaController == self.pagingSlideViewController) {
        int pageIndex = index / kImageCount;
        [self showGridViewAtIndex:pageIndex];
    }
}

#pragma mark - MediaSelectorDelegate

- (void)didSelectMedia:(WFIGMedia *)media fromRect:(CGRect)rect
{   
    rect.origin.y += (self.currentMediaController.view.frame.origin.y + 20); // 20 = status bar height
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    CRGDetailsViewController *detailsVC = (CRGDetailsViewController *)[storyboard instantiateViewControllerWithIdentifier: @"Details"];
    [detailsVC setMedia:media];
    detailsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    detailsVC.startRect = rect;
    [self presentModalViewController:detailsVC animated:YES];
}

@end
