//
//  CRGDetailsViewController.m
//  Carogram
//
//  Created by Jacob Moore on 9/3/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGDetailsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CRGCommentCell.h"
#import "CRGLikeCell.h"
#import "WFIGImageCache.h"
#import "CRGNewCommentViewController.h"
#import "SDWebImageManager.h"
#import <Twitter/Twitter.h>

typedef enum {
    AlertViewTagSetLike,
    AlertViewTagRemoveLike,
} AlertViewTag;

@interface CRGDetailsViewController ()
@property (nonatomic) CGRect mediaFrame;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnShare;
@property (strong, nonatomic) CRGNewCommentViewController *aNewCommentViewController;
@property (strong, nonatomic) IBOutlet UITableView *commentsTableView;
@property (strong, nonatomic) IBOutlet UITableView *likesTableView;
@property (strong, nonatomic) IBOutlet UIButton *btnLike;
@property (strong, nonatomic) IBOutlet UIButton *btnLikeMedia;
@property (strong, nonatomic) IBOutlet UIImageView *likeImageView;
@property (strong, nonatomic) CRGPopoverView *sharePopoverView;
- (void)configureViews;
- (void)loadProfilePicture;
- (void)loadComments;
@end

@implementation CRGDetailsViewController {
@private
    BOOL animationComplete;
}
@synthesize media = _media;
@synthesize ivPhoto = _ivPhoto;
@synthesize startRect = _startRect;
@synthesize mediaView = _mediaView;
@synthesize ivUser = _ivUser;
@synthesize lblCaption = _lblCaption;
@synthesize lblComments = _lblComments;
@synthesize lblLikes = _lblLikes;
@synthesize commentsView = _commentsView;
@synthesize btnComments = _btnComments;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Disable liking until we know if this user has liked this media
    self.btnLike.enabled = NO;
    self.btnLikeMedia.enabled = NO;

    self.mediaFrame = self.mediaView.frame;
    self.mediaView.frame = self.startRect;
    
    // Round avatar image view
    self.ivUser.layer.opaque = YES;
    self.ivUser.layer.masksToBounds = YES;
    self.ivUser.layer.cornerRadius = 0;
    
    // Add rounded border layer
    CALayer *roundedLayer = [CALayer layer];
    roundedLayer.frame = self.ivUser.bounds;
    roundedLayer.opaque = YES;
    roundedLayer.masksToBounds = YES;
    roundedLayer.cornerRadius = 0;
    roundedLayer.borderWidth = 1.0;
    roundedLayer.borderColor = [[UIColor colorWithRed:(220./255.)
                                                green:(201./255.)
                                                 blue:(201./255.)
                                                alpha:1.] CGColor];
    
    [self.ivUser.layer addSublayer:roundedLayer];
    
    [self configureViews];
    
    self.commentsTableView.directionalLockEnabled = YES;
    self.likesTableView.directionalLockEnabled = YES;
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftGesture:)];
    swipeLeftRecognizer.numberOfTouchesRequired = 1;
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.commentsTableView addGestureRecognizer:swipeLeftRecognizer];

    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGesture:)];
    swipeRightRecognizer.numberOfTouchesRequired = 1;
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.likesTableView addGestureRecognizer:swipeRightRecognizer];

    self.likesTableView.frame = CGRectOffset(self.likesTableView.frame, self.commentsView.frame.size.width - self.likesTableView.frame.origin.x, 0);
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self.ivPhoto addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [self.ivPhoto addGestureRecognizer:singleTapRecognizer];
}

- (void)viewDidUnload
{
    [self setIvPhoto:nil];
    [self setMediaView:nil];
    [self setIvUser:nil];
    [self setLblCaption:nil];
    [self setLblComments:nil];
    [self setLblLikes:nil];
    [self setCommentsView:nil];
    [self setBtnComments:nil];
    [self setUsernameLabel:nil];
    [self setBtnShare:nil];
    [self setCommentsTableView:nil];
    [self setLikesTableView:nil];
    [self setBtnLike:nil];
    [self setBtnLikeMedia:nil];
    [self setLikeImageView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect commentsFrame = self.commentsView.frame;
    CGRect startCommentsFrame = self.commentsView.frame;
    startCommentsFrame.origin.x = self.view.frame.size.width;
    self.commentsView.frame = startCommentsFrame;
    
    animationComplete = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.mediaView.frame = self.mediaFrame;
                         self.commentsView.frame = commentsFrame;
                     }
                     completion:^(BOOL finished){
                         animationComplete = YES;
                         [self.commentsTableView setHidden:NO];
                         [self.commentsTableView reloadData];
                         [self loadComments];
                         [self.likesTableView reloadData];
                     }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.commentsTableView setHidden:YES];
    
    CGRect commentsFrame = self.commentsView.frame;
    commentsFrame.origin.x = self.view.frame.size.width;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.mediaView.frame = self.startRect;
                         self.commentsView.frame = commentsFrame;
                     }];
}

