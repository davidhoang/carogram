//
//  CGViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/22/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CGViewController.h"
#import "AppDelegate.h"

static NSSet * ObservableKeys = nil;

@interface CGViewController ()
- (void)loadProfilePicture;
@end

@implementation CGViewController
@synthesize currentUser = _currentUser;
@synthesize titleBarView = _titleBarView;
@synthesize ivSearchBg = _ivSearchBg;
@synthesize btnPopular = _btnPopular;
@synthesize btnHome = _btnHome;
@synthesize ivPhoto = _ivPhoto;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        if (nil == ObservableKeys) {
            ObservableKeys = [[NSSet alloc] initWithObjects:kCurrentUserKeyPath, nil];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (NSString *keyPath in ObservableKeys) {
        [appDelegate addObserver:self
                      forKeyPath:keyPath
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    }
    self.currentUser = appDelegate.currentUser;
    if (nil != self.currentUser) [self loadProfilePicture];
    
    [[NSBundle mainBundle] loadNibNamed:@"TitleBarView" owner:self options:nil];
    [self.view addSubview:self.titleBarView];
    
    self.ivSearchBg.image = [[UIImage imageNamed:@"search-bg"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    
    // Round avatar image view
    self.ivPhoto.layer.opaque = YES;
    self.ivPhoto.layer.masksToBounds = YES;
    self.ivPhoto.layer.cornerRadius = 2.0;
    
    // Add rounded border layer
    CALayer *roundedLayer = [CALayer layer];
    roundedLayer.frame = CGRectMake(-1.0, -1.0, (self.ivPhoto.frame.size.width + 2.0), (self.ivPhoto.frame.size.height + 2.0));
    roundedLayer.opaque = YES;
    roundedLayer.masksToBounds = YES;
    roundedLayer.cornerRadius = 2.0;
    roundedLayer.borderWidth = 2.5;
    roundedLayer.borderColor = [[UIColor colorWithRed:(69.0/255.0) green:(73.0/255.0) blue:(76.0/255.0) alpha:1.0] CGColor];
    
    [self.ivPhoto.layer addSublayer:roundedLayer];
    
    if (self.tabBarController.selectedIndex == 0) {
        [self.btnHome setImage:[UIImage imageNamed:@"btn-home-depressed"] forState:UIControlStateNormal];
        [self.btnPopular setImage:[UIImage imageNamed:@"btn-popular"] forState:UIControlStateNormal];
    } else {
        [self.btnHome setImage:[UIImage imageNamed:@"btn-home"] forState:UIControlStateNormal];
        [self.btnPopular setImage:[UIImage imageNamed:@"btn-popular-depressed"] forState:UIControlStateNormal];
    }
}

- (void)viewDidUnload
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (NSString *keyPath in ObservableKeys) {
        [appDelegate removeObserver:self forKeyPath:keyPath context:nil];
    }
    
    [self setTitleBarView:nil];
    [self setIvSearchBg:nil];
    [self setBtnPopular:nil];
    [self setBtnHome:nil];
    [self setIvPhoto:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (![ObservableKeys containsObject:keyPath]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([kCurrentUserKeyPath isEqualToString:keyPath]) {
        self.currentUser = (WFIGUser *)[change objectForKey:NSKeyValueChangeNewKey];
        [self loadProfilePicture];
    }
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

- (IBAction)touchPopular:(id)sender {
    [self.tabBarController setSelectedIndex:1];
}

- (IBAction)touchHome:(id)sender {
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)touchUser:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showFromRect:self.ivPhoto.frame inView:self.titleBarView animated:YES];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate logout];
    }
}

@end
