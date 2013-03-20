//
//  CRGCommentCell.h
//  Carogram
//
//  Created by Jacob Moore on 9/5/12.
//  Copyright (c) 2012 Xhatch Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WFInstagramAPI.h"
#import "CRGUserTableViewCellDelegate.h"

@interface CRGCommentCell : UITableViewCell

@property (weak, nonatomic) id<CRGUserTableViewCellDelegate> delegate;
@property (strong, nonatomic) WFIGComment *comment;
@property (strong, nonatomic) IBOutlet UILabel *lblUser;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UILabel *lblComment;

- (void)configureWithComment:(WFIGComment *)comment;
+ (int)cellHeightWithCommentText:(NSString*)commentText;

@end
