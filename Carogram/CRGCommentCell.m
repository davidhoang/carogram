//
//  CRGCommentCell.m
//  Carogram
//
//  Created by Jacob Moore on 9/5/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGCommentCell.h"
#import <QuartzCore/QuartzCore.h>

#define kMinCellHeight 64.

#define kOneMinute 60.
#define kOneHour   3600.
#define kOneDay    86400.
#define kOneWeek   604800.

@interface CRGCommentCell()
- (void)loadProfilePicture;
- (NSString *)dateString;
- (void)configureCommentLabelWithText:(NSString*)commentText;
@end

@implementation CRGCommentCell
@synthesize comment = _comment;
@synthesize ivBackground = _ivBackground;
@synthesize ivUser = _ivUser;
@synthesize lblUser = _lblUser;
@synthesize lblDate = _lblDate;
@synthesize lblComment = _lblComment;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.ivBackground.image = [[UIImage imageNamed:@"comment-cell-bg"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];

    // Round avatar image view
    self.ivUser.layer.opaque = YES;
    self.ivUser.layer.masksToBounds = YES;
    self.ivUser.layer.cornerRadius = 2;
    
    // Add rounded border layer
    CALayer *roundedLayer = [CALayer layer];
    roundedLayer.frame = CGRectMake(-1, -1, self.ivUser.frame.size.width + 2, self.ivUser.frame.size.height + 2);
    roundedLayer.opaque = YES;
    roundedLayer.masksToBounds = YES;
    roundedLayer.cornerRadius = 2;
    roundedLayer.borderWidth = 2.0;
    roundedLayer.borderColor = [[UIColor colorWithRed:(69./255.) green:(73./255.) blue:(76./255.) alpha:1] CGColor];
    
    [self.ivUser.layer addSublayer:roundedLayer];
}

- (void)configureWithComment:(WFIGComment *)comment
{
    self.comment = comment;

    [self loadProfilePicture];
    
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


- (void)loadProfilePicture
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.comment.user profilePicture]]]];
        dispatch_async( dispatch_get_main_queue(), ^{
            if (image != nil) {
                self.ivUser.image = image;
            }
        });
    });
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
*/

@end
