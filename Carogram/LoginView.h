//
//  LoginView.h
//  Carogram
//
//  Created by Jacob Moore on 8/24/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFIGAuthDefaultInitialView.h"

@class WFIGAuthController;

//@protocol WFIGAuthInitialView;
//- (id) initWithController:(WFIGAuthController*)controller;
//@end

@interface LoginView : UIView <WFIGAuthInitialView>

@property (strong, nonatomic) WFIGAuthController *controller;

@end
