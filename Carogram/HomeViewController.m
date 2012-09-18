//
//  HomeViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/29/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "SlideViewController.h"
#import "DetailsViewController.h"

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableArray *mediaControllers;
@end

@implementation HomeViewController {
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

- (IBAction)touchHome:(id)sender {
    [super touchHome:sender];
    
    if (self.currentMediaController.currentPage > 0) {
        [self.currentMediaController scrollToFirstPage];
    } else {
        [self loadMediaCollection];
    }
}

@end