- (void)configureViews
{
    self.commentsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"details-bg-tile"]];
    
    self.usernameLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:15.];
    self.lblCaption.font = [UIFont fontWithName:@"Gotham-Medium" size:12.];
    self.lblLikes.font = [UIFont fontWithName:@"Gotham-Medium" size:15.];
    self.lblComments.font = [UIFont fontWithName:@"Gotham-Medium" size:15.];
    
    if (nil != self.media) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadWithURL:[NSURL URLWithString:self.media.imageURL]
                         options:0
                        progress:^(NSUInteger receivedSize, long long expectedSize) { }
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
         {
             if (image)
             {
                 [self.ivPhoto setImage:image];
             }
         }];
        
        [self loadProfilePicture];
        self.usernameLabel.text = self.media.user.username;
        [self.lblCaption setText:[self.media caption]];
        [self.lblComments setText:[NSString stringWithFormat:@"%d", [self.media commentsCount]]];
        [self.lblLikes setText:[NSString stringWithFormat:@"%d", [self.media likesCount]]];
    } else {
        [self.ivPhoto setImage:nil];
        [self.ivUser setImage:nil];
        [self.lblCaption setText:@""];
        [self.lblComments setText:@""];
        [self.lblLikes setText:@""];
    }
    
    self.likeImageView.layer.cornerRadius = 8.;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark -

- (void)setLike
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        BOOL success = [self.media setLikeWithError:&error];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            if (!success || error) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                             message:@"An error occurred while trying to like this media."
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"Try Again", nil];
                av.tag = AlertViewTagSetLike;
                [av show];
            }
        });
    });
}

- (void)removeLike
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        BOOL success = [self.media removeLikeWithError:&error];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            if (!success || error) {
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Whoops!"
                                                             message:@"An error occurred while trying to remove the like for this media."
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                                   otherButtonTitles:@"Try Again", nil];
                av.tag = AlertViewTagRemoveLike;
                [av show];
            }
        });
    });
}

- (void)loadProfilePicture
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [WFIGImageCache getImageAtURL:[self.media.user profilePicture]];
        dispatch_async( dispatch_get_main_queue(), ^{
            if (image != nil) {
                self.ivUser.image = image;
            }
        });
    });
}

- (void)loadComments
{
    if ([self.media commentsCount] == 0) {
        [self loadLikes];
        return;
    }
    
    if (![self.media hasAllComments]) {
        int oldCommentsCount = [self.media.comments count];
        [self.media allCommentsWithCompletionBlock:^(WFIGMedia *commentsMedia, NSArray *comments, NSError *error) {
            if (self.media == commentsMedia && error == nil) {
                int rowsAdded = [self.media commentsCount] - oldCommentsCount;
                
                NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:rowsAdded];
                for (int i = 0; i < rowsAdded; i++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(i+1) inSection:0]; // +1 for Comments header
                    [indexPaths addObject:indexPath];
                }
                
                [self.commentsTableView beginUpdates];
                [self.commentsTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
                [self.commentsTableView endUpdates];

                [self loadLikes];
            }
        }];
    } else {
        [self loadLikes];
    }
}

- (void)loadLikes
{
    if ([self.media likesCount] == 0) {
        [self checkLikeStatus];
        return;
    }
    
    if (! [self.media hasAllLikes]) {
        int oldLikesCount = [self.media.likes count];
        [self.media allLikesWithCompletionBlock:^(WFIGMedia *likesMedia, NSArray *likes, NSError *error) {
            if (self.media == likesMedia && error == nil) {
                int rowsAdded = [self.media likesCount] - oldLikesCount;
                
                NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:rowsAdded];
                for (int i = 0; i < rowsAdded; i++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(i+1) inSection:0]; // +1 for Likes header
                    [indexPaths addObject:indexPath];
                }
                
                [self.likesTableView beginUpdates];
                [self.likesTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
                [self.likesTableView endUpdates];

                [self checkLikeStatus];
            }
        }];
    } else {
        [self checkLikeStatus];
    }
}

- (void)checkLikeStatus
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"instagramId == %@", [WFInstagramAPI currentUser].instagramId];
    NSArray *currentUserMatches = [self.media.likes filteredArrayUsingPredicate:predicate];

    if ([currentUserMatches count]) {
        self.btnLike.selected = YES;
        self.btnLikeMedia.selected = YES;
    } else {
        self.btnLike.selected = NO;
        self.btnLikeMedia.selected = NO;
    }

    self.btnLike.enabled = YES;
    self.btnLikeMedia.enabled = YES;
}

