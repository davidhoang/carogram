//
//  CGMediaCollectionViewController.h
//  Carogram
//
//  Created by Jacob Moore on 8/22/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "WFInstagramAPI.h"
#import "CRGMediaSelectorDelegate.h"
#import "CRGPagingMediaViewController.h"
#import "CRGDetailsViewController.h"

@protocol CRGMediaCollectionViewControllerDelegate;

@interface CRGMediaCollectionViewController : UIViewController <UIActionSheetDelegate, UIScrollViewDelegate, CRGMediaSelectorDelegate, PagingMediaViewControllerDelegate, CRGDetailsViewControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<CRGMediaCollectionViewControllerDelegate> delegate;
@property (nonatomic) int collectionType;
@property (strong, nonatomic) WFIGUser *currentUser;
@property (strong, nonatomic) IBOutlet UIView *titleBarView;
@property (strong, nonatomic) IBOutlet UIImageView *ivSearchBg;
@property (strong, nonatomic) IBOutlet UIButton *btnPopular;
@property (strong, nonatomic) IBOutlet UIButton *btnHome;
@property (strong, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (strong, nonatomic) IBOutlet UIImageView *ivProgressBackground;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (strong, atomic) WFIGMediaCollection *mediaCollection;
@property (strong, nonatomic) CRGPagingMediaViewController *currentPagingMediaController;
@property (strong, nonatomic) NSString *noResultsText;

- (void)refresh;
- (void)scrollToFirstPage;
- (void)setProgressViewShown:(BOOL)shown;
- (void)loadMediaCollection;
- (void)showNoResultsLabel;
- (void)hideNoResultsLabel;
- (void)didLogout;

@end

@protocol CRGMediaCollectionViewControllerDelegate <NSObject>

- (void)mediaCollectionViewControllerDidLoadMediaCollection:(CRGMediaCollectionViewController *)mediaCollectionViewController;

@end
