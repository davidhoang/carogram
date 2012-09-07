//
//  MediaSelectorDelegate.h
//  Carogram
//
//  Created by Jacob Moore on 9/4/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFIGMedia.h"

@protocol MediaSelectorDelegate <NSObject>
@required
- (void)didSelectMedia:(WFIGMedia *)media fromRect:(CGRect)rect;
@end
