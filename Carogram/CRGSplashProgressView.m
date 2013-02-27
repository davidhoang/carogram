//
//  CRGSplashProgressView.m
//  Carogram
//
//  Created by Jacob Moore on 2/26/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGSplashProgressView.h"

@implementation CRGSplashProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [UIImage imageNamed:@"Default-Landscape"];
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect indicatorFrame = activityIndicator.frame;
        indicatorFrame.origin.x = self.frame.size.width/2. - indicatorFrame.size.width/2.;
        indicatorFrame.origin.y = 590.;
        activityIndicator.frame = indicatorFrame;
        activityIndicator.color = [UIColor colorWithWhite:.25 alpha:1];
        [self addSubview:activityIndicator];
        
        [activityIndicator startAnimating];
    }
    return self;
}

@end
