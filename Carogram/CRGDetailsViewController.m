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

@interface CRGDetailsViewController ()
@property (nonatomic) CGRect mediaFrame;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnShare;
@property (strong, nonatomic) CRGNewCommentViewController *aNewCommentViewController;
@property (strong, nonatomic) IBOutlet UITableView *commentsTableView;
@property (strong, nonatomic) IBOutlet UITableView *likesTableView;
@property (strong, nonatomic) IBOutlet UIButton *btnLike;
@property (strong, nonatomic) IBOutlet UIButton *btnLikeMedia;
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
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeftGesture:)];
    swipeLeftRecognizer.numberOfTouchesRequired = 1;
    swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.commentsTableView addGestureRecognizer:swipeLeftRecognizer];

    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRightGesture:)];
    swipeRightRecognizer.numberOfTouchesRequired = 1;
    swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.likesTableView addGestureRecognizer:swipeRightRecognizer];

    self.likesTableView.frame = CGRectOffset(self.likesTableView.frame, self.commentsView.frame.size.width - self.likesTableView.frame.origin.x, 0);
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)touchClose:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)newComment:(UIButton *)sender {
    self.aNewCommentViewController = (CRGNewCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier: @"NewComment"];
    self.aNewCommentViewController.delegate = self;
    self.aNewCommentViewController.media = self.media;
    
    [self addChildViewController:self.aNewCommentViewController];
    [self.view addSubview:self.aNewCommentViewController.view];
    [self.aNewCommentViewController didMoveToParentViewController:self];
}

- (IBAction)toggleLike:(UIButton *)sender {
    self.btnLike.enabled = NO;
    self.btnLike.selected = !self.btnLike.selected;
    self.btnLikeMedia.enabled = NO;
    self.btnLikeMedia.selected = !self.btnLikeMedia.selected;
    
    if (self.btnLike.selected) [self setLike];
    else [self removeLike];
}

- (void)setLike
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        BOOL success = [self.media setLikeWithError:&error];
        
        // Wait 200 milliseconds before refreshing likes
        [NSThread sleepForTimeInterval:0.2];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            if (success) {
                [self refreshLikes];
            }
            if (error) NSLog(@"Error: %@", [error description]);
        });
    });
}

- (void)removeLike
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        BOOL success = [self.media removeLikeWithError:&error];
        
        // Wait 200 milliseconds before refreshing likes
        [NSThread sleepForTimeInterval:0.2];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            if (success) {
                [self refreshLikes];
            }
            if (error) NSLog(@"Error: %@", [error description]);
        });
    });
}

- (IBAction)touchShare:(id)sender {
}

- (void)configureViews
{
    self.commentsView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"details-bg-tile"]];
    
    self.usernameLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:15.];
    self.lblCaption.font = [UIFont fontWithName:@"Gotham-Medium" size:12.];
    self.lblLikes.font = [UIFont fontWithName:@"Gotham-Medium" size:15.];
    self.lblComments.font = [UIFont fontWithName:@"Gotham-Medium" size:15.];
    
    if (nil != self.media) {
        [self.media imageCompletionBlock:^(WFIGMedia* imgMedia, UIImage *img) {
            if (imgMedia == self.media) {
                [self.ivPhoto setImage:img];
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
    if ([self.media likesCount] == 0) return;
    
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

- (void)refreshLikes
{
    [self.media allLikesWithCompletionBlock:^(WFIGMedia *likesMedia, NSArray *likes, NSError *error) {
        if (self.media == likesMedia && error == nil) {
            [self.likesTableView reloadData];
            [self.lblLikes setText:[NSString stringWithFormat:@"%d", [self.media likesCount]]];
            [self checkLikeStatus];
        }
    }];
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

#pragma mark - CRGNewCommentViewControllerDelegate methods

- (void)newCommentViewControllerDidFinish:(CRGNewCommentViewController *)newCommentViewController
{
    [self.aNewCommentViewController willMoveToParentViewController:nil];
    [self.aNewCommentViewController.view removeFromSuperview];
    [self.aNewCommentViewController removeFromParentViewController];
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