- (void)flashLikeHeart
{
    self.likeImageView.alpha = 0;
    self.likeImageView.hidden = NO;
    self.likeImageView.transform = CGAffineTransformMakeScale(.1, .1);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.likeImageView.alpha = 1;
        self.likeImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [NSThread sleepForTimeInterval:1];
            dispatch_async( dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{
                    self.likeImageView.alpha = 0;
                } completion:^(BOOL finished) {
                    self.likeImageView.hidden = YES;
                }];
            });
        });
    }];
}

- (void)sendMail
{
    MFMailComposeViewController *mcvc = [[MFMailComposeViewController alloc] init];
    mcvc.mailComposeDelegate = self;
    [mcvc setSubject:@"Check out this Instagram photo I saw on Carogram"];
    NSString *messageBody = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", self.media.instagramURL, self.media.instagramURL];
    [mcvc setMessageBody:messageBody isHTML:YES];
    [self presentModalViewController:mcvc animated:YES];
}

- (void)sendTweet
{
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
    NSString *initialText = [NSString stringWithFormat:@"Check out this Instagram photo I saw on @carogramapp: %@", self.media.instagramURL];
    [tweetSheet setInitialText:initialText];
    [self presentModalViewController:tweetSheet animated:YES];
}

#pragma mark - Actions

- (IBAction)newComment:(UIButton *)sender {
    self.aNewCommentViewController = (CRGNewCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"NewComment"];
    self.aNewCommentViewController.delegate = self;
    self.aNewCommentViewController.media = self.media;
    
    [self addChildViewController:self.aNewCommentViewController];
    [self.view addSubview:self.aNewCommentViewController.view];
    [self.aNewCommentViewController didMoveToParentViewController:self];
}

- (IBAction)toggleLike:(UIButton *)sender {
    self.btnLike.selected = !self.btnLike.selected;
    self.btnLikeMedia.selected = !self.btnLikeMedia.selected;
    
    WFIGUser *currentUser = [WFInstagramAPI currentUser];
    if (self.btnLike.selected) {
        [self.media.likes addObject:currentUser];
        self.lblLikes.text =[NSString stringWithFormat:@"%d", [self.media.likes count]];
        [self setLike];
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"instagramId == %@", [WFInstagramAPI currentUser].instagramId];
        NSArray *currentUserMatches = [self.media.likes filteredArrayUsingPredicate:predicate];
        
        if ([currentUserMatches count]) {
            [self.media.likes removeObject:currentUserMatches[0]];
            self.lblLikes.text =[NSString stringWithFormat:@"%d", [self.media.likes count]];
            [self removeLike];
        }
    }
    [self.likesTableView reloadData];
}

- (IBAction)touchClose:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)touchShare:(id)sender {
    if (! self.sharePopoverView) {
        CGRect fromRect = [self.btnShare convertRect:self.btnShare.bounds toView:self.view];
        NSArray *items = @[@"Twitter", @"Email"];
        self.sharePopoverView = [[CRGPopoverView alloc] initWithItems:items fromRect:fromRect width:235.];
        self.sharePopoverView.delegate = self;
    }
    [self.sharePopoverView show];
}

#pragma mark - Gesture handling

- (IBAction)handleSwipeLeftGesture:(UIGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateRecognized: {
            [UIView animateWithDuration:0.2 animations:^{
                self.commentsTableView.frame = CGRectOffset(self.commentsTableView.frame, 0 - self.commentsTableView.frame.origin.x - self.commentsTableView.frame.size.width, 0);
                self.likesTableView.frame = CGRectOffset(self.likesTableView.frame, 0 - self.likesTableView.frame.origin.x, 0);
            }];
            break;
        }
        default:
            break;
    }
}

- (IBAction)handleSwipeRightGesture:(UIGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateRecognized: {
            [UIView animateWithDuration:0.2 animations:^{
                self.commentsTableView.frame = CGRectOffset(self.commentsTableView.frame, self.commentsTableView.frame.size.width, 0);
                self.likesTableView.frame = CGRectOffset(self.likesTableView.frame, self.commentsView.frame.size.width, 0);
            }];
            break;
        }
        default:
            break;
    }
}

