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
#import "WFIGImageCache.h"

@interface CRGDetailsViewController ()
@property (nonatomic) CGRect mediaFrame;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIButton *btnShare;
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
@synthesize btnLikes = _btnLikes;
@synthesize btnComments = _btnComments;
@synthesize tableView = _tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    [self setBtnLikes:nil];
    [self setBtnComments:nil];
    [self setTableView:nil];
    [self setUsernameLabel:nil];
    [self setBtnShare:nil];
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
                         [self.tableView setHidden:NO];
                         [self.tableView reloadData];
                         [self loadComments];
                     }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.tableView setHidden:YES];
    
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

- (IBAction)touchLikes:(id)sender {
}

- (IBAction)touchComments:(id)sender {
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
    if ([self.media commentsCount] == 0) return;
    
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
                
                [self.tableView beginUpdates];
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
                [self.tableView endUpdates];
            }
        }];
    }
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CommentsLabelCellIdentifier = @"CommentsLabelCell";
    static NSString *CellIdentifier = @"CommentCell";
    
    if (0 == indexPath.row) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentsLabelCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentsLabelCellIdentifier];
            cell.textLabel.text = @"Comments";
            cell.textLabel.textColor = [UIColor colorWithRed:(247./255.) green:(247./255.) blue:(247./255.) alpha:1];
            cell.textLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:16.];
        }
        return cell;
    } else {
        CRGCommentCell *cell = (CRGCommentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CRGCommentCell" owner:self options:nil];
            cell = (CRGCommentCell *)[nib objectAtIndex:0];
        }

        WFIGComment *comment = [self.media.comments objectAtIndex:(indexPath.row - 1)];
        [cell configureWithComment:comment];

        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!animationComplete) return 0;
    return [[self.media comments] count] + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.row) return 26.;
    
    WFIGComment *comment = [self.media.comments objectAtIndex:(indexPath.row - 1)];
    return [CRGCommentCell cellHeightWithCommentText:[comment text]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
