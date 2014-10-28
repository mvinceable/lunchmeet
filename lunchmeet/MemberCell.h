//
//  MemberCell.h
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MemberCell;

@protocol MemberCellDelegate <NSObject>

- (void)removeMemberCell:(MemberCell *)memberCell;

@end;

@interface MemberCell : UITableViewCell

@property (strong, nonatomic) NSString *name;

- (NSString *)getName;
- (void)makeFirstResponder;

@property (nonatomic, weak) id <MemberCellDelegate> delegate;

@end