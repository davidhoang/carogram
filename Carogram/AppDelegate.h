//
//  AppDelegate.h
//  Carogram
//
//  Created by Adam McDonald on 8/3/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern  NSString* const kCurrentUserKeyPath;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) WFIGUser *currentUser;

- (void)enterAuthFlowAnimated:(BOOL)animated;
- (void)logout;

@end
