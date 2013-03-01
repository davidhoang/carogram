//
//  CRGPagingGridViewController.h
//  Carogram
//
//  Created by Jacob Moore on 9/10/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRGPagingMediaViewController.h"

@interface CRGPagingGridViewController : CRGPagingMediaViewController

@property (nonatomic) int focusIndex;
@property (nonatomic) CGFloat peripheryAlpha;

- (int)indexOfMediaAtPoint:(CGPoint)point;
- (UIView *)gridCellAtPoint:(CGPoint)point;
- (UIView *)gridCellAtIndex:(int)index;

@end
