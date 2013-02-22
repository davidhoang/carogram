//
//  CRGNewCommentViewController.h
//  Carogram
//
//  Created by Jacob Moore on 2/21/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CRGNewCommentViewControllerDelegate;

@interface CRGNewCommentViewController : UIViewController
@property (weak, nonatomic) id<CRGNewCommentViewControllerDelegate> delegate;
@property (strong, nonatomic) WFIGMedia *media;
@end

@protocol CRGNewCommentViewControllerDelegate <NSObject>
- (void)newCommentViewControllerDidFinish:(CRGNewCommentViewController *)newCommentViewController;
@end