- (IBAction)handleSingleTap:(UIGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateRecognized: {
            [self dismissModalViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}

- (IBAction)handleDoubleTap:(UIGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateRecognized: {
            [self flashLikeHeart];
            [self toggleLike:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex) { // Try again
        if (AlertViewTagSetLike == alertView.tag) {
            [self setLike];
        } else if (AlertViewTagRemoveLike == alertView.tag) {
            [self removeLike];
        }
    } else { // Cancel
        if (AlertViewTagSetLike == alertView.tag) {
            self.btnLike.selected = NO;
            self.btnLikeMedia.selected = NO;
            
            WFIGUser *currentUser = [WFInstagramAPI currentUser];
            if ([self.media.likes containsObject:currentUser]) {
                [self.media.likes removeObject:currentUser];
                [self.likesTableView reloadData];
                self.lblLikes.text =[NSString stringWithFormat:@"%d", [self.media.likes count]];
            }
        } else if (AlertViewTagRemoveLike == alertView.tag) {
            self.btnLike.selected = YES;
            self.btnLikeMedia.selected = YES;
            
            WFIGUser *currentUser = [WFInstagramAPI currentUser];
            if (! [self.media.likes containsObject:currentUser]) {
                [self.media.likes addObject:currentUser];
                [self.likesTableView reloadData];
                self.lblLikes.text =[NSString stringWithFormat:@"%d", [self.media.likes count]];
            }
        }
    }
}

#pragma mark - CRGNewCommentViewControllerDelegate methods

- (void)newCommentViewControllerDidFinish:(CRGNewCommentViewController *)newCommentViewController
{
    [self.aNewCommentViewController willMoveToParentViewController:nil];
    [self.aNewCommentViewController.view removeFromSuperview];
    [self.aNewCommentViewController removeFromParentViewController];
}

#pragma mark - CRGPopoverViewDelegate methods

- (void)popoverView:(CRGPopoverView *)popoverView didDismissWithItemIndex:(int)index
{   
    if (0 == index) { // "Twitter"
        if ([TWTweetComposeViewController canSendTweet]) {
            [self sendTweet];
        } else {
            static NSString *message = @"You need to setup a Twitter account before tweeting.";
            UIAlertView *av = [[UIAlertView alloc]
                               initWithTitle:@"Cannot Send Tweet"
                               message:message
                               delegate:nil
                               cancelButtonTitle:@"Okay"
                               otherButtonTitles:nil];
            [av show];
        }
    } else if (1 == index) { // "Email"
        if ([MFMailComposeViewController canSendMail]) {
            [self sendMail];
        } else {
            static NSString *message = @"This device cannot send mail. If your device supports sending mail, you may need to setup an account first.";
            UIAlertView *av = [[UIAlertView alloc]
                               initWithTitle:@"Cannot Send Mail"
                               message:message
                               delegate:nil
                               cancelButtonTitle:@"Okay"
                               otherButtonTitles:nil];
            [av show];
        }
    }
}

- (void)popoverViewDidCancel:(CRGPopoverView *)popoverView { }

#pragma mark - MailComposer Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.commentsTableView)
        return [self commentsCellForRowAtIndexPath:indexPath];
    else
        return [self likesCellForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)commentsCellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *CommentsLabelCellIdentifier = @"CommentsLabelCell";
    static NSString *CellIdentifier = @"CommentCell";
    
    if (0 == indexPath.row) {
        UITableViewCell *cell = [self.commentsTableView dequeueReusableCellWithIdentifier:CommentsLabelCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentsLabelCellIdentifier];
            cell.textLabel.text = @"Comments";
            cell.textLabel.textColor = [UIColor colorWithRed:(247./255.) green:(247./255.) blue:(247./255.) alpha:1];
            cell.textLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:16.];
        }
        return cell;
    } else {
        CRGCommentCell *cell = (CRGCommentCell *)[self.commentsTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CRGCommentCell" owner:self options:nil];
            cell = (CRGCommentCell *)[nib objectAtIndex:0];
        }

        WFIGComment *comment = [self.media.comments objectAtIndex:(indexPath.row - 1)];
        [cell configureWithComment:comment];

        return cell;
    }
}

- (UITableViewCell *)likesCellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString *LikesLabelCellIdentifier = @"LikesLabelCell";
    static NSString *CellIdentifier = @"LikeCell";
    
    if (0 == indexPath.row) {
        UITableViewCell *cell = [self.likesTableView dequeueReusableCellWithIdentifier:LikesLabelCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LikesLabelCellIdentifier];
            cell.textLabel.text = @"Likes";
            cell.textLabel.textColor = [UIColor colorWithRed:(247./255.) green:(247./255.) blue:(247./255.) alpha:1];
            cell.textLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:16.];
        }
        return cell;
    } else {
        CRGLikeCell *cell = (CRGLikeCell *)[self.likesTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CRGLikeCell" owner:self options:nil];
            cell = (CRGLikeCell *)[nib objectAtIndex:0];
        }

        WFIGUser *user = self.media.likes[(indexPath.row-1)];
        [cell configureWithUser:user];
        
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!animationComplete) return 0;

    if (tableView == self.commentsTableView)
        return [[self.media comments] count] + 1;
    else 
        return [[self.media likes] count] + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.row) return 26.;
    
    if (tableView == self.commentsTableView) {
        WFIGComment *comment = [self.media.comments objectAtIndex:(indexPath.row - 1)];
        return [CRGCommentCell cellHeightWithCommentText:[comment text]];
    } else {
        return 54.;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
