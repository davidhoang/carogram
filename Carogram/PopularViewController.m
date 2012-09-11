//
//  HomeViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/21/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "PopularViewController.h"
#import "AppDelegate.h"
#import "PagingGridViewController.h"

static NSSet * ObservableKeys = nil;

static NSString * const CurrentUserKeyPath = @"currentUser";

@interface PopularViewController ()
@property (strong, nonatomic) PagingGridViewController *pagingGridViewController;
@property (strong, nonatomic) PagingMediaViewController *currentMediaController;
- (void)loadMediaCollection;
@end

@implementation PopularViewController

@synthesize mediaCollection = _mediaCollection;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        if (nil == ObservableKeys) {
            ObservableKeys = [[NSSet alloc] initWithObjects:CurrentUserKeyPath, nil];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pagingGridViewController = (PagingGridViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"PagingGrid"];
    self.pagingGridViewController.pagingMediaScrollDelegate = self;
    
    CGRect pagingGridViewFrame = self.pagingGridViewController.view.frame;
    pagingGridViewFrame.origin.y = 50;
    self.pagingGridViewController.view.frame = pagingGridViewFrame;
    
    self.currentMediaController = self.pagingGridViewController;
    [self.view addSubview:self.pagingGridViewController.view];
    
    for (NSString *keyPath in ObservableKeys) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    
    [self loadMediaCollection];
}

- (void)viewDidUnload
{
    for (NSString *keyPath in ObservableKeys) {
        [self removeObserver:self forKeyPath:keyPath context:nil];
    }
    
    [super viewDidUnload];
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

- (void)refresh
{
    [self loadMediaCollection];
}

- (void) loadMediaCollection {
    if (self.currentUser == nil) return;
    
    [self setProgressViewShown:YES];
    self.scrollView.hidden = YES;
    self.currentMediaController.view.hidden = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.mediaCollection = [WFIGMedia popularMediaWithError:NULL];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            self.currentMediaController.mediaCollection = self.mediaCollection;
            
            [self setProgressViewShown:NO];
            self.currentMediaController.view.hidden = NO;
        });
    });
}

- (IBAction)touchPopular:(id)sender {
    [super touchPopular:sender];
    
    if (self.currentMediaController.currentPage > 0) {
        [self.currentMediaController scrollToFirstPage];
    } else {
        [self loadMediaCollection];
    }
}

@end
