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
#import "CRGOnboardViewController.h"
#import "CRGProfileViewController.h"
#import "PVInnerShadowLabel.h"
#import "SDWebImageManager.h"

#define USER_FEED_INDEX     0
#define POPULAR_MEDIA_INDEX 1
#define TAG_SEARCH_INDEX    2

#define APP_ID 608609685

static int currentUserObserverContext;

@interface CRGMainViewController ()
@property (strong, nonatomic) IBOutlet UIView *titleBarView;
@property (strong, nonatomic) IBOutlet UIImageView *searchBackgroundView;
@property (nonatomic) CGRect contentFrame;
@property (strong, nonatomic) NSMutableArray *viewControllers;
@property (nonatomic) int currentViewControllerIndex;
@property (strong, nonatomic) CRGMediaCollectionViewController *currentViewController;
@property (strong, nonatomic) IBOutlet UIButton *popularMediaButton;
@property (strong, nonatomic) IBOutlet UIButton *userFeedButton;
@property (strong, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic, strong) CRGSplashProgressView *splashView;
@property (strong, nonatomic) CRGOnboardViewController *onboardController;
@property (strong, nonatomic) CRGPopoverView *settingsPopoverView;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UIButton *clearSearchButton;
@property (strong, nonatomic) IBOutlet UIView *titleBarBackground;
@property (strong, nonatomic) IBOutlet PVInnerShadowLabel *titleLabel;
@property (strong, nonatomic) UIButton *closeSearchTitleBarButton;
@property (strong, nonatomic) UIButton *closeSearchContentButton;
@property (strong, nonatomic) IBOutlet UIButton *accountButton;
@end

@implementation CRGMainViewController {
    BOOL _showSplashViewOnViewLoad;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self CRGMainViewController_commonInit];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) [self CRGMainViewController_commonInit];
    return self;
}

- (void)CRGMainViewController_commonInit
{
    _currentViewControllerIndex = -1;
    _showSplashViewOnViewLoad = NO;
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [self setTitleBarView:nil];
    [self setPopularMediaButton:nil];
    [self setUserFeedButton:nil];
    [self setSearchTextField:nil];
    [self setSettingsButton:nil];
    [self setSearchButton:nil];
    [self setClearSearchButton:nil];
    [self setTitleBarBackground:nil];
    [self setTitleLabel:nil];
    [self setAccountButton:nil];
    [super viewDidUnload];
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
    
    self.titleLabel.innerShadowColor = [UIColor colorWithWhite:0 alpha:.75];
    self.titleLabel.innerShadowOffset = CGSizeMake(0, .8);
    self.titleLabel.innerShadowSize = 1.2;
    
    UIImage *patternImage = [UIImage imageNamed:@"title-bar-bg-tile"];
    self.titleBarBackground.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    
    // Add shadow to title bar
    self.titleBarBackground.layer.shadowOffset = CGSizeMake(0, 3);
    self.titleBarBackground.layer.shadowRadius = 4;
    self.titleBarBackground.layer.shadowColor = [UIColor blackColor].CGColor;
    self.titleBarBackground.layer.shadowOpacity = .5;
    self.titleBarBackground.layer.masksToBounds = NO;
    
    self.searchBackgroundView.image =
    [[UIImage imageNamed:@"search-bg"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    
    self.searchTextField.font = [UIFont fontWithName:@"Gotham-Medium" size:14.];
    
    // Add rounded border layer
    CALayer *roundedLayer = [CALayer layer];
    roundedLayer.frame = CGRectInset(self.accountButton.bounds, -1, -1);
    roundedLayer.opaque = YES;
    roundedLayer.masksToBounds = NO;
    roundedLayer.borderWidth = 1;
    roundedLayer.borderColor = [[UIColor colorWithRed:(85.0/255.0)
                                                green:(78.0/255.0)
                                                 blue:(59.0/255.0)
                                                alpha:1.0] CGColor];
    
    [self.accountButton.layer addSublayer:roundedLayer];
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
    CRGUserFeedViewController *userFeedController = self.viewControllers[USER_FEED_INDEX];
    if (USER_FEED_INDEX == self.currentViewControllerIndex && (NSNull*)userFeedController != [NSNull null]) {
        [userFeedController scrollToFirstPage];
        return;
    }
    
    self.currentViewControllerIndex = USER_FEED_INDEX;

    [self.userFeedButton setImage:[UIImage imageNamed:@"btn-user-feed-depressed"] forState:UIControlStateNormal];
    [self.popularMediaButton setImage:[UIImage imageNamed:@"btn-popular-media"] forState:UIControlStateNormal];
    
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
    CRGPopularMediaViewController *popularMediaController = self.viewControllers[POPULAR_MEDIA_INDEX];
    if (POPULAR_MEDIA_INDEX == self.currentViewControllerIndex && (NSNull*)popularMediaController != [NSNull null]) {
        [popularMediaController scrollToFirstPage];
        return;
    }
    
    self.currentViewControllerIndex = POPULAR_MEDIA_INDEX;
    
    [self.popularMediaButton setImage:[UIImage imageNamed:@"btn-popular-media-depressed"] forState:UIControlStateNormal];
    [self.userFeedButton setImage:[UIImage imageNamed:@"btn-user-feed"] forState:UIControlStateNormal];
    
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
    
    self.clearSearchButton.hidden = NO;
    self.searchButton.hidden = YES;
    
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

- (IBAction)showSettingsPopover:(UIButton *)sender {
    if (! self.settingsPopoverView) {
        NSArray *items = @[@"Contact Us", @"Gift Carogram", @"Rate Carogram", @"View Tutorial", @"Sign Out"];
        self.settingsPopoverView = [[CRGPopoverView alloc] initWithItems:items
                                                                fromRect:self.settingsButton.frame
                                                                   width:340.];
        self.settingsPopoverView.delegate = self;
    }
    [self.settingsPopoverView show];
}

- (IBAction)clearSearch:(UIButton *)sender {
    [self.searchTextField becomeFirstResponder];
    self.searchTextField.text = @"";
    self.searchButton.hidden = NO;
    self.clearSearchButton.hidden = YES;
}

- (IBAction)touchSettings:(UIButton *)sender {
    self.settingsButton.selected = YES;
}

- (void)closeSearch:(id)sender
{
    [self.searchTextField resignFirstResponder];
}

- (IBAction)viewProfile:(id)sender {
    CRGProfileViewController *profileVC = (CRGProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"Profile"];
    profileVC.user = self.currentUser;
    
    [self.navigationController pushViewController:profileVC animated:YES];
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
        if ([self isViewLoaded]) [self loadProfilePicture];
    }  else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -

- (void)showOnboardingViewAnimated:(BOOL)animated
{
    CRGOnboardViewController *vc = (CRGOnboardViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"Onboard"];
    [self presentModalViewController:vc animated:animated];
}

- (void)loadProfilePicture
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:[NSURL URLWithString:[self.currentUser profilePicture]] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        if (image) {
            [self.accountButton setBackgroundImage:image forState:UIControlStateNormal];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ViewProfile"]) {
        CRGProfileViewController *profileController = [segue destinationViewController];
        profileController.user = [WFInstagramAPI currentUser];
    }
}

#pragma mark - CRGMediaCollectionViewControllerDelegate methods

- (void)mediaCollectionViewControllerDidLoadMediaCollection:(CRGMediaCollectionViewController *)mediaCollectionViewController
{
    if ([self.splashView superview] != nil) {
        [UIView animateWithDuration:0.3 animations:^{
            self.splashView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.splashView removeFromSuperview];
            self.splashView = nil;
        }];
    }
}

#pragma mark - CRGOnboardViewControllerDelegate methods

- (void)onboardViewControllerDidFinish:(CRGOnboardViewController *)onboardViewController
{
    [self.onboardController willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.onboardController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.onboardController.view removeFromSuperview];
        [self.onboardController removeFromParentViewController];
        self.onboardController = nil;
    }];
}

