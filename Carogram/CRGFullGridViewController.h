//
//  CRGFullGridViewController.h
//  Carogram
//
//  Created by Jacob Moore on 8/27/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRGGridViewController.h"

#define kGridCount 12

@interface CRGFullGridViewController : CRGGridViewController
- (id)initWithMediaCollection:(WFIGMediaCollection *)mediaCollection atPage:(int)aPage offset:(int)offset;
@end
