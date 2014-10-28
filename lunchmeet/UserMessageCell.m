//
//  UserMessageCell.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/27/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "UserMessageCell.h"
#import "Group.h"

@interface UserMessageCell()

@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;

@end

@implementation UserMessageCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessage:(PFObject *)message {
    _message = message;
    self.timestampLabel.text = [Group friendlyTimestamp:message.createdAt];
    self.messageLabel.text = message[@"message"];
    self.userLabel.text = message[@"username"];
}

@end
