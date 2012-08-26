//
//  CGViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/22/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CGViewController.h"

@interface CGViewController ()

@end

@implementation CGViewController
@synthesize titleBarView = _titleBarView;
@synthesize ivSearchBg = _ivSearchBg;
@synthesize btnPopular = _btnPopular;
@synthesize btnHome = _btnHome;
@synthesize ivPhoto = _ivPhoto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
}

- (void)viewDidUnload
{
    [self setTitleBarView:nil];
    [self setIvSearchBg:nil];
    [self setBtnPopular:nil];
    [self setBtnHome:nil];
    [self setIvPhoto:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)touchPopular:(id)sender {
    [self.btnHome setImage:[UIImage imageNamed:@"btn-home"] forState:UIControlStateNormal];
    [self.btnPopular setImage:[UIImage imageNamed:@"btn-popular-depressed"] forState:UIControlStateNormal];
}

- (IBAction)touchHome:(id)sender {
    [self.btnHome setImage:[UIImage imageNamed:@"btn-home-depressed"] forState:UIControlStateNormal];
    [self.btnPopular setImage:[UIImage imageNamed:@"btn-popular"] forState:UIControlStateNormal];
}

- (IBAction)touchUser:(id)sender {
}

@end
