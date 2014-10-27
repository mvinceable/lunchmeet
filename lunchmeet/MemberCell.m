//
//  MemberCell.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "MemberCell.h"

@interface MemberCell()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;

@end

@implementation MemberCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString *)name {
    self.usernameTextfield.text = name;
}

- (NSString *)getName {
    return self.usernameTextfield.text;
}

- (void)makeFirstResponder {
    [self.usernameTextfield becomeFirstResponder];
}

- (IBAction)onRemoveCell:(id)sender {
    [self.delegeate removeMemberCell:self];
}


@end
