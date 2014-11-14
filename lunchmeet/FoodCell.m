//
//  FoodCell.m
//  Lunchmeet
//
//  Created by Vince Magistrado on 11/13/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "FoodCell.h"
#import "Menu.h"

@interface FoodCell()

@property (weak, nonatomic) IBOutlet UILabel *foodLabel;
@property (weak, nonatomic) IBOutlet UILabel *foodDescription;
@property (weak, nonatomic) IBOutlet UILabel *foodStation;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;

@property (nonatomic) NSInteger likeCount;

@end

@implementation FoodCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setItem:(NSDictionary *)item {
    _item = item;
    self.foodLabel.text = item[@"label"];
    self.foodDescription.text = item[@"description"];
    self.foodStation.text = [self stringByStrippingHTML:item[@"station"]];
}

- (void)setVotes:(NSDictionary *)votes {
    self.likeCount = [votes[@"votes"] integerValue];
    self.likeLabel.text = [NSString stringWithFormat:@"%ld", (long)self.likeCount];
    if ([votes[@"iVoted"] boolValue]) {
        self.likeButton.alpha = 1;
    } else {
        self.likeButton.alpha = .5;
    }

}

- (NSString *) stringByStrippingHTML:(NSString *)s {
    NSRange r;
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}

- (IBAction)voteUp:(UIButton *)sender {
    if (sender.alpha == 1) {
        NSLog(@"Remove vote for item %@", _item[@"id"]);
        self.likeCount--;
        self.likeButton.alpha = .5;
        [[Menu sharedInstance] voteForFoodItem:NO itemId:_item[@"id"]];
        [self.delegate voteChangedForItem:_item[@"id"] vote:self.likeCount up:NO];
    } else {
        NSLog(@"Vote item %@ up", _item[@"id"]);
        self.likeCount++;
        self.likeButton.alpha = 1;
        [[Menu sharedInstance] voteForFoodItem:YES itemId:_item[@"id"]];
        [self.delegate voteChangedForItem:_item[@"id"] vote:self.likeCount up:YES];
    }
    self.likeLabel.text = [NSString stringWithFormat:@"%ld", (long)self.likeCount];
    [UIView animateWithDuration:.24 animations:^{
        [self layoutIfNeeded];
    }];
    
}

@end
