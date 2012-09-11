//
//  PagingGridViewController.m
//  Carogram
//
//  Created by Jacob Moore on 9/10/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "PagingGridViewController.h"
#import "GridViewController.h"
#import "DetailsViewController.h"

static NSSet * ObservableKeys = nil;

static NSString * const MediaCollectionKeyPath = @"mediaCollection";

@interface PagingGridViewController ()
@property (nonatomic, strong) NSMutableArray *gridViewControllers;
- (void)loadScrollViewWithPage:(int)page;
@end

@implementation PagingGridViewController {
@private
    int pageCount;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        if (nil == ObservableKeys) {
            ObservableKeys = [[NSSet alloc] initWithObjects:MediaCollectionKeyPath, nil];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    for (NSString *keyPath in ObservableKeys) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)viewDidUnload
{
    for (NSString *keyPath in ObservableKeys) {
        [self removeObserver:self forKeyPath:keyPath context:nil];
    }
    
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [ObservableKeys containsObject:keyPath]) {
        if ([keyPath isEqualToString:MediaCollectionKeyPath]) {
            if ([self.mediaCollection count] > 0) {
                pageCount = ceil((double)[self.mediaCollection count] / (double)kImageCount);
                
                // view controllers are created lazily
                // in the meantime, load the array with placeholders which will be replaced on demand
                NSMutableArray *controllers = [[NSMutableArray alloc] init];
                for (unsigned i = 0; i < pageCount; i++) {
                    [controllers addObject:[NSNull null]];
                }
                self.gridViewControllers = controllers;
                
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * pageCount, self.scrollView.frame.size.height);
                self.scrollView.contentOffset = CGPointMake(0, 0);
                
                self.scrollView.hidden = NO;
                
                [self loadScrollViewWithPage:0];
                [self loadScrollViewWithPage:1];
            }
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
        if ([self.mediaCollection hasNextPage] && self.mediaCollectionDelegate != nil && [self.mediaCollectionDelegate respondsToSelector:@selector(loadMoreMedia)]) {
            [self.mediaCollectionDelegate loadMoreMedia];
        }
        return;
    }
    
    // replace the placeholder if necessary
    GridViewController * controller = [self.gridViewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[GridViewController alloc] initWithMediaCollection:self.mediaCollection atPage:page];
        [controller setDelegate:self];
        [self.gridViewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    if (self.pagingMediaScrollDelegate != nil && [self.pagingMediaScrollDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.pagingMediaScrollDelegate scrollViewDidScroll:sender];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.pagingMediaScrollDelegate != nil && [self.pagingMediaScrollDelegate respondsToSelector:@selector(scrollViewDidEndDragging:)]) {
        [self.pagingMediaScrollDelegate scrollViewDidEndDragging:scrollView];
    }
}

#pragma mark - MediaSelectorDelegate

- (void)didSelectMedia:(WFIGMedia *)media fromRect:(CGRect)rect
{
    rect.origin.y += (self.scrollView.frame.origin.y + 20); // 20 = status bar height
    DetailsViewController *detailsVC = (DetailsViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"Details"];
    [detailsVC setMedia:media];
    detailsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    detailsVC.startRect = rect;
    [self presentModalViewController:detailsVC animated:YES];
}

@end
