//
//  CRGProfileGridViewController.m
//  Carogram
//
//  Created by Jacob Moore on 3/14/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGProfileGridViewController.h"
#import "CRGImageGridViewCell.h"
#import "UIImageView+WebCache.h"
#import "CRGFullGridViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImageView+WebCache.h"
#import "UIFont+Carogram.h"
#import "WFIGRelationship.h"

#define kNumberOfColumns  3
#define kInfoViewWidth    280.

static int userRelationshipObserverContext;

@interface CRGProfileGridViewController ()
@property (strong, nonatomic) UIView *profileBackground;
@property (strong, nonatomic) UIView *profileView;
@property (strong, nonatomic) UIImageView *headerImageView;
@property (strong, nonatomic) NSArray *gridCells;
@property (strong, nonatomic) UILabel *photosCountLabel;
@property (strong, nonatomic) UILabel *followingCountLabel;
@property (strong, nonatomic) UILabel *followersCountLabel;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UILabel *fullNameLabel;
@property (strong, nonatomic) UILabel *bioLabel;
@property (strong, nonatomic) UIButton *websiteButton;
@property (strong, nonatomic) UIButton *followButton;
@property (strong, nonatomic) UILabel *privateUserLabel;
@end

@implementation CRGProfileGridViewController {
    BOOL _firstTimeAppearing;
}

- (id)initWithUser:(WFIGUser *)user mediaCollection:(WFIGMediaCollection *)mediaCollection atPage:(int)aPage
{
    self = [super initWithMediaCollection:mediaCollection atPage:aPage];
    if (self) {
        _user = user;
        _firstTimeAppearing = YES;
        
        if (_user) {
            [_user addObserver:self
                    forKeyPath:@"relationship"
                       options:NSKeyValueObservingOptionNew
                       context:&userRelationshipObserverContext];
        }
    }
    return self;
}

- (id)initWithMediaCollection:(WFIGMediaCollection *)mediaCollection atPage:(int)aPage
{
    self = [super initWithMediaCollection:mediaCollection atPage:aPage];
    if (self) {
        _user = nil;
        _firstTimeAppearing = YES;
    }
    return self;
}

- (void)dealloc
{
    self.user = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupProfileBackground];
    [self setupFirstMedia];
    [self setupProfileView];

    [self initGrid];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_firstTimeAppearing) {
        _firstTimeAppearing = NO;
        
        if (self.user.relationship) {
            [self configureWithRelationship:self.user.relationship];
        }
    }
}

- (void)setupProfileBackground
{
    self.profileBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 29, kInfoViewWidth, 660)];
    
    UIImage *patternImage = [UIImage imageNamed:@"profile-bg-tile"];
    self.profileBackground.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    
    // Add white stroke
    self.profileBackground.layer.borderWidth = 1. / [UIScreen mainScreen].scale;
    self.profileBackground.layer.borderColor = [UIColor whiteColor].CGColor;

    // Add shadow
    self.profileBackground.layer.shadowOpacity = 1;
    self.profileBackground.layer.shadowOffset = CGSizeMake(0, 1);
    self.profileBackground.layer.shadowRadius = 5;

    [self.view addSubview:self.profileBackground];
}

