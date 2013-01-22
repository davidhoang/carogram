//
//  CRGLoginView.m
//  Carogram
//
//  Created by Jacob Moore on 8/24/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGLoginView.h"

@interface CRGLoginView ()

@end

@implementation CRGLoginView
@synthesize controller = _controller;

- (id) initWithController:(WFIGAuthController*)controller {
    if ((self = [self init])) {
        self.controller = controller;
        
        CGRect bgFrame = CGRectMake(0, 0, 1024, 748);
        UIImageView *ivBackground = [[UIImageView alloc] initWithFrame:bgFrame];
        [ivBackground setImage:[UIImage imageNamed:@"connect-background.jpg"]];
        [self addSubview:ivBackground];
        
        UIButton *btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnLogin setImage:[UIImage imageNamed:@"btn-connect"] forState:UIControlStateNormal];
        [btnLogin setFrame:CGRectMake(287, 336, 451, 76)];
        [btnLogin addTarget:self.controller
                     action:@selector(gotoInstagramAuthURL:)
           forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnLogin];
    }
    return self;
}

/*
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
*/

@end
