//
//  MediaCollectionDelegate.h
//  Carogram
//
//  Created by Jacob Moore on 9/10/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MediaCollectionDelegate <NSObject>
@required
- (void)loadMoreMedia;
@end
