//
//  GridViewController.h
//  Carogram
//
//  Created by Jacob Moore on 8/27/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFInstagramAPI.h"

#define kImageCount 12

@interface GridViewController : UIViewController

@property (strong, nonatomic) WFIGMediaCollection *mediaCollection;

- (id)initWithMediaCollection:(WFIGMediaCollection *)mediaCollection atPage:(int)page;

@end
