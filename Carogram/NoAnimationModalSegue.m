//
//  NoAnimationModalSegue.m
//  Carogram
//
//  Created by Jacob Moore on 8/22/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "NoAnimationModalSegue.h"

@implementation NoAnimationModalSegue

- (void)perform {
    [self.sourceViewController presentModalViewController:self.destinationViewController animated:NO];
}

@end
