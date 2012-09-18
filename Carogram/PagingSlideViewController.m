//
//  PagingSlideViewController.m
//  Carogram
//
//  Created by Jacob Moore on 9/10/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "PagingSlideViewController.h"
#import "DetailsViewController.h"
#import "SlideViewController.h"

static NSSet * ObservableKeys = nil;

static NSString * const MediaCollectionKeyPath = @"mediaCollection";

@interface PagingSlideViewController ()
@property (nonatomic, strong) NSMutableArray *slideViewControllers;
- (void)configureView;
- (void)loadScrollViewWithPage:(int)page;
@end

@implementation PagingSlideViewController {
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
        if ([self.mediaCollection hasNextPage] && self.delegate != nil && [self.delegate respondsToSelector:@selector(loadMoreMedia)]) {
            [self.delegate loadMoreMedia];
        }
        return;
    }
    
    // replace the placeholder if necessary
    SlideViewController *controller = [self.slideViewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = (SlideViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"Slide"];
        WFIGMedia *media = [self.mediaCollection objectAtIndex:page];
        [controller setMedia:media];
        [controller setDelegate:self];
        [self.slideViewControllers replaceObjectAtIndex:page withObject:controller];
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
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
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
