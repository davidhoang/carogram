//
//  HomeViewController.h
//  Carogram
//
//  Created by Jacob Moore on 8/21/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CGViewController.h"
#import "WFIGMediaCollection.h"

@interface HomeViewController : CGViewController <UIActionSheetDelegate>

@property (strong, nonatomic) WFIGUser *currentUser;
@property (strong, atomic) WFIGMediaCollection *mediaCollection;

@end
