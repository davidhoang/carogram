//
//  CRGPagingMediaViewController.m
//  Carogram
//
//  Created by Jacob Moore on 9/10/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGPagingMediaViewController.h"

NSString * const MediaCollectionDidLoadNextPageNotification = @"MediaCollectionDidLoadNextPageNotification";

@interface CRGPagingMediaViewController ()

@end

@implementation CRGPagingMediaViewController
@synthesize delegate = _delegate;
@synthesize mediaSelectorDelegate = _mediaSelectorDelegate;
@synthesize mediaCollection = _mediaCollection;
@synthesize scrollView = _scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (int)currentPage
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    return floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
}

- (void)setCurrentPage:(int)page animated:(BOOL)animated
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    CGPoint offset = CGPointMake((float)page * pageWidth, self.scrollView.contentOffset.y);
    [self.scrollView setContentOffset:offset animated:animated];
}

- (void)scrollToFirstPage
{
    if (self.scrollView.contentOffset.x > 0) {
        [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
}

- (void)nextPageLoaded { } // 

@end
