//
//  CRGPagingSlideViewController.h
//  Carogram
//
//  Created by Jacob Moore on 9/10/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRGPagingMediaViewController.h"
#import "CRGMediaSelectorDelegate.h"

@interface CRGPagingSlideViewController : CRGPagingMediaViewController <CRGMediaSelectorDelegate>

@property (nonatomic) CGFloat peripheryAlpha;

@end
