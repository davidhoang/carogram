//
//  CRGGridViewController.m
//  Carogram
//
//  Created by Jacob Moore on 3/15/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGGridViewController.h"

@interface CRGGridViewController ()

@end

@implementation CRGGridViewController

- (id)initWithMediaCollection:(WFIGMediaCollection *)mediaCollection atPage:(int)aPage
{
    if ([self class] == [CRGGridViewController class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Error, attempting to instantiate AbstractClass directly."
                                     userInfo:nil];
    }
    
    self = [super init];
    if (self) {
        self.mediaCollection = mediaCollection;
        _page = aPage;
        _gridFull = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Abstract methods

- (int)indexOfMediaAtPoint:(CGPoint)point {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (UIView *)gridCellAtPoint:(CGPoint)point {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (UIView *)gridCellAtIndex:(int)index {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

+ (int)pageCountWithMediaCount:(int)mediaCount {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