- (void)setupProfileView
{
    self.profileView = [[UIView alloc] initWithFrame:CGRectMake(0, 29, kInfoViewWidth, 660)];
    self.profileView.backgroundColor = [UIColor clearColor];
    
    // Add profile image background
    UIView *profileImageBackground = [[UIView alloc] initWithFrame:CGRectMake(15, 231, 100, 100)];
    profileImageBackground.backgroundColor = [UIColor whiteColor];
    profileImageBackground.layer.shadowOpacity = 1;
    profileImageBackground.layer.shadowOffset = CGSizeMake(0,1);
    profileImageBackground.layer.shadowRadius = 1;
    [self.profileView addSubview:profileImageBackground];

    UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 234, 94, 94)];
    [profileImageView setImageWithURL:[NSURL URLWithString:self.user.profilePicture]];
    [self.profileView addSubview:profileImageView];

    // Add follow/unfollow button
    self.followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.followButton.frame = CGRectMake(125, 289, 142, 43);
    self.followButton.titleLabel.font = [UIFont gothamBoldFontOfSize:18];
    self.followButton.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
    self.followButton.titleLabel.shadowColor = [UIColor grayColor];
    self.followButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [self.followButton addTarget:self action:@selector(updateRelationship:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.user.instagramId isEqualToString:[WFInstagramAPI currentUser].instagramId]) {
        self.followButton.hidden = YES;
    }
    
    [self.profileView addSubview:self.followButton];

    // Add follower counts
    UIImageView *followersBackground = [[UIImageView alloc] initWithFrame:CGRectMake(14, 346, 252, 53)];
    followersBackground.image = [UIImage imageNamed:@"profile-followers-bg"];
    [self.profileView addSubview:followersBackground];

    self.photosCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 360, 82, 20)];
    self.photosCountLabel.textAlignment = UITextAlignmentCenter;
    self.photosCountLabel.backgroundColor = [UIColor clearColor];
    self.photosCountLabel.textColor = [UIColor colorWithRed:(51./255.) green:(51./255.) blue:(51./255.) alpha:1];
    self.photosCountLabel.font = [UIFont defaultFontOfSize:18];
    self.photosCountLabel.text = [self.user.mediaCount stringValue];
    [self.profileView addSubview:self.photosCountLabel];
    
    UILabel *photosLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 376, 82, 15)];
    photosLabel.textAlignment = UITextAlignmentCenter;
    photosLabel.backgroundColor = [UIColor clearColor];
    photosLabel.textColor = [UIColor colorWithRed:(102./255.) green:(102./255.) blue:(102./255.) alpha:1];
    photosLabel.font = [UIFont defaultFontOfSize:10];
    photosLabel.text = @"photos";
    [self.profileView addSubview:photosLabel];

    self.followingCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(99, 360, 82, 20)];
    self.followingCountLabel.textAlignment = UITextAlignmentCenter;
    self.followingCountLabel.backgroundColor = [UIColor clearColor];
    self.followingCountLabel.textColor = [UIColor colorWithRed:(51./255.) green:(51./255.) blue:(51./255.) alpha:1];
    self.followingCountLabel.font = [UIFont defaultFontOfSize:18];
    self.followingCountLabel.text = [self.user.followsCount stringValue];
    [self.profileView addSubview:self.followingCountLabel];
    
    UILabel *followingLabel = [[UILabel alloc] initWithFrame:CGRectMake(99, 376, 82, 15)];
    followingLabel.textAlignment = UITextAlignmentCenter;
    followingLabel.backgroundColor = [UIColor clearColor];
    followingLabel.textColor = [UIColor colorWithRed:(102./255.) green:(102./255.) blue:(102./255.) alpha:1];
    followingLabel.font = [UIFont defaultFontOfSize:10];
    followingLabel.text = @"following";
    [self.profileView addSubview:followingLabel];

    self.followersCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(183, 360, 82, 20)];
    self.followersCountLabel.textAlignment = UITextAlignmentCenter;
    self.followersCountLabel.backgroundColor = [UIColor clearColor];
    self.followersCountLabel.textColor = [UIColor colorWithRed:(51./255.) green:(51./255.) blue:(51./255.) alpha:1];
    self.followersCountLabel.font = [UIFont defaultFontOfSize:18];
    self.followersCountLabel.text = [self.user.followedByCount stringValue];
    [self.profileView addSubview:self.followersCountLabel];
    
    UILabel *followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(183, 376, 82, 15)];
    followersLabel.textAlignment = UITextAlignmentCenter;
    followersLabel.backgroundColor = [UIColor clearColor];
    followersLabel.textColor = [UIColor colorWithRed:(102./255.) green:(102./255.) blue:(102./255.) alpha:1];
    followersLabel.font = [UIFont defaultFontOfSize:10];
    followersLabel.text = @"followers";
    [self.profileView addSubview:followersLabel];

    // Add username
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 420, kInfoViewWidth-4, 30)];
    self.usernameLabel.adjustsFontSizeToFitWidth = YES;
    self.usernameLabel.textAlignment = UITextAlignmentCenter;
    self.usernameLabel.backgroundColor = [UIColor clearColor];
    self.usernameLabel.textColor = [UIColor colorWithRed:(51./255.) green:(51./255.) blue:(51./255.) alpha:1];
    self.usernameLabel.font = [UIFont defaultFontOfSize:30];
    self.usernameLabel.text = self.user.username;
    [self.profileView addSubview:self.usernameLabel];

    // Add full name
    self.fullNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 457, kInfoViewWidth-4, 24)];
    self.fullNameLabel.adjustsFontSizeToFitWidth = YES;
    self.fullNameLabel.textAlignment = UITextAlignmentCenter;
    self.fullNameLabel.backgroundColor = [UIColor clearColor];
    self.fullNameLabel.textColor = [UIColor colorWithRed:(51./255.) green:(51./255.) blue:(51./255.) alpha:1];
    self.fullNameLabel.font = [UIFont gothamBookFontOfSize:18];
    self.fullNameLabel.text = self.user.fullName;
    [self.profileView addSubview:self.fullNameLabel];

    // Add bio
    self.bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 480, kInfoViewWidth-8, 134)];
    self.bioLabel.numberOfLines = 5;
    self.bioLabel.textAlignment = UITextAlignmentCenter;
    self.bioLabel.backgroundColor = [UIColor clearColor];
    self.bioLabel.textColor = [UIColor colorWithRed:(102./255.) green:(102./255.) blue:(102./255.) alpha:1];
    self.bioLabel.font = [UIFont gothamBookFontOfSize:18];
    self.bioLabel.text = self.user.bio;
    [self.profileView addSubview:self.bioLabel];
    
    // Add website button
    self.websiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.websiteButton.frame = CGRectMake(4, 620, kInfoViewWidth-8, 24);
    self.websiteButton.titleLabel.textColor = [UIColor colorWithRed:(102./255.) green:(102./255.) blue:(102./255.) alpha:1];
    self.websiteButton.titleLabel.font = [UIFont gothamBookFontOfSize:18];
    [self.websiteButton setTitleColor:[UIColor colorWithRed:(102./255.) green:(102./255.) blue:(102./255.) alpha:1] forState:UIControlStateNormal];
    [self.websiteButton setTitleColor:[UIColor colorWithRed:(51./255.) green:(51./255.) blue:(51./255.) alpha:1] forState:UIControlStateHighlighted];
    [self.websiteButton setTitle:self.user.website forState:UIControlStateNormal];
    [self.websiteButton addTarget:self action:@selector(viewWebsite:) forControlEvents:UIControlEventTouchUpInside];
    [self.profileView addSubview:self.websiteButton];

    [self.view addSubview:self.profileView];
}

