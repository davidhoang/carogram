//
//  HomeViewController.m
//  Carogram
//
//  Created by Jacob Moore on 8/21/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "HomeViewController.h"
#import "AppDelegate.h"
#import "ImageGridViewCell.h"
#import "GridViewController.h"

@interface HomeViewController ()
@property (nonatomic, strong) NSMutableArray *gridViewControllers;
- (void)loadMediaCollection;
- (void)loadScrollViewWithPage:(int)page;
- (void)loadMoreMedia;
- (void)loadProfilePicture;
@end

@implementation HomeViewController {
@private
    int pageCount;
    BOOL isLoadingMoreMedia;
}
@synthesize mediaCollection = _mediaCollection;
@synthesize scrollView = _scrollView;
@synthesize currentUser = _currentUser;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isLoadingMoreMedia = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setHomeViewController:self];

}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void) setCurrentUser:(WFIGUser *)currentUser
{
    _currentUser = currentUser;
       
    [self loadProfilePicture]; 
    [self loadMediaCollection];
}

- (void) loadMediaCollection {
    NSLog(@"loadMediaCollection");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.mediaCollection = [WFIGMedia popularMediaWithError:NULL];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            if ([self.mediaCollection count] > 0) {
                pageCount = ceil((double)[self.mediaCollection count] / (double)kImageCount);
                
                // view controllers are created lazily
                // in the meantime, load the array with placeholders which will be replaced on demand
                NSMutableArray *controllers = [[NSMutableArray alloc] init];
                for (unsigned i = 0; i < pageCount; i++) {
                    [controllers addObject:[NSNull null]];
                }
                self.gridViewControllers = controllers;
                
                self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * pageCount, self.scrollView.frame.size.height);
                
                [self loadScrollViewWithPage:0];
                [self loadScrollViewWithPage:1];
            }
        });
    });
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= pageCount) {
        if ([self.mediaCollection hasNextPage] && !isLoadingMoreMedia) {
            [self loadMoreMedia];
        }
        return;
    }
    
    // replace the placeholder if necessary
    GridViewController * controller = [self.gridViewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
        controller = [[GridViewController alloc] initWithMediaCollection:self.mediaCollection atPage:page];
        [self.gridViewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
    }
}

- (void)loadMoreMedia
{
    if (isLoadingMoreMedia) return;
    
    isLoadingMoreMedia = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.mediaCollection loadAndMergeNextPageWithError:NULL];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            pageCount = [self.mediaCollection count] / kImageCount;
            
            NSMutableArray *controllers = [self.gridViewControllers mutableCopy];
            for (unsigned i = [self.gridViewControllers count]; i < pageCount; i++) {
                [controllers addObject:[NSNull null]];
            }
            self.gridViewControllers = controllers;
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * pageCount, self.scrollView.frame.size.height);
            
            isLoadingMoreMedia = NO;
        });
    });
}

- (void)loadProfilePicture
 {
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.currentUser profilePicture]]]];
        dispatch_async( dispatch_get_main_queue(), ^{
            if (image != nil) {
                self.ivPhoto.image = image;
            }
        });
    });
}

- (IBAction)touchUser:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Logout" otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showFromRect:self.ivPhoto.frame inView:self.titleBarView animated:YES];

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate logout];
    }
}

@end
