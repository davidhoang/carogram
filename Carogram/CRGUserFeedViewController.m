//
//  HomeViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/29/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGUserFeedViewController.h"
#import "CRGSlideViewController.h"
#import "WFIGUser.h"

@interface CRGUserFeedViewController ()
@end

@implementation CRGUserFeedViewController {
@private
    BOOL _isLoadingMoreMedia;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self CRGUserFeedViewController_commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self CRGUserFeedViewController_commonInit];
    }
    return self;
}

- (void)CRGUserFeedViewController_commonInit
{
    _isLoadingMoreMedia = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidChangeOutgoingStatus:)
                                                 name:WFIGUserDidChangeOutgoingStatusNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"<HomeVC> didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)userDidChangeOutgoingStatus:(NSNotification *)notification
{
    [self loadMediaCollection];
}

- (void)loadMediaCollection
{
    if (! self.currentUser || ! [self isViewLoaded]) return;

    [self setProgressViewShown:YES];
    self.currentPagingMediaController.view.hidden = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.mediaCollection = [[WFInstagramAPI currentUser] feedMediaWithError:NULL];

        dispatch_async( dispatch_get_main_queue(), ^{
            self.currentPagingMediaController.mediaCollection = self.mediaCollection;
            
            [self setProgressViewShown:NO];
            self.currentPagingMediaController.view.hidden = NO;
            
            if ([self.delegate respondsToSelector:@selector(mediaCollectionViewControllerDidLoadMediaCollection:)]) {
                [self.delegate mediaCollectionViewControllerDidLoadMediaCollection:self];
            }
        });
    });
}

- (void)loadMoreMedia
{
    @synchronized(self) {
        if (_isLoadingMoreMedia) return;
        _isLoadingMoreMedia = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.mediaCollection loadAndMergeNextPageWithError:NULL];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:MediaCollectionDidLoadNextPageNotification
                                                                object:self.mediaCollection];
            
            _isLoadingMoreMedia = NO;
        });
    });
}

@end

