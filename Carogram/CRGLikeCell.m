//
//  CRGLikeCell.m
//  Carogram
//
//  Created by Jacob Moore on 2/22/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGLikeCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Carogram.h"
#import "SDWebImageManager.h"

@interface CRGLikeCell()
@property (strong, nonatomic) WFIGUser *user;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *userButton;
@end

@implementation CRGLikeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) { }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.usernameLabel.font = [UIFont defaultFontOfSize:14];
    self.fullNameLabel.font = [UIFont gothamBookFontOfSize:11];
    
    // Add rounded border layer
    CALayer *roundedLayer = [CALayer layer];
    roundedLayer.frame = CGRectInset(self.userButton.bounds, -1, -1);
    roundedLayer.opaque = YES;
    roundedLayer.borderWidth = 1;
    roundedLayer.borderColor = [[UIColor colorWithRed:(72./255.) green:(67./255.) blue:(67./255.) alpha:1] CGColor];
    
    [self.userButton.layer addSublayer:roundedLayer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureWithUser:(WFIGUser *)user
{
    self.user = user;
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:[NSURL URLWithString:self.user.profilePicture] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
        if (image) {
            [self.userButton setBackgroundImage:image forState:UIControlStateNormal];
        }
    }];
    
    self.usernameLabel.text = user.username;
    self.fullNameLabel.text = user.fullName;
}

- (IBAction)viewProfile:(id)sender {
    [self.delegate tableViewCell:self didSelectUser:self.user];
}

@end
