//
//  GroupViewController.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "GroupViewController.h"
#import "GroupDetailsCell.h"
#import "MBProgressHud.h"
#import "MemberCell.h"

@interface GroupViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstraint;
@property (strong, nonatomic) MBProgressHUD *loadingIndicator;
@property (strong, nonatomic) NSMutableArray *members;

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set cancel button
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(onStop)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    // set title text
    if (_group) {
        self.navigationItem.title = _group.name;
    } else {
        self.navigationItem.title = @"New Group";
    }
    
    // add '+' button icon
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onDone)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    // register table cell nibs
    [self.tableview registerNib:[UINib nibWithNibName:@"GroupDetailsCell" bundle:nil] forCellReuseIdentifier:@"GroupDetailsCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"MemberCell" bundle:nil] forCellReuseIdentifier:@"MemberCell"];

    // setup delegates
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.tableview.estimatedRowHeight = 150;
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    
    self.members = [NSMutableArray array];
    
    // listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
        default:
            return self.members.count + 1;    // first one will be add member button
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        GroupDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupDetailsCell"];
        cell.group = _group;
        return cell;
    } else {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] init];
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
            cell.textLabel.text = @"+ add member";
            return cell;
        } else {
            MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MemberCell"];
            NSString *username = self.members[indexPath.row - 1];
            cell.name = username;
            cell.delegate = self;
            
            // make newly added cell first responder
            if ([username isEqualToString:@""] && indexPath.row == 1) {
                [cell makeFirstResponder];
            }
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // unhighlight selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        // add member clicked
        NSLog(@"adding member");
        [self addMember];
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    headerView.backgroundColor = [UIColor colorWithWhite:.9 alpha:.9];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 320, 50)];
    switch (section) {
        case 0:
            headerLabel.text = @"Group Details";
            break;
        case 1:
        default:
            headerLabel.text = @"Members";
            break;
    }
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    headerLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

- (void)onStop {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onDone {
    [self syncNames];
    
    GroupDetailsCell *gdc = (GroupDetailsCell *)[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // validate name
    NSString *name = [gdc getName];
    NSString *trimmedName = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([trimmedName isEqualToString:@""]) {
        // it's empty or contains only white spaces
        [[[UIAlertView alloc] initWithTitle:@"Please enter a group name" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        self.loadingIndicator = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // save existing group
        if (_group) {
            NSLog(@"Saving existing group");
            
            _group.name = trimmedName;
            _group.desc = [gdc getDesc];
            _group.members = self.members;
            
            [_group saveExistingGroupWithCompletion:^(NSString *objectId, NSError *error) {
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"There was an error saving the group" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [self.loadingIndicator hide:YES];
                } else {
                    NSLog(@"Group changes saved with id %@", objectId);
                    [self.loadingIndicator hide:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        } else {
            // store new group and them dismiss
            NSLog(@"Saving new group");
            NSDictionary *dictionary = @{
                           @"name": trimmedName,
                           @"description": [gdc getDesc],
                           @"members": self.members
                           };
            
            Group *group = [[Group alloc] initWithDictionary:dictionary];
            
            [group saveNewGroupWithCompletion:^(NSString *objectId, NSError *error) {
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"There was an error creating the group" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    [self.loadingIndicator hide:YES];
                } else {
                    NSLog(@"Group saved with id %@", objectId);
                    [self.loadingIndicator hide:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }
}

- (void)addMember {
    [self syncNames];
    [self.members insertObject:@"" atIndex:0];
}

- (void)removeMemberCell:(MemberCell *)memberCell {
    // sync names so refresh works
    [self syncNames];
    
    NSIndexPath *indexPath = [self.tableview indexPathForCell:memberCell];
    [self.members removeObjectAtIndex:indexPath.row - 1];
    [self.tableview reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)syncNames {
    for (int i = 0; i < self.members.count; i++) {
        MemberCell *cell = (MemberCell *)[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i + 1 inSection:1]];
        if (cell) {
            [self.members replaceObjectAtIndex:i withObject:[cell getName]];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"Keyboard will show for group");
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    [UIView animateWithDuration:.24 animations:^{
        self.tableBottomConstraint.constant = keyboardFrameEndRect.size.height;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSLog(@"Keyboard hidden");
    [UIView animateWithDuration:.24 animations:^{
        self.tableBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void)setGroup:(Group *)group {
    _group = group;
    
    // load members for the group
    self.loadingIndicator = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [_group getGroupMembersWithCompletion:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu members.", (unsigned long)objects.count);
            for (PFObject *object in objects) {
                [self.members addObject:object[@"username"]];
            }
            [self.tableview reloadData];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            [[[UIAlertView alloc] initWithTitle:@"Failed to get group members" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            // disable saving since we're in a bad state
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        [self.loadingIndicator hide:YES];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
