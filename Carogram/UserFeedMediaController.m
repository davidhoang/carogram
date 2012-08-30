//
//  UserFeedMediaController.m
//  Carogram
//
//  Created by Jacob Moore on 8/29/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "UserFeedMediaController.h"

static NSSet * ObservableKeys = nil;

static NSString * const MediaKeyPath = @"media";

@interface UserFeedMediaController ()

@end

@implementation UserFeedMediaController
@synthesize media = _media;
@synthesize ivPhoto = _ivPhoto;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        ObservableKeys = [[NSSet alloc] initWithObjects:MediaKeyPath, nil];
        for (NSString *keyPath in ObservableKeys) {
            [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    return self;
}

- (void)dealloc
{
    for (NSString *keyPath in ObservableKeys) {
        [self removeObserver:self forKeyPath:keyPath context:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setIvPhoto:nil];   
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([ObservableKeys containsObject:keyPath]) {
        if ([keyPath isEqualToString:MediaKeyPath]) {
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *img = [self.media image];
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    [self.ivPhoto setImage:img];
                });
            });
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
