//
//  CRGUserTableViewCellDelegate.h
//  Carogram
//
//  Created by Jacob Moore on 3/18/13.
//  Copyright (c) 2013 Xhatch Interactive, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CRGUserTableViewCellDelegate <NSObject>

- (void)tableViewCell:(UITableViewCell *)tableViewCell didSelectUser:(WFIGUser *)user;

@end
