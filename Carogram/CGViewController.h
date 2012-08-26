//
//  CGViewController.h
//  Carogram
//
//  Created by Jacob Moore on 8/22/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CGViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *titleBarView;
@property (strong, nonatomic) IBOutlet UIImageView *ivSearchBg;
@property (strong, nonatomic) IBOutlet UIButton *btnPopular;
@property (strong, nonatomic) IBOutlet UIButton *btnHome;
@property (strong, nonatomic) IBOutlet UIImageView *ivPhoto;

- (IBAction)touchPopular:(id)sender;
- (IBAction)touchHome:(id)sender;
- (IBAction)touchUser:(id)sender;

@end
