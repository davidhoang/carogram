//
//  HomeViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/21/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"

@interface HomeViewController ()
- (void)loadMediaCollection;
- (void)loadProfilePicture;
@end

@implementation HomeViewController
@synthesize mediaCollection = _mediaCollection;
@synthesize currentUser = _currentUser;

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
 
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setHomeViewController:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"<Home> viewWillAppear:");
    
    // start loading your photos if we don't have any right now
//    if (nil == self.mediaCollection) {
//        [self loadMediaCollection];
//    }
//    [self loadProfilePicture];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void) setCurrentUser:(WFIGUser *)currentUser
{
    _currentUser = currentUser;
    
    [self loadProfilePicture];
}

- (void) loadMediaCollection {
    NSLog(@"loadMediaCollection");
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        self.mediaCollection = [WFIGMedia popularMediaWithError:NULL];
////        [self.tableView reloadData];
//    });
}

- (void)loadProfilePicture
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.currentUser profilePicture]]]];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            if (image != nil) {
                self.ivPhoto.image = image;
            }
        });
    });
}

- (IBAction)touchUser:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showFromRect:self.ivPhoto.frame inView:self.titleBarView animated:YES];

}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex: %d", buttonIndex);
    if (0 == buttonIndex) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate logout];
    }
}

@end
