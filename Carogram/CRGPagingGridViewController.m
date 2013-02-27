//
//  CRGPagingGridViewController.m
//  Carogram
//
//  Created by Jacob Moore on 9/10/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGPagingGridViewController.h"
#import "CRGGridViewController.h"

static NSSet * ObservableKeys = nil;

static NSString * const MediaCollectionKeyPath = @"mediaCollection";

@interface CRGPagingGridViewController ()
@property (nonatomic, strong) NSMutableArray *gridViewControllers;
- (void)configureView;
- (void)loadScrollViewWithPage:(int)page;
- (void)loadMoreMedia;
@end

@implementation CRGPagingGridViewController {
@private
    int pageCount;
    BOOL zoomRecognized_;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        zoomRecognized_ = NO;
        if (nil == ObservableKeys) {
            ObservableKeys = [[NSSet alloc] initWithObjects:MediaCollectionKeyPath, nil];
        }
        for (NSString *keyPath in ObservableKeys) {
            [self addObserver:self
                   forKeyPath:keyPath
                      options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                      context:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(mediaCollectionDidLoadNextPage:)
                                                     name:MediaCollectionDidLoadNextPageNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    for (NSString *keyPath in ObservableKeys) {
        [self removeObserver:self forKeyPath:keyPath context:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View management

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self.mediaCollection count] > 0) {
        [self configureView];
    }
    
    UIPinchGestureRecognizer *pinchRecognizer =
        [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchRecognizer];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"<PGVC> didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (void) configureView
{
    pageCount = pageCount = ceil((double)[self.mediaCollection count] / (double)kImageCount);
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < pageCount; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.gridViewControllers = controllers;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * pageCount, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    self.scrollView.alwaysBounceHorizontal = YES;
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
    // Load more media if we don't have 2 full pages
    if (2*kImageCount > [self.mediaCollection count]) [self loadMoreMedia];
}

#pragma mark -

- (void)handlePinch:(UIPinchGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            zoomRecognized_ = NO;
        case UIGestureRecognizerStateChanged: {
            CGFloat scale = [recognizer scale];
            if (scale < 1) scale = powf(scale, .2);
            self.view.transform = CGAffineTransformMakeScale(scale, scale);
            
            if (scale >= 1.5 && !zoomRecognized_) {
                zoomRecognized_ = YES;
                CGPoint firstPt = [recognizer locationOfTouch:0 inView:self.view];
                CGPoint secondPt = [recognizer locationOfTouch:1 inView:self.view];
                CGPoint midPt = CGPointMake((firstPt.x + secondPt.x) / 2.,
                                            (firstPt.y + secondPt.y) / 2.);
                [self zoomInFromPoint:midPt];
            }
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed: {
            [UIView animateWithDuration:.2 animations:^{
                self.view.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
            }];
        }
        default: break;
    }
}

- (void)zoomInFromPoint:(CGPoint)point
{
    CRGGridViewController *currentGridViewController = self.gridViewControllers[self.currentPage];
    int pageIndex = [currentGridViewController indexOfMediaAtPoint:point];
    int mediaIndex = self.currentPage * kImageCount + pageIndex;
    
    if ([self.delegate respondsToSelector:@selector(pagingMediaViewController:didZoomInAtIndex:)])
    {
        [self.delegate pagingMediaViewController:self didZoomInAtIndex:mediaIndex];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [ObservableKeys containsObject:keyPath]) {
        if ([keyPath isEqualToString:MediaCollectionKeyPath]) {
            if ([self isViewLoaded]) [self configureView];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0) return;
    if (page >= pageCount) return;
    
    // replace the placeholder if necessary
    CRGGridViewController * controller = [self.gridViewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[CRGGridViewController alloc] initWithMediaCollection:self.mediaCollection atPage:page];
        [controller setDelegate:self.mediaSelectorDelegate];
        [self.gridViewControllers replaceObjectAtIndex:page withObject:controller];
    } else {
        if (((page+1)*kImageCount) <= [self.mediaCollection count] && ![controller isGridFull]) {
            if (controller.view.superview != nil) {
                [controller willMoveToParentViewController:nil];
                [controller.view removeFromSuperview];
                [controller removeFromParentViewController];
            }
            controller = [[CRGGridViewController alloc] initWithMediaCollection:self.mediaCollection atPage:page];
            [controller setDelegate:self.mediaSelectorDelegate];
            [self.gridViewControllers replaceObjectAtIndex:page withObject:controller];
        }
    }
    
    if (page <= [self currentPage]) {
        controller.view.frame = CGRectOffset(self.scrollView.frame,
                                             -self.scrollView.frame.origin.x + (self.scrollView.bounds.size.width * page),
                                             -self.scrollView.frame.origin.y);
        controller.view.alpha = 1;
    } else {
        
        controller.view.frame = CGRectOffset(self.scrollView.frame,
                                             -self.scrollView.frame.origin.x + self.scrollView.bounds.size.width * (page-1),
                                             -self.scrollView.frame.origin.y);
        controller.view.alpha = 0;
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}

- (void)loadMoreMedia
{
    if ([self.mediaCollection hasNextPage] && [self.delegate respondsToSelector:@selector(loadMoreMedia)]) {
        [self.delegate loadMoreMedia];
    }    
}

- (void)mediaCollectionDidLoadNextPage:(NSNotification *)notification
{
    if (self.mediaCollection == [notification object]) {
        int oldPageCount = pageCount;
        pageCount = pageCount = ceil((double)[self.mediaCollection count] / (double)kImageCount);

        NSMutableArray *controllers = [[NSMutableArray alloc] init];
        [controllers addObjectsFromArray:self.gridViewControllers];
        for (unsigned i = oldPageCount; i < pageCount; i++) {
            [controllers addObject:[NSNull null]];
        }
        self.gridViewControllers = controllers;

        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * pageCount, self.scrollView.frame.size.height);
        
        int currentPage = [self currentPage];
        [self loadScrollViewWithPage:currentPage - 1];
        [self loadScrollViewWithPage:currentPage];
        [self loadScrollViewWithPage:currentPage + 1];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    float xOffset = self.scrollView.contentOffset.x;
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((xOffset - pageWidth / 2) / pageWidth) + 1;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];

    int previousPage;
    int nextPage;
    float adjustedXOffset;
    if (xOffset < (page * pageWidth)) {
        previousPage = page - 1;
        nextPage = page;
        adjustedXOffset = xOffset - (previousPage * pageWidth);
    } else {
        previousPage = page;
        nextPage = page + 1;
        adjustedXOffset = xOffset - (previousPage * pageWidth);
    }

    if (previousPage >= 0) {
        CRGGridViewController *previousGridVC = self.gridViewControllers[previousPage];
        previousGridVC.view.frame = CGRectOffset(self.scrollView.frame,
                                                 -self.scrollView.frame.origin.x + (pageWidth * previousPage),
                                                 -self.scrollView.frame.origin.y);
        previousGridVC.view.alpha = 1;
        [self.scrollView bringSubviewToFront:previousGridVC.view];
    }

    if (nextPage == 0) {
        CRGGridViewController *nextGridVC = self.gridViewControllers[nextPage];
        nextGridVC.view.alpha = 1;
        nextGridVC.view.frame = CGRectOffset(self.scrollView.frame,
                                             -self.scrollView.frame.origin.x + (pageWidth * nextPage),
                                             -self.scrollView.frame.origin.y);
    } else if (nextPage < pageCount) {
        CRGGridViewController *nextGridVC = self.gridViewControllers[nextPage];
        nextGridVC.view.alpha = (adjustedXOffset / pageWidth);
        nextGridVC.view.alpha = pow((adjustedXOffset / pageWidth), 3.);
        nextGridVC.view.frame = CGRectOffset(self.scrollView.frame,
                                             -self.scrollView.frame.origin.x + (pageWidth * previousPage) + adjustedXOffset,
                                             -self.scrollView.frame.origin.y);
    }
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:sender];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self currentPage] >= ([self.gridViewControllers count] - 2)) [self loadMoreMedia];
}

@end
