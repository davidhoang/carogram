//
//  CRGImageGridViewCell.m
//  Carogram
//
//  Created by Jacob Moore on 8/27/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGImageGridViewCell.h"

@interface CRGImageGridViewCell ()
@property (strong, nonatomic) WFIGMedia *media;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation CRGImageGridViewCell
@synthesize imageView = _imageView;
@synthesize media = _media;

- (id)initWithMedia:(WFIGMedia *)media frame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        CGRect ivFrame = CGRectMake(5, 5, 190, 190);
        self.imageView = [[UIImageView alloc] initWithFrame:ivFrame];
        [self addSubview:self.imageView];
        
        [self setMedia:media];
    }
    return self;
}

- (void)setMedia:(WFIGMedia *)media
{
    _media = media;
    
    [self.media lowResolutionImageWithCompletionBlock:^(WFIGMedia *media, UIImage *image) {
        if (media == self.media) {
            [self.imageView setImage:image];
        }
    }];
}

@end
