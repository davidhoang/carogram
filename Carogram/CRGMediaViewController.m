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
#import "UIFont+Carogram.h"

#define kRefreshDrag -67.

static int currentUserObserverContext;

CGRect kSlideViewMediaRect = { {170., 8.}, {684., 703.} };

@interface CRGMediaViewController ()
@property (strong, nonatomic) UIImageView *ivBackground;
@property (strong, nonatomic) UIImageView *ivRefreshIcon;
@property (strong, nonatomic) CRGPagingGridViewController *pagingGridViewController;
@property (strong, nonatomic) CRGPagingSlideViewController *pagingSlideViewController;
@property (strong, nonatomic) UILabel *noResultsLabel;
- (void)setupRefreshViews;
- (void)setupBackgroundView;
- (void)setupProgressView;
@end

@implementation CRGMediaViewController {
    CGFloat _pinchScale;
    BOOL _zoomRecognized;
    BOOL _resetView;
    CGPoint _gridCellCenter;
    CGFloat _gridCellScale;
    CGFloat _slideCellScale;
    CGPoint _slideCellCenter;
    UIView *_selectedGridCell;
    UIView *_selectedSlideCell;
}
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
        [self CRGMediaViewController_commonInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self CRGMediaViewController_commonInit];
    }
    return self;
}

- (void)CRGMediaViewController_commonInit
{
    _noResultsText = @"No Results";
    
    [self addKeyValueObservers];
}

- (void)dealloc
{
    [self removeKeyValueObservers];
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
    
    CRGAppDelegate *appDelegate = (CRGAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.currentUser = appDelegate.currentUser;
    
    [self loadMediaCollection];
    
    UIPinchGestureRecognizer *pinchRecognizer =
    [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchRecognizer];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark -

- (void)showGridViewAtIndex:(int)index
{
    if (self.pagingGridViewController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        self.pagingGridViewController =
        (CRGPagingGridViewController *)[storyboard instantiateViewControllerWithIdentifier: @"PagingGrid"];
        self.pagingGridViewController.delegate = self;
        self.pagingGridViewController.mediaSelectorDelegate = self;
        self.pagingGridViewController.view.frame = self.view.bounds;
    }
    self.pagingGridViewController.mediaCollection = self.mediaCollection;
    [self.pagingGridViewController setCurrentPage:index animated:NO];
    
    [self.pagingSlideViewController willMoveToParentViewController:nil];
    [self addChildViewController:self.pagingGridViewController];
    
    [self.pagingSlideViewController.view removeFromSuperview];
    [self.view addSubview:self.pagingGridViewController.view];
    
    [self.pagingSlideViewController removeFromParentViewController];
    [self.pagingGridViewController didMoveToParentViewController:self];
    
    self.currentMediaController = self.pagingGridViewController;
}

- (void)addPagingGridControllerToViewHidden:(BOOL)hidden
{
    if (! self.pagingGridViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        self.pagingGridViewController =
            (CRGPagingGridViewController *)[storyboard instantiateViewControllerWithIdentifier: @"PagingGrid"];
        self.pagingGridViewController.delegate = self;
        self.pagingGridViewController.mediaSelectorDelegate = self;
        self.pagingGridViewController.view.frame = self.view.bounds;
    }
    self.pagingGridViewController.mediaCollection = self.mediaCollection;
    self.pagingGridViewController.view.hidden = hidden;
    
    [self addChildViewController:self.pagingGridViewController];
    [self.view addSubview:self.pagingGridViewController.view];
    [self.pagingGridViewController didMoveToParentViewController:self];
}

- (void)addPagingSlideControllerToViewHidden:(BOOL)hidden
{
    if (self.pagingSlideViewController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        self.pagingSlideViewController =
        (CRGPagingSlideViewController *)[storyboard instantiateViewControllerWithIdentifier: @"PagingSlide"];
        self.pagingSlideViewController.delegate = self;
        self.pagingSlideViewController.mediaSelectorDelegate = self;
        self.pagingSlideViewController.view.frame = self.view.bounds;
    }

    self.pagingSlideViewController.mediaCollection = self.mediaCollection;
    self.pagingSlideViewController.view.hidden = hidden;
    
    [self addChildViewController:self.pagingSlideViewController];
    [self.view addSubview:self.pagingSlideViewController.view];
    [self.pagingSlideViewController didMoveToParentViewController:self];
}

- (void)refresh
{
    [self loadMediaCollection];
}

- (void)didLogout
{
    [self setProgressViewShown:YES];
    self.currentMediaController.view.hidden = YES;
}

- (void) loadMediaCollection { } // subclasses should override this method

- (void)showNoResultsLabel
{
    if (! self.noResultsLabel) {
        self.noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 1024, 32)];
        self.noResultsLabel.textColor = [UIColor colorWithRed:(247./255.) green:(247./255.) blue:(247./255.) alpha:1];
        self.noResultsLabel.textAlignment = UITextAlignmentCenter;
        self.noResultsLabel.font = [UIFont gothamBookFontOfSize:20];
        self.noResultsLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.noResultsLabel];
    }
    self.noResultsLabel.text = self.noResultsText;
    self.noResultsLabel.hidden = NO;
}

