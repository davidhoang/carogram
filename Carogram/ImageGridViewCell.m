//
//  ImageGridViewCell.m
//  Carogram
//
//  Created by Jacob Moore on 8/27/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "ImageGridViewCell.h"

@interface ImageGridViewCell ()
@property (strong, nonatomic) WFIGMedia *media;
@property (strong, nonatomic) UIImageView *imageView;
@end

@implementation ImageGridViewCell
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
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *img = [self.media image];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.imageView setImage:img];
        });
    });
}

@end
