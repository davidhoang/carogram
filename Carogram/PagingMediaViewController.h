//
//  PagingMediaViewController.h
//  Carogram
//
//  Created by Jacob Moore on 9/10/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaCollectionDelegate.h"

@protocol PagingMediaScrollDelegate;

@interface PagingMediaViewController : UIViewController

@property (weak, nonatomic) id<MediaCollectionDelegate> mediaCollectionDelegate;
@property (weak, nonatomic) id<PagingMediaScrollDelegate>pagingMediaScrollDelegate;
@property (strong, nonatomic) WFIGMediaCollection *mediaCollection;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (int)currentPage;
- (void)scrollToFirstPage;

@end

@protocol PagingMediaScrollDelegate <NSObject>
@optional
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;
@end
