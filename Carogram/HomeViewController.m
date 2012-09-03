//
//  HomeViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/29/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "UserFeedMediaController.h"

static NSSet * ObservableKeys = nil;

static NSString * const CurrentUserKeyPath = @"currentUser";

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableArray *mediaControllers;
- (void) loadMediaCollection;
- (void)loadScrollViewWithPage:(int)page;
- (void)loadMoreMedia;
@end

@implementation HomeViewController {
@private
    int pageCount;
    BOOL isLoadingMoreMedia;
}

@synthesize mediaControllers = _mediaControllers;
@synthesize mediaCollection = _mediaCollection;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        isLoadingMoreMedia = NO;
        if (nil == ObservableKeys) {
            ObservableKeys = [[NSSet alloc] initWithObjects:CurrentUserKeyPath, nil];
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
    
    [self loadMediaCollection];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    for (NSString *keyPath in ObservableKeys) {
        [self removeObserver:self forKeyPath:keyPath context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [ObservableKeys containsObject:keyPath]) {
        if ([keyPath isEqualToString:CurrentUserKeyPath]) {
            [self loadMediaCollection];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)loadMediaCollection
{
    if (self.currentUser == nil) return;

    self.scrollView.hidden = YES;
    [self setProgressViewShown:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.mediaCollection = [[WFInstagramAPI currentUser] feedMediaWithError:NULL];

        dispatch_async( dispatch_get_main_queue(), ^{
            if ([self.mediaCollection count] == 0) return;
                
            pageCount = [self.mediaCollection count];
            
            // view controllers are created lazily
            // in the meantime, load the array with placeholders which will be replaced on demand
            NSMutableArray *controllers = [[NSMutableArray alloc] init];
            for (unsigned i = 0; i < pageCount; i++) {
                [controllers addObject:[NSNull null]];
            }
            self.mediaControllers = controllers;
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * pageCount, self.scrollView.frame.size.height);
            self.scrollView.contentOffset = CGPointMake(0, 0);

            [self setProgressViewShown:NO];
            self.scrollView.hidden = NO;
            
            [self loadScrollViewWithPage:0];
            [self loadScrollViewWithPage:1];
        });
    });
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= pageCount) {
        if ([self.mediaCollection hasNextPage] && !isLoadingMoreMedia) {
            [self loadMoreMedia];
        }
        return;
    }
    
    // replace the placeholder if necessary
    UserFeedMediaController *controller = [self.mediaControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = (UserFeedMediaController *)[self.storyboard instantiateViewControllerWithIdentifier: @"UserFeedMedia"];
        WFIGMedia *media = [self.mediaCollection objectAtIndex:page];
        [controller setMedia:media];
        [self.mediaControllers replaceObjectAtIndex:page withObject:controller];
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

- (void)loadMoreMedia
{
    @synchronized(self) {
        if (isLoadingMoreMedia) return;
        isLoadingMoreMedia = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.mediaCollection loadAndMergeNextPageWithError:NULL];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            int oldPageCount = pageCount;
            pageCount = [self.mediaCollection count];

            NSMutableArray *controllers = [[NSMutableArray alloc] init];
            [controllers addObjectsFromArray:self.mediaControllers];
            for (unsigned i = oldPageCount; i < pageCount; i++) {
                [controllers addObject:[NSNull null]];
            }
            
            self.mediaControllers = controllers;
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * pageCount, self.scrollView.frame.size.height);
            
            isLoadingMoreMedia = NO;
            
            [self loadScrollViewWithPage:oldPageCount];
        });
    });
}

- (void)refresh
{
    [self loadMediaCollection];
}

- (IBAction)touchHome:(id)sender {
    [super touchHome:sender];
    if (self.scrollView.contentOffset.x > 0) {
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    } else {
        [self loadMediaCollection];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    [super scrollViewDidScroll:sender];
       
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}

@end
