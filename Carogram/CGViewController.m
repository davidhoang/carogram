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
}

- (void)viewDidUnload
{
    [self setTitleBarView:nil];
    [self setIvSearchBg:nil];
    [self setBtnPopular:nil];
    [self setBtnHome:nil];
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

@end
