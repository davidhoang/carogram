//
//  HomeViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/29/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGUserFeedViewController.h"
#import "CRGSlideViewController.h"

@interface CRGUserFeedViewController ()
@property (nonatomic, strong) NSMutableArray *mediaControllers;
@end

@implementation CRGUserFeedViewController {
@private
    int pageCount;
    BOOL isLoadingMoreMedia;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        isLoadingMoreMedia = NO;
    }
    return self;
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

- (void)loadMediaCollection
{
    if (self.currentUser == nil) return;

    [self setProgressViewShown:YES];
    self.currentMediaController.view.hidden = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.mediaCollection = [[WFInstagramAPI currentUser] feedMediaWithError:NULL];

        dispatch_async( dispatch_get_main_queue(), ^{
            self.currentMediaController.mediaCollection = self.mediaCollection;
            
            [self setProgressViewShown:NO];
            self.currentMediaController.view.hidden = NO;
            
            if ([self.delegate respondsToSelector:@selector(mediaViewControllerDidLoadMediaCollection:)]) {
                [self.delegate mediaViewControllerDidLoadMediaCollection:self];
            }
        });
    });
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
            [[NSNotificationCenter defaultCenter] postNotificationName:MediaCollectionDidLoadNextPageNotification
                                                                object:self.mediaCollection];
            
            isLoadingMoreMedia = NO;
        });
    });
}

@end

