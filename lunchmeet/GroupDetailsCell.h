//
//  GroupDetailsCell.h
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"

@class GroupDetailsCell;

@protocol GroupDetailsCellDelegate <NSObject>

- (void)groupDetailsChanged:(GroupDetailsCell *)cell;

@end

@interface GroupDetailsCell : UITableViewCell <UITextViewDelegate>

@property (strong, nonatomic) Group *group;

- (NSString *)getName;
- (NSString *)getDesc;

@property (nonatomic, weak) id <GroupDetailsCellDelegate> delegate;

@end