#pragma mark - CRGPopoverViewDelegate methods

- (void)popoverView:(CRGPopoverView *)popoverView didDismissWithItemIndex:(int)index
{
    self.settingsButton.selected = NO;
    
    if (0 == index) { // "Contact Us"
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setToRecipients:[NSArray arrayWithObjects:@"carogram@xhatch.com", nil]];
        [self presentModalViewController:picker animated:YES];
    } else if (1 == index) { // "Gift Carogram"
        NSString *giftAppURL = [NSString stringWithFormat:@"itms-appss://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=%d&productType=C&pricingParameter=STDQ&mt=8&ign-mscache=1", APP_ID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:giftAppURL]];
    } else if (2 == index) { // "Rate Carogram"
        NSString *rateAppURL = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", APP_ID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:rateAppURL]];
    } else if (3 == index) { // "View Tutorial"
        [self showOnboardingViewAnimated:YES];
    } else if (4 == index) { // "Sign Out"
        [self.accountButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.currentViewController didLogout];
        CRGAppDelegate *appDelegate = (CRGAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate logout];
    }
}

- (void)popoverViewDidCancel:(CRGPopoverView *)popoverView
{
    self.settingsButton.selected = NO;
}

#pragma mark - MailComposer Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (! self.closeSearchTitleBarButton) {
        self.closeSearchTitleBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeSearchTitleBarButton.frame = self.titleBarView.bounds;
        self.closeSearchTitleBarButton.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
        [self.closeSearchTitleBarButton addTarget:self action:@selector(closeSearch:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.closeSearchTitleBarButton.alpha = 0;
    [self.titleBarView insertSubview:self.closeSearchTitleBarButton belowSubview:self.searchBackgroundView];
    
    if (! self.closeSearchContentButton) {
        self.closeSearchContentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.closeSearchContentButton.frame = self.contentFrame;
        self.closeSearchContentButton.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
        [self.closeSearchContentButton addTarget:self action:@selector(closeSearch:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.closeSearchContentButton.alpha = 0;
    [self.view addSubview:self.closeSearchContentButton];

    CGFloat duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.closeSearchTitleBarButton.alpha = 1;
        self.closeSearchContentButton.alpha = 1;
    }];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    CGFloat duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        self.closeSearchTitleBarButton.alpha = 0;
        self.closeSearchContentButton.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.closeSearchTitleBarButton.superview) {
            [self.closeSearchTitleBarButton removeFromSuperview];
        }
        if (self.closeSearchContentButton.superview) {
            [self.closeSearchContentButton removeFromSuperview];
        }
    }];
}

@end

