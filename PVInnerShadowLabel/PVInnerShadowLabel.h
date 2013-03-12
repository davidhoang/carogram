//
//  PVInnerShadowLabel.h
//  CPA
//
//  Created by Dmitry Povolotsky on 2/8/13.
//  Based on http://stackoverflow.com/questions/3231690/inner-shadow-in-uilabel
//

#import <Foundation/Foundation.h>

@interface PVInnerShadowLabel : UILabel

@property (nonatomic) UIColor* innerShadowColor;
@property (nonatomic) CGSize innerShadowOffset;
@property (nonatomic) CGFloat innerShadowSize;


@end
