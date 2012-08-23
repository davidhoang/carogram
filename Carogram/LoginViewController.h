//
//  ViewController.h
//  Carogram
//
//  Created by Adam McDonald on 8/3/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Instagram.h"

@interface LoginViewController : UIViewController <IGSessionDelegate>

- (IBAction)touchConnect:(id)sender;
@end
