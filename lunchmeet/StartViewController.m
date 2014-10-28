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
#import "FlickrCam.h"
#import "UIImageView+AFNetworking.h"

@interface StartViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIImageView *urlsView;
@property (weak, nonatomic) IBOutlet UIImageView *previousUrlsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginControlsVerticalConstraint;
@property (weak, nonatomic) IBOutlet UIView *loginControlsView;

@property (strong, nonatomic) NSTimer *flickrTimer;

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
    [self resetFlickrTimer];
}

- (void)resetFlickrTimer {
    NSLog(@"Resetting flickr timer");
    [self.flickrTimer invalidate];
    // flickrcam updates every 6 minutes, so refresh every 8 or so
    self.flickrTimer = [NSTimer scheduledTimerWithTimeInterval:480 target:self selector:@selector(onFlickrTimer) userInfo:nil repeats:YES];
    [self onFlickrTimer];
}

- (void)onFlickrTimer {
    // get live image of urls
    [[FlickrCam sharedInstance] getLatestImageUrlWithCompletion:^(NSString *imageUrl, NSError *error) {
        NSLog(@"Got flickr url %@", imageUrl);
        [self.urlsView setImageWithURL:[NSURL URLWithString:imageUrl]];
        [UIView animateWithDuration:3 animations:^{
            self.urlsView.alpha = 1;
        }];
    }];
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
    [self presentViewController:svc animated:NO completion:nil];
    svc.username = self.usernameTextfield.text;
    svc.password = self.passwordTextfield.text;
}

NSInteger const DEFAULT_LOGIN_CONTROLS_VERTICAL_CONSTRAINT = 200;

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"Keyboard will show for start vc");
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    if (keyboardFrameEndRect.size.height + 16 > DEFAULT_LOGIN_CONTROLS_VERTICAL_CONSTRAINT) {
        [UIView animateWithDuration:.24 animations:^{
            self.loginControlsVerticalConstraint.constant = keyboardFrameEndRect.size.height + 16;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSLog(@"Keyboard hidden");
    [UIView animateWithDuration:.24 animations:^{
        self.loginControlsVerticalConstraint.constant = DEFAULT_LOGIN_CONTROLS_VERTICAL_CONSTRAINT;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)onTap:(id)sender {
    NSLog(@"Screen tapped");
    
    CGFloat finalValue;
    
    if (self.loginControlsView.alpha == 0) {
        finalValue = 1;
    } else {
        finalValue = 0;
    }
    
    [UIView animateWithDuration:.24 animations:^{
        self.loginControlsView.alpha = finalValue;
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
