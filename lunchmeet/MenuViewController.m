//
//  MenuViewController.m
//  Lunchmeet
//
//  Created by Vince Magistrado on 11/13/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "MenuViewController.h"
#import "Menu.h"
#import "FoodCell.h"
#import "MBProgressHud.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, FoodCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *cafeSegmentedControl;

@property (strong, nonatomic) NSDictionary *cafeInfo;
@property (strong, nonatomic) MBProgressHUD *loadingIndicator;
@property (strong, nonatomic) UIRefreshControl *refreshMenuControl;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.cafeSegmentedControl sizeToFit];
    self.navigationItem.titleView = self.cafeSegmentedControl;
    
    // setup delegates
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 200;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // register nib
    [self.tableView registerNib:[UINib nibWithNibName:@"FoodCell" bundle:nil] forCellReuseIdentifier:@"FoodCell"];
    
    self.cafeInfo = [NSDictionary dictionary];
    [self loadMenu];
    
    // add pull to refresh tweets control
    self.refreshMenuControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshMenuControl];
    [self.refreshMenuControl addTarget:self action:@selector(loadMenu) forControlEvents:UIControlEventValueChanged];
    
    // show loading indicator
    self.loadingIndicator = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // unhighlight selection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *dayparts = self.cafeInfo[@"dayparts"];
    return dayparts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    headerView.backgroundColor = [UIColor colorWithWhite:.9 alpha:.9];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, self.view.frame.size.width, 50)];
    
    NSArray *dayparts = self.cafeInfo[@"dayparts"];
    NSLog(@"section label is %@", dayparts[section][@"label"]);
    headerLabel.text = dayparts[section][@"label"];
    
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    headerLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    [headerView addSubview:headerLabel];
    
    return headerView;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *stations = self.cafeInfo[@"dayparts"][section][@"stations"];
    NSInteger itemCount = 0;
    
    for (NSDictionary *station in stations) {
        NSArray *items = station[@"items"];
        itemCount += items.count;
    }
    return itemCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FoodCell"];
    NSInteger rowCount = 0;
    
    NSArray *stations = self.cafeInfo[@"dayparts"][indexPath.section][@"stations"];
    BOOL dobreak = NO;
    
    for (NSDictionary *station in stations) {
        NSArray *items = station[@"items"];
        for (NSString *itemId in items) {
            if (rowCount == indexPath.row) {
                cell.item = self.cafeInfo[@"items"][itemId];
                cell.votes = self.cafeInfo[@"votes"][itemId];
                cell.delegate = self;
                dobreak = YES;
                break;
            }
            rowCount++;
        }
        if (dobreak) {
            break;
        }
    }

    return cell;
}

- (void)loadMenu {
    NSInteger cafe = self.cafeSegmentedControl.selectedSegmentIndex;
    NSString *cafeId;
    
    switch (cafe) {
        case 0:
        default:
            cafeId = @"684";
            break;
        case 1:
            cafeId = @"682";
            break;
        case 2:
            cafeId = @"674";
            break;
    }
    
    [[Menu sharedInstance] getMenuForCafeWithCompletion:cafeId completion:^(NSDictionary *cafeInfo, NSError *error) {
//        NSLog(@"Got menu for %@: %@", cafeId, cafeInfo);
        self.cafeInfo = cafeInfo;
        [self.tableView reloadData];
        [self.refreshMenuControl endRefreshing];
        [self.loadingIndicator hide:YES];
        [UIView animateWithDuration:.24 animations:^{
            self.tableView.alpha = 1;
            [self.view layoutIfNeeded];
        }];
    }];
}

- (IBAction)cafeChanged:(id)sender {
    self.loadingIndicator = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self loadMenu];
}

- (void)voteChangedForItem:(NSString *)itemId vote:(NSInteger)count up:(BOOL)up {
    self.cafeInfo[@"votes"][itemId] = @{
                                        @"votes": @(count),
                                        @"iVoted": up ? @YES : @NO
                                        };
    
    NSLog(@"item now contains %@", self.cafeInfo[@"votes"][itemId]);
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