- (void)hideNoResultsLabel
{
    if (self.noResultsLabel) self.noResultsLabel.hidden = YES;
}

#pragma mark - Pinch Gesture handling

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    if (self.currentMediaController == self.pagingGridViewController) {
        [self handlePinchInGridView:recognizer];
    } else {
        [self handlePinchInSlideView:recognizer];
    }
}

- (void)handlePinchInGridView:(UIPinchGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            _zoomRecognized = NO;
            _resetView = YES;

            CGPoint firstPt = [recognizer locationOfTouch:0 inView:self.view];
            CGPoint secondPt = [recognizer locationOfTouch:1 inView:self.view];
            CGPoint midPt = CGPointMake((firstPt.x + secondPt.x) / 2.,
                                        (firstPt.y + secondPt.y) / 2.);
            
            int mediaIndex = [self.pagingGridViewController indexOfMediaAtPoint:midPt];
            self.pagingGridViewController.focusIndex = (mediaIndex % kImageCount);
            
            [self addPagingSlideControllerToViewHidden:YES];
            [self.pagingSlideViewController setCurrentPage:mediaIndex animated:NO];
            self.pagingSlideViewController.view.alpha = 0;
            self.pagingSlideViewController.view.hidden = NO;
            [self.view bringSubviewToFront:self.pagingSlideViewController.view];
            
            _selectedGridCell = [self.pagingGridViewController gridCellAtPoint:midPt];
            _selectedSlideCell = [self.pagingSlideViewController currentSlideCell];
            _selectedSlideCell.alpha = 0;

            _gridCellCenter = CGPointMake(CGRectGetMidX(_selectedGridCell.frame),
                                          CGRectGetMidY(_selectedGridCell.frame));
            _slideCellCenter = CGPointMake(CGRectGetMidX(_selectedSlideCell.frame),
                                           CGRectGetMidY(_selectedSlideCell.frame));

            _slideCellScale = _selectedSlideCell.frame.size.width / _selectedGridCell.frame.size.width;
        }
        case UIGestureRecognizerStateChanged: {
            _pinchScale = [recognizer scale];
            if (_pinchScale < 1) _pinchScale = powf(_pinchScale, .2);
            if (_pinchScale > _slideCellScale) _pinchScale = _slideCellScale;

            if (_pinchScale < 1) [self performGridZoom];
            else [self performCellZoom];

            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGFloat halfwayScale = ((_slideCellScale - 1.) / 2.) + 1.;
            if (_pinchScale >= halfwayScale && ! _zoomRecognized) {
                _zoomRecognized = YES;
                int index = [self.pagingGridViewController indexOfMediaAtPoint:_gridCellCenter];
                [self animateToSlideViewAtIndex:index];
            }
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            if (_zoomRecognized) break;
            [UIView animateWithDuration:.2 animations:^{
                _selectedGridCell.transform = CGAffineTransformIdentity;
                _selectedGridCell.center = _gridCellCenter;
                
                self.pagingSlideViewController.view.alpha = 0;
                self.pagingSlideViewController.view.center = _gridCellCenter;
                self.pagingSlideViewController.view.transform = CGAffineTransformMakeScale(1./_slideCellScale, 1./_slideCellScale);
                
                self.pagingGridViewController.peripheryAlpha = 1;

                self.pagingGridViewController.view.transform = CGAffineTransformIdentity;
            }];
        }
        default: break;
    }
}

