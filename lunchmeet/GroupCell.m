//
//  GroupCell.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "GroupCell.h"

@interface GroupCell()

@property (weak, nonatomic) IBOutlet UILabel *groupLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupDescription;

@end

@implementation GroupCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setGroup:(Group *)group {
    self.groupLabel.text = group.name;
    self.groupDescription.text = group.desc;
}

@end
