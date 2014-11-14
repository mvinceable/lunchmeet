//
//  MenuViewController.m
//  Lunchmeet
//
//  Created by Vince Magistrado on 11/13/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *menuWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabHeightConstraint;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *menuUrl = @"http://yahoo.cafebonappetit.com/";
    NSURL *url = [NSURL URLWithString:menuUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.menuWebView loadRequest:requestObj];
}

- (void)viewWillAppear:(BOOL)animated {
    self.menuTopConstraint.constant = [UIApplication sharedApplication].statusBarFrame.size.height;
    self.tabHeightConstraint.constant = self.tabBarController.tabBar.frame.size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
