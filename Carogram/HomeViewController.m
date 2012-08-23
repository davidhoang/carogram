//
//  HomeViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/21/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "Instagram.h"
#import "LoginViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

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
    NSLog(@"<Home> viewDidLoad");
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"<Home> viewWillAppear");
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    Instagram *instagram = appDelegate.instagram;
    // Show Login VC if necessary
    instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    if (![instagram isSessionValid]) {
        NSLog(@"session NOT valid");
        [self performSegueWithIdentifier:@"ShowLogin" sender:self];
    } else {
        NSLog(@"session VALID");
    }
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    Instagram *instagram = appDelegate.instagram;
//    // Show Login VC if necessary
//    instagram.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
//    if (![instagram isSessionValid]) {
//        NSLog(@"session NOT valid");
//        [self performSegueWithIdentifier:@"ShowLogin" sender:self];
//    } else {
//        NSLog(@"session VALID");
//    }
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)touchLogout:(id)sender {
    NSLog(@"touchLogout:");
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"accessToken"];
//    [[NSUserDefaults standardUserDefaults] setObject:appDelegate.instagram.accessToken forKey:@"accessToken"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [appDelegate.instagram logout];
//    [self.navigationController popViewControllerAnimated:YES];
//    [self performSegueWithIdentifier:@"ShowLoginAnimated" sender:self];
}

@end
