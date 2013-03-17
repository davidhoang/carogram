//
//  CRGGridViewController.h
//  Carogram
//
//  Created by Jacob Moore on 3/15/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//
//  This is an abstract class. Do not attempt to instantiate this class.

#import <Foundation/Foundation.h>
#import "WFInstagramAPI.h"
#import "CRGMediaSelectorDelegate.h"

@interface CRGGridViewController : UIViewController

@property (weak, nonatomic) id<CRGMediaSelectorDelegate>delegate;
@property (strong, nonatomic) WFIGMediaCollection *mediaCollection;
@property (nonatomic) int focusIndex;
@property (nonatomic) CGFloat peripheryAlpha;
@property (nonatomic, getter=isGridFull) BOOL gridFull;
@property (nonatomic) int page;

- (id)initWithMediaCollection:(WFIGMediaCollection *)mediaCollection atPage:(int)page;
- (int)indexOfMediaAtPoint:(CGPoint)point;
- (UIView *)gridCellAtPoint:(CGPoint)point;
- (UIView *)gridCellAtIndex:(int)index;
+ (int)pageCountWithMediaCount:(int)mediaCount;

@end
