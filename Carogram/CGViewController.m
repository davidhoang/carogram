//
//  CGViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/22/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CGViewController.h"
#import "AppDelegate.h"
#import "DetailsViewController.h"

#define kRefreshDrag -67.

static NSSet * ObservableKeys = nil;

@interface CGViewController ()
@property (strong, nonatomic) UIImageView *ivBackground;
@property (strong, nonatomic) UIImageView *ivRefreshIcon;
- (void)loadProfilePicture;
- (void)setupRefreshViews;
- (void)setupBackgroundView;
- (void)setupProgressView;
- (void)setupTitleBarView;
@end

@implementation CGViewController
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

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        if (nil == ObservableKeys) {
            ObservableKeys = [[NSSet alloc] initWithObjects:kCurrentUserKeyPath, nil];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (NSString *keyPath in ObservableKeys) {
        [appDelegate addObserver:self
                      forKeyPath:keyPath
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    }
    
    self.scrollView.delegate = self;
    
    [self setupRefreshViews];
    [self setupBackgroundView];
    [self setupProgressView];
    [self setupTitleBarView];
}

- (void)viewDidUnload
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (NSString *keyPath in ObservableKeys) {
        [appDelegate removeObserver:self forKeyPath:keyPath context:nil];
    }
    
    [self setTitleBarView:nil];
    [self setIvSearchBg:nil];
    [self setBtnPopular:nil];
    [self setBtnHome:nil];
    [self setIvPhoto:nil];
    [self setScrollView:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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
    self.ivProgressBackground.image = [[UIImage imageNamed:@"progress-bg"] stretchableImageWithLeftCapWidth:29 topCapHeight:30];
    [self.ivProgressBackground setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    [self.view insertSubview:self.ivProgressBackground aboveSubview:self.ivBackground];

    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    x = (int)((self.view.frame.size.width/2.) - (self.activityIndicatorView.frame.size.width/2.));
    y = (int)((self.view.frame.size.height/2.) - (self.activityIndicatorView.frame.size.height/2.));
    self.activityIndicatorView.frame = CGRectMake(x, y, self.activityIndicatorView.frame.size.width, self.activityIndicatorView.frame.size.height);
    [self.activityIndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin];
    self.activityIndicatorView.color = [UIColor colorWithRed:(225./255.) green:(225./255.) blue:(225./255.) alpha:1];
    [self.view insertSubview:self.activityIndicatorView aboveSubview:self.ivProgressBackground];
}

- (void)setupTitleBarView
{
    [[NSBundle mainBundle] loadNibNamed:@"TitleBarView" owner:self options:nil];
    [self.view addSubview:self.titleBarView];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.currentUser = appDelegate.currentUser;
    if (nil != self.currentUser) [self loadProfilePicture];

    self.ivSearchBg.image = [[UIImage imageNamed:@"search-bg"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    
    // Round avatar image view
    self.ivPhoto.layer.opaque = YES;
    self.ivPhoto.layer.masksToBounds = YES;
    self.ivPhoto.layer.cornerRadius = 2.0;
    
    // Add rounded border layer
    CALayer *roundedLayer = [CALayer layer];
    roundedLayer.frame = CGRectMake(-1.0, -1.0, (self.ivPhoto.frame.size.width + 2.0), (self.ivPhoto.frame.size.height + 2.0));
    roundedLayer.opaque = YES;
    roundedLayer.masksToBounds = YES;
    roundedLayer.cornerRadius = 2.0;
    roundedLayer.borderWidth = 2.5;
    roundedLayer.borderColor = [[UIColor colorWithRed:(69.0/255.0) green:(73.0/255.0) blue:(76.0/255.0) alpha:1.0] CGColor];
    
    [self.ivPhoto.layer addSublayer:roundedLayer];
    
    if (self.tabBarController.selectedIndex == 0) {
        [self.btnHome setImage:[UIImage imageNamed:@"btn-home-depressed"] forState:UIControlStateNormal];
        [self.btnPopular setImage:[UIImage imageNamed:@"btn-popular"] forState:UIControlStateNormal];
    } else {
        [self.btnHome setImage:[UIImage imageNamed:@"btn-home"] forState:UIControlStateNormal];
        [self.btnPopular setImage:[UIImage imageNamed:@"btn-popular-depressed"] forState:UIControlStateNormal];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![ObservableKeys containsObject:keyPath]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([kCurrentUserKeyPath isEqualToString:keyPath]) {
        self.currentUser = (WFIGUser *)[change objectForKey:NSKeyValueChangeNewKey];
        [self loadProfilePicture];
    }
}

- (void)loadProfilePicture
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.currentUser profilePicture]]]];
        dispatch_async( dispatch_get_main_queue(), ^{
            if (image != nil) {
                self.ivPhoto.image = image;
            }
        });
    });
}

- (IBAction)touchPopular:(id)sender {
    [self.tabBarController setSelectedIndex:1];
}

- (IBAction)touchHome:(id)sender {
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)touchUser:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showFromRect:self.ivPhoto.frame inView:self.titleBarView animated:YES];
}

- (void)refresh { } // override for pull-to-refresh func.

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
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate logout];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (self.scrollView.contentOffset.x < 1) {
        CGRect bgFrame = self.ivBackground.frame;
        bgFrame.origin.x = -self.scrollView.contentOffset.x;
        self.ivBackground.frame = bgFrame;
        
        CGRect progressBgFrame = self.ivProgressBackground.frame;
        progressBgFrame.origin.x = (int)((self.view.frame.size.width/2.) - (progressBgFrame.size.width/2.)) - self.scrollView.contentOffset.x;
        self.ivProgressBackground.frame = progressBgFrame;

        CGRect activityFrame = self.activityIndicatorView.frame;
        activityFrame.origin.x = (int)((self.view.frame.size.width/2.) - (activityFrame.size.width/2.)) - self.scrollView.contentOffset.x;
        self.activityIndicatorView.frame = activityFrame;
    }
    
    if (self.scrollView.contentOffset.x <= kRefreshDrag) {
        self.ivRefreshIcon.layer.opacity = 1.0;
    } else {
        self.ivRefreshIcon.layer.opacity = 0.5;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.scrollView.contentOffset.x <= kRefreshDrag) {
        [self refresh];
    }
}

#pragma mark - MediaSelectorDelegate

- (void)didSelectMedia:(WFIGMedia *)media fromRect:(CGRect)rect
{   
    DetailsViewController *detailsVC = (DetailsViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"Details"];
    [detailsVC setMedia:media];
    detailsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    detailsVC.startRect = rect;
    [self presentModalViewController:detailsVC animated:YES];
}

@end
