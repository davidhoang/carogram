//
//  AppDelegate.m
//  Carogram
//
//  Created by Adam McDonald on 8/3/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "WFInstagramAPI.h"
#import "NSURL+WillFleming.h"
#import "CGAuthController.h"
#import "LoginView.h"

#define APP_ID @"f4d2dcb4d1b3422a99344b1b10fad732"

NSString * const kDefaultsUserToken = @"user_token";
NSString * const kOAuthCallbackURL = @"egwfapi://auth";

@interface AppDelegate ()
@property (strong, nonatomic) UIWindow *authWindow;
@end

@implementation AppDelegate
@synthesize authWindow = _authWindow;
@synthesize homeViewController = _homeViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *config = [[NSBundle mainBundle] pathForResource:@"APIClient" ofType:@"plist"];
    if (nil == config) {
        [[NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:@"No client configuration plist found! Did you read the README?"
                               userInfo:nil] raise];
    }
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:config];
    [WFInstagramAPI setClientId:[plist objectForKey:@"id"]];
    [WFInstagramAPI setClientSecret:[plist objectForKey:@"secret"]];
    [WFInstagramAPI setClientScope:@"likes+relationships+comments"];
    [WFInstagramAPI setOAuthRedirectURL:kOAuthCallbackURL];
    /*
    [WFIGConnection setGlobalErrorHandler:^(WFIGResponse* response) {
        void (^logicBlock)(WFIGResponse*) = ^(WFIGResponse *response){
            switch ([response error].code) {
                case WFIGErrorOAuthException:
                    [WFInstagramAPI enterAuthFlow];
                    break;
                default: {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:[[response error] localizedDescription]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                } break;
            }
        };
        // needs to be run on main thread because of UI changes. So we decide where to run & then run it.
        if ([NSThread isMainThread]) {
            logicBlock(response);
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                logicBlock(response);
            });
        }
    }];
    */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:kDefaultsUserToken];
    NSLog(@"token: {%@}", token);
    [WFInstagramAPI setAccessToken:[defaults objectForKey:kDefaultsUserToken]];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (!([WFInstagramAPI accessToken] && [WFInstagramAPI currentUser])) {
        [self enterAuthFlowAnimated:NO];
    } else {
        [self.homeViewController setCurrentUser:[WFInstagramAPI currentUser]];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSDictionary *params = [url queryDictionary];
    
    // make the request to get the user's token, then store it in defaults/synchronize & set it on API
    WFIGResponse *response = [WFInstagramAPI accessTokenForCode:[params objectForKey:@"code"]];
    NSDictionary *json = [response parsedBody];
    NSString *token = [json objectForKey:@"access_token"];
    [WFInstagramAPI setAccessToken:token];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:kDefaultsUserToken];
    [defaults synchronize];
    
    // dismiss our auth controller, get back to the regular application
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow resignKeyWindow];
    keyWindow.hidden = YES;
    [WFInstagramAPI setAuthWindow:nil];
    [self.window makeKeyAndVisible];
    
    [self.homeViewController setCurrentUser:[WFInstagramAPI currentUser]];
    
    return YES;
}

- (void)enterAuthFlowAnimated:(BOOL)animated
{
    // established that we're not valid yet - show the auth controller
    CGAuthController *authController = [[CGAuthController alloc] init];
    [WFIGAuthController setInitialViewClass:[LoginView class]];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:authController];
    navController.navigationBarHidden = YES;
    
    // swap out current window for a window containing our auth view
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIWindow *authWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    authWindow.rootViewController = navController;
    [self setAuthWindow:authWindow];  // otherwise it gets released silently
    
    if (animated) {
        [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            [keyWindow resignKeyWindow];
            keyWindow.hidden = YES;
            [authWindow makeKeyAndVisible];
        } completion:NULL];
    } else {
        [keyWindow resignKeyWindow];
        keyWindow.hidden = YES;
        [authWindow makeKeyAndVisible];
    }
    
    //    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
    //        [keyWindow resignKeyWindow];
    //        keyWindow.hidden = YES;
    //        [authWindow makeKeyAndVisible];
    //    } completion:NULL];
}

- (void)logout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kDefaultsUserToken];
    [defaults synchronize];
    [WFInstagramAPI setAccessToken:nil];
    [self enterAuthFlowAnimated:NO];
}

@end
