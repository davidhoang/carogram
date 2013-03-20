//
//  CRGProfileGridViewController.h
//  Carogram
//
//  Created by Jacob Moore on 3/14/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGGridViewController.h"

#define kProfileGridCount 10

@interface CRGProfileGridViewController : CRGGridViewController

@property (strong, nonatomic) WFIGUser *user;

- (id)initWithUser:(WFIGUser *)user mediaCollection:(WFIGMediaCollection *)mediaCollection atPage:(int)aPage;

@end
