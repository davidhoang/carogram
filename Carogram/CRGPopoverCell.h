//
//  CRGPopoverCell.h
//  Carogram
//
//  Created by Jacob Moore on 3/5/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CellTypeTop,
    CellTypeMiddle,
    CellTypeBottom
} CellType;

@interface CRGPopoverCell : UITableViewCell

@property (nonatomic) CellType cellType;
@property (strong, nonatomic) UILabel *titleLabel;

@end