- (void)handlePinchInSlideView:(UIPinchGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            _zoomRecognized = NO;
            _resetView = YES;

            int gridPage = [self.pagingSlideViewController currentPage] / kImageCount;
            
            [self addPagingGridControllerToViewHidden:YES];
            [self.pagingGridViewController setCurrentPage:gridPage animated:NO];
            self.pagingGridViewController.view.alpha = 0;
            self.pagingGridViewController.view.hidden = NO;
            [self.view bringSubviewToFront:self.pagingSlideViewController.view];
            
            int mediaIndex = [self.pagingSlideViewController currentPage] % kImageCount;
            _selectedGridCell = [self.pagingGridViewController gridCellAtIndex:mediaIndex];
            _selectedGridCell.alpha = 0;

            _selectedSlideCell = [self.pagingSlideViewController currentSlideCell];
            
            _gridCellCenter = CGPointMake(CGRectGetMidX(_selectedGridCell.frame), CGRectGetMidY(_selectedGridCell.frame));
            _slideCellCenter = CGPointMake(CGRectGetMidX(_selectedSlideCell.frame),
                                           CGRectGetMidY(_selectedSlideCell.frame));
            
            _gridCellScale = _selectedGridCell.frame.size.width / _selectedSlideCell.frame.size.width;
        }
        case UIGestureRecognizerStateChanged: {
            UIView *pagingSlideView = self.pagingSlideViewController.view;
            _pinchScale = [recognizer scale];
            if (_pinchScale > 1) _pinchScale = powf(_pinchScale, .2);
            if (_pinchScale < _gridCellScale) _pinchScale = _gridCellScale;
            pagingSlideView.transform = CGAffineTransformMakeScale(_pinchScale, _pinchScale);
            
            CGFloat scalePct = ((1. - _gridCellScale) - (_pinchScale - _gridCellScale)) / (1. - _gridCellScale);
            
            CGRect commonSlideCellFrame
                = [self.pagingSlideViewController.view convertRect:_selectedSlideCell.bounds
                                                          fromView:_selectedSlideCell];
            CGPoint commonSlideCellCtr = CGPointMake(CGRectGetMidX(commonSlideCellFrame),
                                                     CGRectGetMidY(commonSlideCellFrame));
            CGFloat centerX = commonSlideCellCtr.x + ( (_gridCellCenter.x - commonSlideCellCtr.x) * scalePct);
            CGFloat centerY = commonSlideCellCtr.y + ( (_gridCellCenter.y - commonSlideCellCtr.y) * scalePct);
            CGPoint center = CGPointMake(centerX, centerY);
            pagingSlideView.center = center;
            
            self.pagingGridViewController.view.alpha = MAX(0, MIN(1, scalePct));

            CGFloat slidePeripheryAlpha = 1. - (scalePct/.75);
            self.pagingSlideViewController.peripheryAlpha = MAX(0, MIN(1, slidePeripheryAlpha));
            
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGFloat halfwayScale = ((1. - _gridCellScale) / 2.) + _gridCellScale;
            if (_pinchScale <= halfwayScale && ! _zoomRecognized) {
                _zoomRecognized = YES;
                int mediaIndex = [self.pagingSlideViewController currentPage] % kImageCount;
                [self animateToGridViewAtIndex:mediaIndex];
            }
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            if (_zoomRecognized) break;
            UIView *pagingSlideView = self.pagingSlideViewController.view;
            [UIView animateWithDuration:0.2 animations:^{
                self.pagingGridViewController.view.alpha = 0;
                pagingSlideView.transform = CGAffineTransformIdentity;
                pagingSlideView.frame = self.view.bounds;
                self.pagingSlideViewController.peripheryAlpha = 1.;
            }];
        }
        default: break;
    }
}

- (void)performGridZoom
{
    _selectedGridCell.transform = CGAffineTransformIdentity;
    _selectedGridCell.center = _gridCellCenter;
    
    self.pagingSlideViewController.view.alpha = 0;
    self.pagingSlideViewController.view.center = _gridCellCenter;
    self.pagingSlideViewController.view.transform = CGAffineTransformMakeScale(1./_slideCellScale, 1./_slideCellScale);
    
    self.pagingGridViewController.peripheryAlpha = 1;

    self.pagingGridViewController.view.transform = CGAffineTransformMakeScale(_pinchScale, _pinchScale);
}

- (void)performCellZoom
{
    self.pagingGridViewController.view.transform = CGAffineTransformIdentity;

    _selectedGridCell.transform = CGAffineTransformMakeScale(_pinchScale, _pinchScale);
    
    CGFloat scalePct = (_pinchScale - 1.) / (_slideCellScale - 1);

    CGRect commonSlideCellFrame
        = [self.pagingSlideViewController.view convertRect:_selectedSlideCell.bounds
                                                  fromView:_selectedSlideCell];
    CGPoint commonSlideCellCtr = CGPointMake(CGRectGetMidX(commonSlideCellFrame),
                                             CGRectGetMidY(commonSlideCellFrame));
    CGFloat centerX = _gridCellCenter.x + ( (commonSlideCellCtr.x - _gridCellCenter.x) * scalePct);
    CGFloat centerY = _gridCellCenter.y + ( (commonSlideCellCtr.y - _gridCellCenter.y) * scalePct);
    CGPoint center = CGPointMake(centerX, centerY);

    _selectedGridCell.center = center;
    self.pagingSlideViewController.view.center = center;
    CGFloat slideViewScale = _pinchScale / _slideCellScale;
    self.pagingSlideViewController.view.transform = CGAffineTransformMakeScale(slideViewScale, slideViewScale);
    
    CGFloat slideAlpha = (scalePct/.75) - (1./3.);
    self.pagingSlideViewController.view.alpha = MAX(0, MIN(1, slideAlpha));
    
    CGFloat gridPeripheryAlpha = 1. - (scalePct/.75);
    self.pagingGridViewController.peripheryAlpha = MAX(0., MIN(1., gridPeripheryAlpha));
}

