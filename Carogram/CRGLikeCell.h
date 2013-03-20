//
//  CRGLikeCell.h
//  Carogram
//
//  Created by Jacob Moore on 2/22/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRGUserTableViewCellDelegate.h"

@interface CRGLikeCell : UITableViewCell
@property (weak, nonatomic) id<CRGUserTableViewCellDelegate> delegate;
- (void)configureWithUser:(WFIGUser *)user;
@end
