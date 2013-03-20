//
//  CRGRecentMediaViewController.m
//  Carogram
//
//  Created by Jacob Moore on 3/13/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGRecentMediaViewController.h"
#import "WFIGRelationship.h"

static int userRelationshipObserverContext;

@interface CRGRecentMediaViewController ()

@end

@implementation CRGRecentMediaViewController {
    BOOL _isLoadingMoreMedia;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self CRGRecentMediaViewController_commonInit];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self CRGRecentMediaViewController_commonInit];
    }
    return self;
}

- (void)CRGRecentMediaViewController_commonInit
{
    self.collectionType = CRGCollectionTypeProfile;
    _isLoadingMoreMedia = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (! self.user.relationship) {
        [self setProgressViewShown:YES];
        self.currentPagingMediaController.view.hidden = YES;
        
        [self.user relationshipWithCompletion:^(WFIGUser *user, WFIGRelationship *relationship, NSError *error) {
            if (relationship.isPrivate) {
                [self setProgressViewShown:NO];
                self.currentPagingMediaController.view.hidden = NO;
            } else {
                [self loadMediaCollection];
            }
        }];
    } else {
        [self setProgressViewShown:NO];
        self.currentPagingMediaController.view.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)loadMediaCollection
{
    if (self.user.relationship == nil || self.user.relationship.isPrivate) return;
    
    [self setProgressViewShown:YES];
    self.currentPagingMediaController.view.hidden = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.mediaCollection = [self.user recentMediaWithError:NULL];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            self.currentPagingMediaController.mediaCollection = self.mediaCollection;
            
            [self setProgressViewShown:NO];
            self.currentPagingMediaController.view.hidden = NO;
            
            if ([self.delegate respondsToSelector:@selector(mediaCollectionViewControllerDidLoadMediaCollection:)]) {
                [self.delegate mediaCollectionViewControllerDidLoadMediaCollection:self];
            }
        });
    });
}

- (void)loadMoreMedia
{
    @synchronized(self) {
        if (_isLoadingMoreMedia) return;
        _isLoadingMoreMedia = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.mediaCollection loadAndMergeNextPageWithError:NULL];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:MediaCollectionDidLoadNextPageNotification
                                                                object:self.mediaCollection];
            
            _isLoadingMoreMedia = NO;
        });
    });
}

- (void)dealloc
{
    self.user = nil;
}

@end
