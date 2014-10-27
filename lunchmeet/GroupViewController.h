//
//  GroupViewController.h
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Group.h"
#import "MemberCell.h"

@interface GroupViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MemberCellDelegate>

@property (strong, nonatomic) Group *group;

@end
