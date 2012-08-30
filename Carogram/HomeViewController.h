//
//  HomeViewController.h
//  Carogram
//
//  Created by Jacob Moore on 8/29/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CGViewController.h"

@interface HomeViewController : CGViewController <UIScrollViewDelegate>

@property (strong, atomic) WFIGMediaCollection *mediaCollection;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) IBOutlet UIImageView *ivProgressBackground;

@end
