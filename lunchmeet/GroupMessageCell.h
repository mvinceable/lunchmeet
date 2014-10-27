//
//  GroupMessageCell.h
//  lunchmeet
//
//  Created by Vince Magistrado on 10/27/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface GroupMessageCell : UITableViewCell

@property (strong, nonatomic) PFObject *message;

@end
