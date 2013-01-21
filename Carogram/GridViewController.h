//
//  GridViewController.h
//  Carogram
//
//  Created by Jacob Moore on 8/27/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFInstagramAPI.h"
#import "MediaSelectorDelegate.h"

#define kImageCount 12

@interface GridViewController : UIViewController

@property (weak, nonatomic) id<MediaSelectorDelegate>delegate;
@property (strong, nonatomic) WFIGMediaCollection *mediaCollection;

- (id)initWithMediaCollection:(WFIGMediaCollection *)mediaCollection atPage:(int)page;
- (BOOL)isGridFull;
- (int)indexOfMediaAtPoint:(CGPoint)point;

@end
