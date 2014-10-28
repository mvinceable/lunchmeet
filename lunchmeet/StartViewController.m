//
//  StartViewController.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "StartViewController.h"
#import <Parse/Parse.h>
#import "GroupsViewController.h"
#import "SignupViewController.h"

@interface StartViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signupVerticalConstraint;


@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // update status bar appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor blackColor],
                                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20]
                                                            }];
}

- (void)viewDidAppear:(BOOL)animated {
    PFUser *user = [PFUser currentUser];
    if (user) { // User logged in
        NSLog(@"Welcome %@ (%@)", user.username, user.objectId);
        GroupsViewController *gvc = [[GroupsViewController alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:gvc];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogin:(id)sender {
    NSLog(@"Log in button");
    [PFUser logInWithUsernameInBackground:self.usernameTextfield.text password:self.passwordTextfield.text
        block:^(PFUser *user, NSError *error) {
            if (user) {
                // Do stuff after successful login.
                NSLog(@"Welcome %@ (%@)", user.username, user.objectId);
                GroupsViewController *gvc = [[GroupsViewController alloc] init];
                UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:gvc];
                [self presentViewController:nc animated:YES completion:nil];
            } else {
                // The login failed. Check error to see why.
                NSString *errorString = [error userInfo][@"error"];
                [[[UIAlertView alloc] initWithTitle:@"Failed to log in" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
}

- (IBAction)onSignup:(id)sender {
    NSLog(@"Sign up button");
    SignupViewController *svc = [[SignupViewController alloc] init];
    [self presentViewController:svc animated:YES completion:nil];
    svc.username = self.usernameTextfield.text;
    svc.password = self.passwordTextfield.text;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"Keyboard will show for start vc");
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    if (keyboardFrameEndRect.size.height + 16 > self.signupVerticalConstraint.constant) {
        [UIView animateWithDuration:.24 animations:^{
            self.signupVerticalConstraint.constant = keyboardFrameEndRect.size.height + 16;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSLog(@"Keyboard hidden");
    [UIView animateWithDuration:.24 animations:^{
        self.signupVerticalConstraint.constant = 100;
        [self.view layoutIfNeeded];
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
