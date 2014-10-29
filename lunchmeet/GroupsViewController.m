//
//  GroupsViewController.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "GroupsViewController.h"
#import <Parse/Parse.h>
#import "GroupCell.h"
#import "Group.h"
#import "MBProgressHud.h"
#import "GroupViewController.h"
#import "ChatViewController.h"

@interface GroupsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) UIRefreshControl *refreshTweetsControl;
@property (strong, nonatomic) MBProgressHUD *loadingIndicator;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set logout button
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(onStop)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    // set title text
    self.navigationItem.title = @"Lunchmeets";
    
    // add '+' button icon
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onNew)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    // register group cell nib
    [self.tableview registerNib:[UINib nibWithNibName:@"GroupCell" bundle:nil] forCellReuseIdentifier:@"GroupCell"];

    // set delegates
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.tableview.estimatedRowHeight = 120;
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    
    // add pull to refresh tweets control
    self.refreshTweetsControl = [[UIRefreshControl alloc] init];
    [self.tableview addSubview:self.refreshTweetsControl];
    [self.refreshTweetsControl addTarget:self action:@selector(refreshGroups) forControlEvents:UIControlEventValueChanged];
    
    // show loading indicator
    self.loadingIndicator = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    // update status bar appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidAppear:(BOOL)animated {
    // sometimes the keyboard would still be present so hide it
    [self.view endEditing:YES];
    [self refreshGroups];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;//self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    
    cell.group = self.groups[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // unhighlight selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChatViewController *vc = [[ChatViewController alloc] init];
    vc.group = self.groups[indexPath.row];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)refreshGroups {
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:@"members" equalTo:user];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu groups.", (unsigned long)objects.count);
            self.groups = [Group groupsWithArray:objects];
            [self.tableview reloadData];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            [[[UIAlertView alloc] initWithTitle:@"Failed to get groups" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        [self.loadingIndicator hide:YES];
        [self.refreshTweetsControl endRefreshing];
    }];
}

- (void)onStop {
    NSLog(@"Log out");
    [PFUser logOut];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onNew {
    GroupViewController *vc = [[GroupViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [nvc.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                 NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20]
                                                 }];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (IBAction)onLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"UIGestureRecognizerStateBegan.");
        CGPoint location = [sender locationInView:self.tableview];
        NSIndexPath *indexPath = [self.tableview indexPathForRowAtPoint:location];
        NSLog(@"row is %ld", (long)indexPath.row);
        GroupViewController *vc = [[GroupViewController alloc] init];
        vc.group = self.groups[indexPath.row];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        [nvc.navigationBar setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor blackColor],
                                                     NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20]
                                                     }];
        [self presentViewController:nvc animated:YES completion:nil];
    }
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
