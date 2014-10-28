//
//  GroupDetailsCell.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "GroupDetailsCell.h"

@interface GroupDetailsCell()

@property (weak, nonatomic) IBOutlet UITextField *nameTextfield;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextview;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeightConstraint;

@end

@implementation GroupDetailsCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setGroup:(Group *)group {
    _group = group;
    
    self.nameTextfield.text = group.name;
    self.descriptionTextview.text = group.desc;
}

- (NSString *)getName {
    return self.nameTextfield.text;
}

- (NSString *)getDesc {
    return self.descriptionTextview.text;
}

- (IBAction)onDescription:(id)sender {
    NSLog(@"Description tapped");
    [self.descriptionTextview becomeFirstResponder];
}

@end
