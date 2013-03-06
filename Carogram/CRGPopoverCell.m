//
//  CRGPopoverCell.m
//  Carogram
//
//  Created by Jacob Moore on 3/5/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import "CRGPopoverCell.h"
#import "UIFont+Carogram.h"

@interface CRGPopoverCell()
@end

@implementation CRGPopoverCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15., 10., self.frame.size.width - 20., 30.)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont defaultFontOfSize:18];
        _titleLabel.textColor = [UIColor colorWithWhite:.2 alpha:1];
        [self addSubview:_titleLabel];
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.titleLabel.frame = CGRectMake(15., 10., self.frame.size.width - 20., 30.);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellType:(CellType)cellType
{
    _cellType = cellType;
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    backgroundImageView.image = [[self class] backgroundImageForCellType:cellType];
    self.backgroundView = backgroundImageView;
    
    UIImageView *selectedBackgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    selectedBackgroundImageView.image = [[self class] selectedBackgroundImageForCellType:cellType];
    self.selectedBackgroundView = selectedBackgroundImageView;
}

+ (UIImage *)backgroundImageForCellType:(CellType)cellType
{
    if (CellTypeTop == cellType) return [[UIImage imageNamed:@"popover-top-cell-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 2, 5)];
    else if (CellTypeMiddle == cellType) return [[UIImage imageNamed:@"popover-middle-cell-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    else return [[UIImage imageNamed:@"popover-bottom-cell-bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 5, 4, 5)];
}

+ (UIImage *)selectedBackgroundImageForCellType:(CellType)cellType
{
    if (CellTypeTop == cellType) return [[UIImage imageNamed:@"popover-top-cell-bg-selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(4, 5, 2, 5)];
    else if (CellTypeMiddle == cellType) return [[UIImage imageNamed:@"popover-middle-cell-bg-selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    else return [[UIImage imageNamed:@"popover-bottom-cell-bg-selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 5, 4, 5)];
}

@end
