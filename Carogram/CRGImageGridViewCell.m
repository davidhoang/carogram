//
//  CRGImageGridViewCell.m
//  Carogram
//
//  Created by Jacob Moore on 8/27/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGImageGridViewCell.h"
#import "SDWebImageManager.h"

@interface CRGImageGridViewCell ()
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) WFIGMedia *media;
@end

@implementation CRGImageGridViewCell

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
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:[NSURL URLWithString:media.lowResolutionURL]
                     options:0
                    progress:^(NSUInteger receivedSize, long long expectedSize)
     {
         // progression tracking code
     }
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
     {
         if (image)
         {
             [self.imageView setImage:image];
         }
     }];
}

@end
