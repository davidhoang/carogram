//
//  CRGCommentCell.m
//  Carogram
//
//  Created by Jacob Moore on 9/5/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGCommentCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SDWebImageManager.h"

#define kMinCellHeight 64.

#define kOneMinute 60.
#define kOneHour   3600.
#define kOneDay    86400.
#define kOneWeek   604800.

@interface CRGCommentCell()
@property (strong, nonatomic) IBOutlet UIButton *userButton;
- (NSString *)dateString;
- (void)configureCommentLabelWithText:(NSString*)commentText;
@end

@implementation CRGCommentCell
@synthesize comment = _comment;
@synthesize lblUser = _lblUser;
@synthesize lblDate = _lblDate;
@synthesize lblComment = _lblComment;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Add rounded border layer
    CALayer *roundedLayer = [CALayer layer];
    roundedLayer.frame = CGRectInset(self.userButton.bounds, -1, -1);
    roundedLayer.opaque = YES;
    roundedLayer.borderWidth = 1;
    roundedLayer.borderColor = [[UIColor colorWithRed:(72./255.) green:(67./255.) blue:(67./255.) alpha:1] CGColor];
    
    [self.userButton.layer addSublayer:roundedLayer];
}

- (void)configureWithComment:(WFIGComment *)comment
{
    self.comment = comment;
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:[NSURL URLWithString:self.comment.user.profilePicture] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        if (image) {
            [self.userButton setBackgroundImage:image forState:UIControlStateNormal];
        }
    }];
    
    self.lblUser.text = [self.comment.user username];
    self.lblDate.text = [self dateString];

    [self configureCommentLabelWithText:[self.comment text]];
    self.lblComment.text = [self.comment text];
}

- (NSString *)dateString
{
    NSString *dateString;
    NSTimeInterval elapsed = -[self.comment.createdTime timeIntervalSinceNow];
    if (elapsed < kOneMinute) {
        dateString = [NSString stringWithFormat:@"%ds", (int)elapsed];
    } else if (elapsed < kOneHour) {
        dateString = [NSString stringWithFormat:@"%dm", (int)(elapsed/kOneMinute)];
    } else if (elapsed < kOneDay) {
        dateString = [NSString stringWithFormat:@"%dh", (int)(elapsed/kOneHour)];
    } else if (elapsed < kOneWeek) {
        dateString = [NSString stringWithFormat:@"%dd", (int)(elapsed/kOneDay)];
    } else {
        dateString = [NSString stringWithFormat:@"%dw", (int)(elapsed/kOneWeek)];
    }
    return dateString;
}

- (void)configureCommentLabelWithText:(NSString*)commentText
{
    // configure label size
    CGSize maxCommentSize = CGSizeMake(self.lblComment.frame.size.width, 9999);
    CGSize commentSize = [commentText sizeWithFont:self.lblComment.font 
                                 constrainedToSize:maxCommentSize
                                     lineBreakMode:UILineBreakModeWordWrap];
    CGRect commentFrame = self.lblComment.frame;
    commentFrame.size.height = commentSize.height;
    self.lblComment.frame = commentFrame;
}

+ (int)cellHeightWithCommentText:(NSString*)commentText
{
    // font should match lblComment font in nib
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    
    // width should match lblComment width in nib
    int width = 218;
    
    CGSize maxCommentSize = CGSizeMake(width, 9999);
    CGSize commentSize = [commentText sizeWithFont:font 
                                 constrainedToSize:maxCommentSize
                                     lineBreakMode:UILineBreakModeWordWrap];

    return MAX((commentSize.height + 31), kMinCellHeight);
}

- (IBAction)viewProfile:(id)sender {
    [self.delegate tableViewCell:self didSelectUser:self.comment.user];
}

@end
