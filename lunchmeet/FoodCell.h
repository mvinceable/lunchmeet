//
//  FoodCell.h
//  Lunchmeet
//
//  Created by Vince Magistrado on 11/13/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FoodCellDelegate <NSObject>

- (void)voteChangedForItem:(NSString *)itemId vote:(NSInteger)count up:(BOOL)up;

@end

@interface FoodCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *item;
@property (strong, nonatomic) NSDictionary *votes;

@property (nonatomic, weak) id <FoodCellDelegate> delegate;

@end
