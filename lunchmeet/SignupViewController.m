//
//  SignupViewController.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "SignupViewController.h"
#import <Parse/Parse.h>

@interface SignupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonVerticalConstraint;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // start with focus on the text view
    [self.emailTextfield becomeFirstResponder];
    
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

- (IBAction)onSignup:(id)sender {
    
    PFUser *user = [PFUser user];
    user.email = self.emailTextfield.text;
    user.username = self.usernameTextfield.text;
    user.password = self.passwordTextfield.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
            NSLog(@"we've signed up");
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
            [[[UIAlertView alloc] initWithTitle:@"Failed to sign up" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];

}

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void) setUsername:(NSString *)username {
    self.usernameTextfield.text = username;
}

- (void) setPassword:(NSString *)password {
    self.passwordTextfield.text = password;
}

NSInteger const DEFAULT_CANCELVERTICAL_CONSTRAINT = 150;

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"Keyboard will show for signup vc");
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    if (keyboardFrameEndRect.size.height + 16 > DEFAULT_CANCELVERTICAL_CONSTRAINT) {
        [UIView animateWithDuration:.24 animations:^{
            self.cancelButtonVerticalConstraint.constant = keyboardFrameEndRect.size.height + 16;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSLog(@"Keyboard hidden");
    [UIView animateWithDuration:.24 animations:^{
        self.cancelButtonVerticalConstraint.constant = DEFAULT_CANCELVERTICAL_CONSTRAINT;
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
