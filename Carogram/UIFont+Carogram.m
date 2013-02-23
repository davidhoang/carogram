//
//  UIFont+Carogram.m
//  Carogram
//
//  Created by Jacob Moore on 2/23/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "UIFont+Carogram.h"

@implementation UIFont (Carogram)

+ (UIFont *)defaultFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Gotham-Medium" size:fontSize];
}

+ (UIFont *)gothamBookFontOfSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:@"Gotham-Book" size:fontSize];
}

@end
