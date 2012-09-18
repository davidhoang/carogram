//
//  PopularViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/21/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "PopularViewController.h"
#import "AppDelegate.h"
#import "DetailsViewController.h"

@interface PopularViewController ()
@end

@implementation PopularViewController

- (void)didReceiveMemoryWarning
{
    NSLog(@"<PopularVC> didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
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
