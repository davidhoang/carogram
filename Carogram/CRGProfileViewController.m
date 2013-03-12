//
//  CRGProfileViewController.m
//  Carogram
//
//  Created by Jacob Moore on 3/11/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Carogram.h"
#import "PVInnerShadowLabel.h"

@interface CRGProfileViewController ()
@property (strong, nonatomic) IBOutlet UIView *titleBarView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) IBOutlet PVInnerShadowLabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *titleBarBackground;

@end

@implementation CRGProfileViewController

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
	
    UIImage *patternImage = [UIImage imageNamed:@"title-bar-bg-tile"];
    self.titleBarBackground.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    
    // Add shadow to title bar
    self.titleBarBackground.layer.shadowOffset = CGSizeMake(0, 3);
    self.titleBarBackground.layer.shadowRadius = 4;
    self.titleBarBackground.layer.shadowColor = [UIColor blackColor].CGColor;
    self.titleBarBackground.layer.shadowOpacity = .5;
    self.titleBarBackground.layer.masksToBounds = NO;

    UIImage *backButtonImage = [[UIImage imageNamed:@"btn-back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 19, 0, 8)];
    [self.backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    
    self.backButton.titleLabel.font = [UIFont defaultFontOfSize:14];
    
    self.titleLabel.text = [self.user.username uppercaseString];
    self.titleLabel.innerShadowColor = [UIColor colorWithWhite:0 alpha:.75];
    self.titleLabel.innerShadowOffset = CGSizeMake(0, .8);
    self.titleLabel.innerShadowSize = 1.2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleBarView:nil];
    [self setBackButton:nil];
    [self setTitleLabel:nil];
    [self setTitleBarBackground:nil];
    [super viewDidUnload];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
