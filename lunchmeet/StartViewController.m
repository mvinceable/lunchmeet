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
#import "FlickrCam.h"
#import "UIImageView+AFNetworking.h"

@interface StartViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIImageView *urlsView;
@property (weak, nonatomic) IBOutlet UIImageView *previousUrlsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginControlsVerticalConstraint;
@property (weak, nonatomic) IBOutlet UIView *loginControlsView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlsBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlsTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlsRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *urlsLeftConstraint;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (strong, nonatomic) NSTimer *flickrTimer;
@property (nonatomic) BOOL isLoginScreen;
@property (nonatomic) CGFloat keyboardHeight;

@end

@implementation StartViewController

NSInteger const PARALLAX_CONSTANT = 24;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20]
                                                            }];
    
    self.scrollview.delegate = self;
    
    // starts as login screen
    self.isLoginScreen = YES;
    
    // detect orientation change
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    // Set vertical effect
    UIInterpolatingMotionEffect *verticalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.y"
     type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(PARALLAX_CONSTANT);
    verticalMotionEffect.maximumRelativeValue = @(-PARALLAX_CONSTANT);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect =
    [[UIInterpolatingMotionEffect alloc]
     initWithKeyPath:@"center.x"
     type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(PARALLAX_CONSTANT);
    horizontalMotionEffect.maximumRelativeValue = @(-PARALLAX_CONSTANT);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    [self.urlsView addMotionEffect:group];
    [self.previousUrlsView addMotionEffect:group];
}

- (void)viewWillAppear:(BOOL)animated {
    // update status bar appearance
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidAppear:(BOOL)animated {
    if (![self signedInUser]) {
        [self resetFlickrTimer];
    }
}

- (BOOL)signedInUser {
    PFUser *user = [PFUser currentUser];
    if (user) { // User logged in
        NSLog(@"Welcome %@ (%@)", user.username, user.objectId);
        GroupsViewController *gvc = [[GroupsViewController alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:gvc];
        nc.navigationBar.barTintColor = [UIColor orangeColor];
        nc.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:nc animated:YES completion:nil];
        return YES;
    } else {
        return NO;
    }
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
        } completion:^(BOOL finished) {
            [self.previousUrlsView setImageWithURL:[NSURL URLWithString:imageUrl]];
            self.urlsView.alpha = 0;
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
                [self signedInUser];
            } else {
                // The login failed. Check error to see why.
                NSString *errorString = [error userInfo][@"error"];
                [[[UIAlertView alloc] initWithTitle:@"Failed to log in" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        }];
}

- (IBAction)onSignup:(id)sender {
    NSLog(@"Sign up button");
    
    if (self.isLoginScreen) {
        // switch to sign up screen
        [UIView animateWithDuration:.24 animations:^{
            self.loginButton.alpha = 0;
            self.emailTextfield.alpha = 1;
            self.cancelButton.alpha = 1;
            [self.view layoutIfNeeded];
        }];
        self.isLoginScreen = NO;
        [self adjustHeightForKeybaord];
    } else {
        // sign up
        NSString *trimmedEmail = [self.emailTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *trimmedUsername = [self.usernameTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([trimmedEmail isEqualToString:@""] || [trimmedUsername isEqualToString:@""]) {
            [[[UIAlertView alloc] initWithTitle:@"Please enter all fields" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            PFUser *user = [PFUser user];
            user.email = trimmedEmail;
            user.username = trimmedUsername;
            user.password = self.passwordTextfield.text;
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    // Hooray! Let them use the app now.
                    NSLog(@"we've signed up");
                    [self signedInUser];
                } else {
                    NSString *errorString = [error userInfo][@"error"];
                    // Show the errorString somewhere and let the user try again.
                    [[[UIAlertView alloc] initWithTitle:@"Failed to sign up" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            }];
        }
    }
    
}

- (IBAction)onCancel:(id)sender {
    // switch to login screen
    [UIView animateWithDuration:.24 animations:^{
        self.loginButton.alpha = 1;
        self.emailTextfield.alpha = 0;
        self.cancelButton.alpha = 0;
        [self.view layoutIfNeeded];
    }];
    self.isLoginScreen = YES;
    [self adjustHeightForKeybaord];
}

NSInteger const DEFAULT_LOGIN_CONTROLS_VERTICAL_CONSTRAINT = 150;

- (void)adjustHeightForKeybaord {
    [UIView animateWithDuration:.24 animations:^{
        if (self.keyboardHeight > 0) {
            self.loginControlsVerticalConstraint.constant = self.keyboardHeight + 16 - (self.isLoginScreen ? 50 : 0);
        } else {
            self.loginControlsVerticalConstraint.constant = DEFAULT_LOGIN_CONTROLS_VERTICAL_CONSTRAINT;
        }
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"Keyboard will show for start vc");
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    self.keyboardHeight = keyboardFrameEndRect.size.height;
    if (self.keyboardHeight + 16 > DEFAULT_LOGIN_CONTROLS_VERTICAL_CONSTRAINT) {
        [self adjustHeightForKeybaord];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"Keyboard hidden");
    self.keyboardHeight = 0;
    [self adjustHeightForKeybaord];
}

- (void)showControls:(BOOL)show {
    CGFloat finalValue;
    
    if (show) {
        finalValue = 1;
    } else {
        finalValue = 0;
        [self.view endEditing:YES];
    }
    
    [UIView animateWithDuration:.24 animations:^{
        self.loginControlsView.alpha = finalValue;
    }];
}

- (IBAction)onTap:(id)sender {
    NSLog(@"Screen tapped");
    // hide keyboard
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat xOffset = scrollView.contentOffset.x;
    CGFloat yOffset = scrollView.contentOffset.y;

    if (xOffset < 0) {
        // pull right
        self.urlsRightConstraint.constant = xOffset - PARALLAX_CONSTANT;
    } else {
        // pull left
        self.urlsLeftConstraint.constant = -xOffset - PARALLAX_CONSTANT;
    }
    
    if (yOffset < 0) {
        // pulling down
        self.urlsBottomConstraint.constant = yOffset - PARALLAX_CONSTANT;
    } else {
        // pulling up
        self.urlsTopConstraint.constant = -yOffset - PARALLAX_CONSTANT;
    }
}

- (IBAction)didPinch:(UIPinchGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateChanged) {
        if (sender.scale > 1) {
            CGFloat scaleTo = (2 + sender.scale)/3;
            self.previousUrlsView.transform = CGAffineTransformMakeScale(scaleTo, scaleTo);
            self.urlsView.transform = CGAffineTransformMakeScale(scaleTo, scaleTo);
            [self.view layoutIfNeeded];
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:.24 animations:^{
            self.previousUrlsView.transform = CGAffineTransformMakeScale(1, 1);
            self.urlsView.transform = CGAffineTransformMakeScale(1, 1);
            [self.view layoutIfNeeded];
        }];
    }
}

- (void) orientationChanged:(NSNotification *)note {
    UIDevice * device = note.object;
    
    switch (device.orientation) {
        case UIDeviceOrientationPortrait:
            /* start special animation */
            [self showControls:YES];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            /* start special animation */
            break;
            
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            [self showControls:NO];
            break;
            
        default:
            break;
    };
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
