//
//  CRGPopularMediaViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/21/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGPopularMediaViewController.h"
#import "CRGAppDelegate.h"
#import "CRGGridViewController.h"

@interface CRGPopularMediaViewController ()
@end

@implementation CRGPopularMediaViewController

- (void)didReceiveMemoryWarning
{
    NSLog(@"<PopularVC> didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (void) loadMediaCollection {
    if (self.currentUser == nil) return;
    
    [self setProgressViewShown:YES];
    self.currentPagingMediaController.view.hidden = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.mediaCollection = [WFIGMedia popularMediaWithLimit:kImageCount error:NULL];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            self.currentPagingMediaController.mediaCollection = self.mediaCollection;
            
            [self setProgressViewShown:NO];
            self.currentPagingMediaController.view.hidden = NO;
        });
    });
}

@end
