//
//  AppDelegate.h
//  Carogram
//
//  Created by Adam McDonald on 8/3/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HomeViewController *homeViewController;

- (void)enterAuthFlowAnimated:(BOOL)animated;
- (void)logout;

@end