- (void)animateToGridViewAtIndex:(int)index
{
    UIView *pagingGridView = self.pagingGridViewController.view;
    UIView *pagingSlideView = self.pagingSlideViewController.view;
    
    _selectedGridCell.center = pagingSlideView.center;
    CGFloat gridScale = _pinchScale / _gridCellScale;
    _selectedGridCell.transform = CGAffineTransformMakeScale(gridScale, gridScale);
    _selectedGridCell.alpha = 1;

    [UIView animateWithDuration:0.2 animations:^{
        _selectedGridCell.transform = CGAffineTransformIdentity;
        _selectedGridCell.center = _gridCellCenter;

        pagingSlideView.transform = CGAffineTransformMakeScale(_gridCellScale, _gridCellScale);
        pagingSlideView.center = _gridCellCenter;
        pagingSlideView.alpha = 0;

        pagingGridView.alpha = 1;
    } completion:^(BOOL finished) {
        pagingSlideView.transform = CGAffineTransformIdentity;
        pagingSlideView.frame = self.view.bounds;
        [pagingSlideView removeFromSuperview];

        [self.pagingSlideViewController removeFromParentViewController];

        self.currentMediaController = self.pagingGridViewController;
    }];
}

- (void)animateToSlideViewAtIndex:(int)index
{
    [UIView animateWithDuration:0.2 animations:^{
        _selectedGridCell.transform = CGAffineTransformMakeScale(_slideCellScale, _slideCellScale);
        CGRect commonSlideCellFrame
            = [self.pagingSlideViewController.view convertRect:_selectedSlideCell.bounds
                                                      fromView:_selectedSlideCell];
        CGPoint commonSlideCellCtr = CGPointMake(CGRectGetMidX(commonSlideCellFrame),
                                                 CGRectGetMidY(commonSlideCellFrame));
        _selectedGridCell.center = commonSlideCellCtr;
        
        _selectedSlideCell.alpha = 1;
        
        self.pagingGridViewController.peripheryAlpha = 0;
        
        self.pagingSlideViewController.view.transform = CGAffineTransformIdentity;
        self.pagingSlideViewController.view.frame = self.view.bounds;
        self.pagingSlideViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        _selectedGridCell.alpha = 0;
        _selectedGridCell.center = _gridCellCenter;
        _selectedGridCell.transform = CGAffineTransformIdentity;
        
        [self.pagingGridViewController removeFromParentViewController];
        
        self.currentMediaController = self.pagingSlideViewController;
    }];
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
        if ([self isViewLoaded]) [self loadMediaCollection];
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
    CGRect bgFrame = self.ivBackground.frame;
    CGRect progressBgFrame = self.ivProgressBackground.frame;
    CGRect activityFrame = self.activityIndicatorView.frame;
    if (scrollView.contentOffset.x < 1) {
        bgFrame.origin.x = -scrollView.contentOffset.x;
        progressBgFrame.origin.x = (int)((self.view.frame.size.width/2.) - (progressBgFrame.size.width/2.)) - scrollView.contentOffset.x;
        activityFrame.origin.x = (int)((self.view.frame.size.width/2.) - (activityFrame.size.width/2.)) - scrollView.contentOffset.x;
    } else {
        bgFrame.origin.x = 0;
        progressBgFrame.origin.x = (int)((self.view.frame.size.width/2.) - (progressBgFrame.size.width/2.));
        activityFrame.origin.x = (int)((self.view.frame.size.width/2.) - (activityFrame.size.width/2.));
    }
    self.ivBackground.frame = bgFrame;
    self.ivProgressBackground.frame = progressBgFrame;
    self.activityIndicatorView.frame = activityFrame;
    
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

#pragma mark - MediaSelectorDelegate

- (void)didSelectMedia:(WFIGMedia *)media fromRect:(CGRect)rect
{
    rect.origin.y += self.view.frame.origin.y;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    CRGDetailsViewController *detailsVC = (CRGDetailsViewController *)[storyboard instantiateViewControllerWithIdentifier: @"Details"];
    [detailsVC setMedia:media];
    detailsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    detailsVC.startRect = rect;
    [self presentModalViewController:detailsVC animated:YES];
}

@end
