//
//  CRGOnboardViewController.m
//  Carogram
//
//  Created by Jacob Moore on 3/4/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGOnboardViewController.h"
#import "SMPageControl.h"

//static NSUInteger kNumberOfPages = 6;
static NSUInteger kNumberOfPages = 5;

@interface CRGOnboardViewController ()
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *onboardViews;
@property (strong, nonatomic) SMPageControl *pageControl;
@end

@implementation CRGOnboardViewController {
    BOOL _pageControlUsed;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.onboardViews = [NSMutableArray new];
    for (int i = 0; i < kNumberOfPages; i++) {
        [self.onboardViews addObject:[NSNull null]];
    }
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * kNumberOfPages, self.scrollView.frame.size.height);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageControl = [[SMPageControl alloc] init];
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    self.pageControl.pageIndicatorImage = [UIImage imageNamed:@"page-indicator"];
    self.pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"current-page-indicator"];
    self.pageControl.numberOfPages = kNumberOfPages;
    self.pageControl.currentPage = 0;
    [self.pageControl sizeToFit];
    
    CGRect pageControlFrame = self.pageControl.frame;
    pageControlFrame.origin.x = 512. - pageControlFrame.size.width/2.;
    pageControlFrame.origin.y = 691. - pageControlFrame.size.height/2.;
    self.pageControl.frame = pageControlFrame;
    
    [self.view addSubview:self.pageControl];
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)getStarted:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (UIView *)lastPageView
{
    CGRect pageFrame = CGRectMake(0, 0, 1024., 768.);
    UIView *lastPageView = [[UIView alloc] initWithFrame:pageFrame];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:pageFrame];
//    NSString *imageName = [NSString stringWithFormat:@"onboard-%d.jpg", (kNumberOfPages-1)];
    NSString *imageName = [NSString stringWithFormat:@"onboard-%d.jpg", 5];
    imageView.image = [UIImage imageNamed:imageName];
    [lastPageView addSubview:imageView];
    
    CGRect buttonFrame = CGRectMake(357, 553, 310, 76);
    UIButton *getStartedButton = [[UIButton alloc] initWithFrame:buttonFrame];
    [getStartedButton setImage:[UIImage imageNamed:@"btn-get-started"] forState:UIControlStateNormal];
    [getStartedButton addTarget:self action:@selector(getStarted:) forControlEvents:UIControlEventTouchUpInside];
    [lastPageView addSubview:getStartedButton];
    
    return lastPageView;
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0) return;
    if (page >= kNumberOfPages) return;
    
    // replace the placeholder if necessary
    UIView *onboardView = self.onboardViews[page];
    if ((NSNull*)onboardView == [NSNull null]) {
        if (page == kNumberOfPages-1) {
            onboardView = [self lastPageView];
        } else {
            onboardView = [[UIImageView alloc] init];
            NSString *imageName = [NSString stringWithFormat:@"onboard-%d.jpg", page];
            ((UIImageView*)onboardView).image = [UIImage imageNamed:imageName];
            self.onboardViews[page] = onboardView;
        }
    }
    
    // add the controller's view to the scroll view
    if (onboardView.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        onboardView.frame = frame;
        [self.scrollView addSubview:onboardView];
    }    
}

- (IBAction)changePage:(id)sender
{
    int page = self.pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    _pageControlUsed = YES;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (_pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }

    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // if we are dragging, we want to update the page control directly during the drag
    if (self.scrollView.dragging) {
        [self.pageControl updateCurrentPageDisplay];
    }
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _pageControlUsed = NO;
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)aScrollView
{
	// if we are animating (triggered by clicking on the page control), we update the page control
	[self.pageControl updateCurrentPageDisplay];
}

@end