- (void)setupFirstMedia
{
    CGRect firstMediaFrame = CGRectMake(0, 29, kInfoViewWidth, kInfoViewWidth);
    WFIGMedia *firstMedia = [self.mediaCollection objectAtIndex:0];
    NSURL *imageURL = [NSURL URLWithString:[firstMedia lowResolutionURL]];
    self.headerImageView = [[UIImageView alloc] initWithFrame:firstMediaFrame];
    [self.headerImageView setImageWithURL:imageURL];

    // Add separator
    CALayer *separatorLayer = [CALayer layer];
    separatorLayer.frame = CGRectMake(0, kInfoViewWidth - 5, kInfoViewWidth, 5);
    separatorLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:.5].CGColor;
    [self.headerImageView.layer addSublayer:separatorLayer];

    [self.view addSubview:self.headerImageView];

    // Add invisible button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = firstMediaFrame;
    btn.tag = 0;
    [btn addTarget:self action:@selector(touchCell:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)configureProfileView
{
    self.photosCountLabel.text = [self.user.mediaCount stringValue];
    self.followingCountLabel.text = [self.user.followsCount stringValue];
    self.followersCountLabel.text = [self.user.followedByCount stringValue];
    self.usernameLabel.text = self.user.username;
    self.fullNameLabel.text = self.user.fullName;
    self.bioLabel.text = self.user.bio;
    [self.websiteButton setTitle:self.user.website forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (&userRelationshipObserverContext == context) {
        WFIGRelationship *relationship = (WFIGRelationship *)change[NSKeyValueChangeNewKey];
        [self configureWithRelationship:relationship];
    }  else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setUser:(WFIGUser *)user
{
    if (_user) {
        [_user removeObserver:self
                   forKeyPath:@"relationship"
                      context:&userRelationshipObserverContext];
    }
    
    _user = user;

    if (_user) {
        [_user addObserver:self
                forKeyPath:@"relationship"
                   options:NSKeyValueObservingOptionNew
                   context:&userRelationshipObserverContext];
    }
    
    [self configureProfileView];
    
    if (_user.relationship) [self configureWithRelationship:_user.relationship];
}

- (void)initGrid
{
    NSMutableArray *cells = [[NSMutableArray alloc] initWithCapacity:kProfileGridCount];
    for (int i = 1; i < kProfileGridCount; i++) {
        int index = i + (self.page * kProfileGridCount);
        if (index >= [self.mediaCollection count]) {
            self.gridFull = NO;
            break;
        } else if (i == (kProfileGridCount - 1)) {
            self.gridFull = YES;
        }
        
        WFIGMedia *media = [self.mediaCollection objectAtIndex:index];
        
        int gridIndex = i - 1;
        int x = 295 + ((gridIndex % kNumberOfColumns) * 244);
        int y = 29 + ((gridIndex / kNumberOfColumns) * 230);
        
        CGRect frame = CGRectMake(x, y, 200, 200);
        CRGImageGridViewCell *cell = [[CRGImageGridViewCell alloc] initWithMedia:media frame:frame];
        [cells addObject:cell];
        [self.view addSubview:cell];
        
        // Add invisible button
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = frame;
        btn.tag = i;
        [btn addTarget:self action:@selector(touchCell:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    self.gridCells = cells;
}

- (void)configureWithRelationship:(WFIGRelationship *)relationship
{
    if (! relationship) {
        [self configureFollowButtonWithOutgoingStatus:WFIGOutgoingStatusUnknown];
        return;
    }
    
    [self configureFollowButtonWithOutgoingStatus:relationship.outgoingStatus];
    
    if (relationship.isPrivate) {
        [self showPrivateUserLabel];
    } else {
        if (! [self.user hasBasicInfo]) {
            [self.user loadBasicInfoWithCompletion:^(WFIGUser *user, NSError *error) {
                [self configureProfileView];
            }];
        }
    }
}

- (void)configureFollowButtonWithOutgoingStatus:(WFIGOutgoingStatus)outgoingStatus
{
    switch (outgoingStatus) {
        case WFIGOutgoingStatusUnknown: {
            UIImage *followButtonBgImage = [[UIImage imageNamed:@"btn-loading-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
            [self.followButton setBackgroundImage:followButtonBgImage forState:UIControlStateDisabled];
            [self.followButton setTitle:@"Loading" forState:UIControlStateDisabled];
            [self.followButton setTitleColor:[UIColor colorWithWhite:.9 alpha:1] forState:UIControlStateDisabled];
            self.followButton.enabled = NO;
            break;
        }
        case WFIGOutgoingStatusNone: {
            UIImage *followButtonBgImage = [[UIImage imageNamed:@"btn-follow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
            [self.followButton setBackgroundImage:followButtonBgImage forState:UIControlStateNormal];
            [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
            [self.followButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
            self.followButton.enabled = YES;
            break;
        }
        case WFIGOutgoingStatusFollows: {
            UIImage *followButtonBgImage = [[UIImage imageNamed:@"btn-unfollow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
            [self.followButton setBackgroundImage:followButtonBgImage forState:UIControlStateNormal];
            [self.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
            [self.followButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
            self.followButton.enabled = YES;
            break;
        }
        case WFIGOutgoingStatusRequested: {
            UIImage *followButtonBgImage = [[UIImage imageNamed:@"btn-loading-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
            [self.followButton setBackgroundImage:followButtonBgImage forState:UIControlStateNormal];
            [self.followButton setTitle:@"Requested" forState:UIControlStateNormal];
            [self.followButton setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
            self.followButton.enabled = YES;
            break;
        }
        default:
            break;
    }
}

- (void)showPrivateUserLabel
{
    float width = 200.;
    float height = 32;
    int x = kInfoViewWidth + ((self.view.frame.size.width-kInfoViewWidth)/2.) - (width/2.);
    int y = self.view.frame.size.height/2. - height/2.;
    self.privateUserLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
    self.privateUserLabel.textAlignment = UITextAlignmentCenter;
    self.privateUserLabel.textColor = [UIColor whiteColor];
    self.privateUserLabel.backgroundColor = [UIColor clearColor];
    self.privateUserLabel.font = [UIFont gothamBookFontOfSize:20];
    self.privateUserLabel.text = @"This user is private.";
    [self.view addSubview:self.privateUserLabel];
}

- (void)touchCell:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMedia:fromRect:)]) {
        UIButton *btn = (UIButton *)sender;
        int tag = btn.tag;
        int index = tag + (self.page * kGridCount);
        
        [self.delegate didSelectMedia:[self.mediaCollection objectAtIndex:index] fromRect:btn.frame];
    }
}

- (void)viewWebsite:(id)sender
{
    if ([self.user.website length]) {
        NSURL *url = [NSURL URLWithString:self.user.website];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)updateRelationship:(id)sender
{
    WFIGRelationshipAction action;
    switch (self.user.relationship.outgoingStatus) {
        case WFIGOutgoingStatusNone: {
            if (self.user.relationship.isPrivate) {
                [self configureFollowButtonWithOutgoingStatus:WFIGOutgoingStatusRequested];
            } else {
                [self configureFollowButtonWithOutgoingStatus:WFIGOutgoingStatusFollows];
            }
            action = WFIGRelationshipActionFollow;
            break;
        }
        case WFIGOutgoingStatusFollows: {
            [self configureFollowButtonWithOutgoingStatus:WFIGOutgoingStatusNone];
            action = WFIGRelationshipActionUnfollow;
            break;
        }
        case WFIGOutgoingStatusRequested: {
            [self configureFollowButtonWithOutgoingStatus:WFIGOutgoingStatusNone];
            action = WFIGRelationshipActionUnfollow;
            break;
        }
        default:
            return;
    }
    
    [self.user updateRelationship:action withCompletion:^(WFIGUser *user, WFIGRelationship *relationship, NSError *error) {
        [self configureWithRelationship:relationship];
        // TODO: update user feed
    }];
}

#pragma mark - CRGGridViewController protocol

+ (int)pageCountWithMediaCount:(int)mediaCount
{
    return ceil((double)(mediaCount + 2) / (double)kGridCount);
}

- (int)indexOfMediaAtPoint:(CGPoint)point
{
    if (point.x < kInfoViewWidth) return 0;

    float columnDivisor = (self.view.bounds.size.width - kInfoViewWidth) / kNumberOfColumns;
    int column = (int)((point.x - kInfoViewWidth) / columnDivisor);

    float rowDivisor = self.view.bounds.size.height / ((kGridCount-1)/kNumberOfColumns);
    int row = (int)(point.y / rowDivisor);

    int index = row * kNumberOfColumns + column + 1;
    if (index >= kProfileGridCount) index = kProfileGridCount - 1;
    return index;
}

- (UIView *)gridCellAtPoint:(CGPoint)point
{
    if (point.x < kInfoViewWidth) return self.headerImageView;

    float columnDivisor = (self.view.bounds.size.width - kInfoViewWidth) / kNumberOfColumns;
    int column = (int)((point.x - kInfoViewWidth) / columnDivisor);
    
    float rowDivisor = self.view.bounds.size.height / ((kGridCount-1)/kNumberOfColumns);
    int row = (int)(point.y / rowDivisor);
    
    int index = row * kNumberOfColumns + column;
    if (index >= [self.gridCells count]) return nil;
    return self.gridCells[index];
}

- (UIView *)gridCellAtIndex:(int)index
{
    if (index < 0 || index > [self.gridCells count]) return nil;
    if (index == 0) return self.headerImageView;
    return self.gridCells[index - 1];
}

- (void)setFocusIndex:(int)focusIndex
{
    [super setFocusIndex:focusIndex];
    
    if (focusIndex == 0) [self.view bringSubviewToFront:self.headerImageView];
    else if (focusIndex > 0 && focusIndex <= [self.gridCells count]) {
        [self.view bringSubviewToFront:self.gridCells[focusIndex-1]];
    }
}

- (void)setPeripheryAlpha:(CGFloat)peripheryAlpha
{
    [super setPeripheryAlpha:peripheryAlpha];

    if (self.focusIndex != 0) self.headerImageView.alpha = peripheryAlpha;

    self.profileBackground.alpha = peripheryAlpha;
    self.profileView.alpha = peripheryAlpha;

    for (int i = 0; i < [self.gridCells count]; i++) {
        if ((i + 1) == self.focusIndex) continue;
        UIView *gridCell = self.gridCells[i];
        gridCell.alpha = peripheryAlpha;
    }
    
    if (peripheryAlpha == 1) {
        [self.view bringSubviewToFront:self.profileView];
    } else {
        if (self.focusIndex == 0) [self.view bringSubviewToFront:self.headerImageView];
        else if (self.focusIndex > 0 && self.focusIndex <= [self.gridCells count]) {
            [self.view bringSubviewToFront:self.gridCells[self.focusIndex-1]];
        }
    }
}

@end
