//
//  CRGPagingMediaViewController.h
//  Carogram
//
//  Created by Jacob Moore on 9/10/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRGMediaSelectorDelegate.h"

extern NSString *  const MediaCollectionDidLoadNextPageNotification;

@protocol PagingMediaViewControllerDelegate;

@interface CRGPagingMediaViewController : UIViewController

@property (weak, nonatomic) id<PagingMediaViewControllerDelegate> delegate;
@property (weak, nonatomic) id<CRGMediaSelectorDelegate> mediaSelectorDelegate;
@property (strong, nonatomic) WFIGMediaCollection *mediaCollection;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

- (int)currentPage;
- (void)setCurrentPage:(int)page animated:(BOOL)animated;
- (void)scrollToFirstPage;
- (void)nextPageLoaded;

@end

@protocol PagingMediaViewControllerDelegate <NSObject>
@optional
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)didSelectMedia:(WFIGMedia *)media fromRect:(CGRect)rect;
- (void)loadMoreMedia;
@end
