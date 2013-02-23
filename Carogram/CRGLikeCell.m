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

@interface CRGLikeCell()
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *fullNameLabel;
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
    
    self.userImageView.layer.borderColor = [UIColor colorWithRed:(72./255.) green:(67./255.) blue:(67./255.) alpha:1].CGColor;
    self.userImageView.layer.borderWidth = 1;
    
    self.usernameLabel.font = [UIFont defaultFontOfSize:14];
    self.fullNameLabel.font = [UIFont gothamBookFontOfSize:11];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)configureWithUser:(WFIGUser *)user
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[user profilePicture]]]];
        dispatch_async( dispatch_get_main_queue(), ^{
            if (image != nil) {
                self.userImageView.image = image;
            }
        });
    });
    
    self.usernameLabel.text = user.username;
    self.fullNameLabel.text = user.fullName;
}

@end
