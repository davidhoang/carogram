//
//  CRGPagingSlideViewController.m
//  Carogram
//
//  Created by Jacob Moore on 9/10/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGPagingSlideViewController.h"
#import "CRGSlideViewController.h"
#import <QuartzCore/QuartzCore.h>

#define PERIPHERAL_SCALE    .85
#define PERIPHERAL_ALPHA    .3
#define PERIPHERAL_Y_OFFSET -30.

static NSSet * ObservableKeys = nil;

static NSString * const MediaCollectionKeyPath = @"mediaCollection";

@interface CRGPagingSlideViewController ()
@property (nonatomic, strong) NSMutableArray *slideViewControllers;
- (void)configureView;
- (void)loadScrollViewWithPage:(int)page;
@end

@implementation CRGPagingSlideViewController {
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
            [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
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
    NSLog(@"<PSVC> didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (void) configureView
{
    // Remove old slideViewControllers if necessary
    for (CRGSlideViewController *slideController in self.slideViewControllers) {
        if ((NSNull*)slideController != [NSNull null] && [slideController.view superview]) {
            [slideController willMoveToParentViewController:nil];
            [slideController.view removeFromSuperview];
            [slideController removeFromParentViewController];
        }
    }

    pageCount = [self.mediaCollection count];
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < pageCount; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.slideViewControllers = controllers;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * pageCount, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
}

#pragma mark -

- (void)setCurrentPage:(int)page animated:(BOOL)animated
{
    [super setCurrentPage:page animated:animated];

    for (int i = 0; i < [self.slideViewControllers count]; i++) {
        CRGSlideViewController *slideController = self.slideViewControllers[i];

        if ((NSNull*)slideController != [NSNull null]) {
            if (i == [self currentPage]) {
                slideController.view.transform = CGAffineTransformIdentity;
                slideController.view.alpha = 1;
            } else {
                CGAffineTransform transform = CGAffineTransformMakeScale(PERIPHERAL_SCALE,
                                                                         PERIPHERAL_SCALE);
                transform = CGAffineTransformTranslate(transform, 0, PERIPHERAL_Y_OFFSET);
                slideController.view.transform = transform;

                slideController.view.alpha = PERIPHERAL_ALPHA;
            }
        }
    }
}

- (void)setPeripheryAlpha:(CGFloat)peripheryAlpha
{
    _peripheryAlpha = MAX(0., MIN(1., peripheryAlpha)) * PERIPHERAL_ALPHA;
    
    int currentPage = [self currentPage];
    for (int i = 0; i < [self.slideViewControllers count]; i++) {
        CRGSlideViewController *slideController = self.slideViewControllers[i];
        if ((NSNull*)slideController == [NSNull null]) continue;
        
        if (i == currentPage - 1 || i == currentPage + 1) {
            slideController.view.alpha = _peripheryAlpha;
        } else if (i != currentPage) {
            slideController.view.hidden = YES;
        }
    }
}

- (UIView *)currentSlideCell
{
    CRGSlideViewController *currentSlideController = self.slideViewControllers[[self currentPage]];
    if ((NSNull*)currentSlideController == [NSNull null]) return nil;
    
    return currentSlideController.mediaView;
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
    if (page < 0)
        return;
    if (page >= pageCount) {
        if ([self.mediaCollection hasNextPage] && [self.delegate respondsToSelector:@selector(loadMoreMedia)]) {
            [self.delegate loadMoreMedia];
        }
        return;
    }
    
    // replace the placeholder if necessary
    CRGSlideViewController *controller = [self.slideViewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = (CRGSlideViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"Slide"];
        WFIGMedia *media = [self.mediaCollection objectAtIndex:page];
        [controller setMedia:media];
        [controller setDelegate:self];
        [self.slideViewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = self.view.bounds.size.height/2. - controller.view.bounds.size.height/2.;        
        controller.view.frame = frame;

        if (page != [self currentPage]) {
            CGAffineTransform transform = CGAffineTransformMakeScale(PERIPHERAL_SCALE,
                                                                     PERIPHERAL_SCALE);
            transform = CGAffineTransformTranslate(transform, 0, PERIPHERAL_Y_OFFSET);
            controller.view.transform = transform;
            controller.view.alpha = PERIPHERAL_ALPHA;
        }

        [self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        [controller didMoveToParentViewController:self];
    }
}

- (void)mediaCollectionDidLoadNextPage:(NSNotification *)notification
{
    if (self.mediaCollection == [notification object]) {
        int oldPageCount = pageCount;
        pageCount = [self.mediaCollection count];
        
        // view controllers are created lazily
        // in the meantime, load the array with placeholders which will be replaced on demand
        NSMutableArray *controllers = [[NSMutableArray alloc] init];
        [controllers addObjectsFromArray:self.slideViewControllers];
        for (unsigned i = oldPageCount; i < pageCount; i++) {
            [controllers addObject:[NSNull null]];
        }
        self.slideViewControllers = controllers;
        
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
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

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
        CRGSlideViewController *previousPageController = self.slideViewControllers[previousPage];
        if ((NSNull*)previousPageController != [NSNull null]) {
            float adjustedOffsetPct = adjustedXOffset / pageWidth;

            float scale = 1. - (adjustedOffsetPct * (1. - PERIPHERAL_SCALE));
            CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
            float yOffset = adjustedOffsetPct * PERIPHERAL_Y_OFFSET;
            transform = CGAffineTransformTranslate(transform, 0, yOffset);
            previousPageController.view.transform = transform;

            float alpha = 1. - (adjustedOffsetPct * (1. - PERIPHERAL_ALPHA));
            previousPageController.view.alpha = alpha;
        }
    }

    if (nextPage > 0 && nextPage < pageCount) {
        CRGSlideViewController *nextPageController = self.slideViewControllers[nextPage];
        if ((NSNull*)nextPageController != [NSNull null]) {
            float adjustedOffsetPct = adjustedXOffset / pageWidth;

            float scale = adjustedOffsetPct * (1. - PERIPHERAL_SCALE) + PERIPHERAL_SCALE;
            CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
            float yOffset = PERIPHERAL_Y_OFFSET - adjustedOffsetPct * PERIPHERAL_Y_OFFSET;
            transform = CGAffineTransformTranslate(transform, 0, yOffset);
            nextPageController.view.transform = transform;

            float alpha = adjustedOffsetPct * (1. - PERIPHERAL_ALPHA ) + PERIPHERAL_ALPHA;
            nextPageController.view.alpha = alpha;
        }
    }
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    int currentPage = [self currentPage];
    for (int i = currentPage - 2; i <= currentPage + 2; i++) {
        if (i >= 0 && i < [self.mediaCollection count]) {
            CRGSlideViewController *slideController = self.slideViewControllers[i];
            if ([NSNull null] == (NSNull*)slideController) continue;
            slideController.view.hidden = NO;
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    int currentPage = [self currentPage];
    for (int i = 0; i < [self.slideViewControllers count]; i++) {
        if (i == currentPage) continue;
        
        CRGSlideViewController *slideController = self.slideViewControllers[i];
        if ([NSNull null] == (NSNull*)slideController) continue;
        
        CGAffineTransform transform = CGAffineTransformMakeScale(PERIPHERAL_SCALE,
                                                                 PERIPHERAL_SCALE);
        transform = CGAffineTransformTranslate(transform, 0, PERIPHERAL_Y_OFFSET);
        slideController.view.transform = transform;
        slideController.view.alpha = PERIPHERAL_ALPHA;
    }
}

#pragma mark - MediaSelectorDelegate

- (void)didSelectMedia:(WFIGMedia *)media fromRect:(CGRect)rect
{
    rect.origin.x += self.scrollView.frame.origin.x;
    rect.origin.y += self.scrollView.frame.origin.y;
    
    if (self.mediaSelectorDelegate && [self.mediaSelectorDelegate respondsToSelector:@selector(didSelectMedia:fromRect:)]) {
        [self.mediaSelectorDelegate didSelectMedia:media fromRect:rect];
    }
}

@end
