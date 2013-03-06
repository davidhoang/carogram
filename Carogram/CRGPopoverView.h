//
//  CRGPopoverView.h
//  Carogram
//
//  Created by Jacob Moore on 3/4/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CRGPopoverViewDelegate;

@interface CRGPopoverView : UIView

@property (weak, nonatomic) id<CRGPopoverViewDelegate> delegate;

- (id)initWithItems:(NSArray *)items;
- (void)show;

@end

@protocol CRGPopoverViewDelegate <NSObject>
- (void)popoverView:(CRGPopoverView *)popoverView didDismissWithItemIndex:(int)index;
- (void)popoverViewDidCancel:(CRGPopoverView *)popoverView;
@end

