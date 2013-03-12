//
//  PVInnerShadowLabel.m
//  CPA
//
//  Created by Dmitry Povolotsky on 2/8/13.
//  Based on http://stackoverflow.com/questions/3231690/inner-shadow-in-uilabel
//

#import "PVInnerShadowLabel.h"

@implementation PVInnerShadowLabel


- (UIImage*)blackSquareOfSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [[UIColor blackColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
    UIImage *blackSquare = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blackSquare;
}


- (CGImageRef)createMaskWithSize:(CGSize)size shape:(void (^)(void))block {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    block();
    CGImageRef shape = [UIGraphicsGetImageFromCurrentImageContext() CGImage];
    UIGraphicsEndImageContext();
    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(shape),
                                        CGImageGetHeight(shape),
                                        CGImageGetBitsPerComponent(shape),
                                        CGImageGetBitsPerPixel(shape),
                                        CGImageGetBytesPerRow(shape),
                                        CGImageGetDataProvider(shape), NULL, false);
    return mask;
}


- (void)drawRect:(CGRect)rect
{
    CGSize textSize = [self.text sizeWithFont:self.font constrainedToSize:self.bounds.size];
//    CGRect textRect = CGRectMake(0,self.bounds.size.height/2 - textSize.height/2, self.bounds.size.width, textSize.height);
    CGRect textRect = CGRectMake(self.bounds.size.width/2 - textSize.width/2,self.bounds.size.height/2 - textSize.height/2, self.bounds.size.width, textSize.height);
    CGImageRef mask = [self createMaskWithSize:rect.size shape:^{
        [[UIColor blackColor] setFill];
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
        [[UIColor whiteColor] setFill];
        [self.text drawInRect:textRect withFont:self.font];
    }];
    
    CGImageRef cutoutRef = CGImageCreateWithMask([self blackSquareOfSize:rect.size].CGImage, mask);
    CGImageRelease(mask);
    UIImage *cutout = [UIImage imageWithCGImage:cutoutRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
    CGImageRelease(cutoutRef);
    
    CGImageRef shadedMask = [self createMaskWithSize:rect.size shape:^{
        [[UIColor whiteColor] setFill];
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(), _innerShadowOffset, _innerShadowSize, [[UIColor colorWithWhite:0.0 alpha:1] CGColor]);
        [cutout drawAtPoint:CGPointZero];
    }];
    
    // create negative image
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [_innerShadowColor setFill];
    
    // custom shape goes here
    [self.text drawInRect:textRect withFont:self.font];
    UIImage *negative = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef innerShadowRef = CGImageCreateWithMask(negative.CGImage, shadedMask);
    CGImageRelease(shadedMask);
    UIImage *innerShadow = [UIImage imageWithCGImage:innerShadowRef scale:[[UIScreen mainScreen] scale] orientation:UIImageOrientationUp];
    CGImageRelease(innerShadowRef);
    
    // draw actual image
    [self.textColor setFill];
    [self.text drawInRect:textRect withFont:self.font];
    
    // finally apply shadow
//    [innerShadow drawAtPoint:CGPointZero];
    [innerShadow drawAtPoint:CGPointZero blendMode:kCGBlendModeMultiply alpha:1];
}
@end
