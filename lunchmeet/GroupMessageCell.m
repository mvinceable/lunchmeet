//
//  GroupMessageCell.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/27/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "GroupMessageCell.h"
#import "Group.h"

@interface GroupMessageCell()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;

@end

@implementation GroupMessageCell

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
    if ([message[@"isPin"] boolValue]) {
        self.pinImageView.hidden = NO;
    } else {
        self.pinImageView.hidden = YES;
    }
}


@end
