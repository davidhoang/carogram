//
//  CRGTagSearchViewController.m
//  Carogram
//
//  Created by Jacob Moore on 1/21/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGTagSearchViewController.h"

@interface CRGTagSearchViewController ()
@property (nonatomic, strong) NSMutableArray *mediaControllers;
@end

@implementation CRGTagSearchViewController {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchTag = @"snow";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadMediaCollection {
    if (self.currentUser == nil) return;
    
    [self setProgressViewShown:YES];
    self.scrollView.hidden = YES;
    self.currentMediaController.view.hidden = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.mediaCollection = [WFIGMedia mediaWithTag:self.searchTag error:NULL];
        
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

@end
