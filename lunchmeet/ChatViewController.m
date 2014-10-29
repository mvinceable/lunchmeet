//
//  ChatViewController.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "ChatViewController.h"
#import "UserMessageCell.h"
#import "GroupMessageCell.h"
#import "MapViewController.h"

@interface ChatViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic)NSTimer *chatTimer;
@property (strong, nonatomic)NSArray *messages;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBottomConstraint;
@property (weak, nonatomic) IBOutlet UITextView *messageTextview;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextviewHeightConstraint;
@property (nonatomic) BOOL shouldScrollDown;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set title text
    self.navigationItem.title = self.group.name;
    
    // set right bar button
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(onMap)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    // set delegates
    self.tableview.dataSource = self;
    self.tableview.delegate = self;
    self.tableview.estimatedRowHeight = 90;
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    
    self.messageTextview.delegate = self;
    
    // listen for keyboard appearances and disappearances
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // register message cell nibs
    [self.tableview registerNib:[UINib nibWithNibName:@"GroupMessageCell" bundle:nil] forCellReuseIdentifier:@"GroupMessageCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"UserMessageCell" bundle:nil] forCellReuseIdentifier:@"UserMessageCell"];

}

- (void)viewDidAppear:(BOOL)animated {
    self.shouldScrollDown = YES;
    [self resetTimer];
}

- (void)resetTimer {
    NSLog(@"Resetting timer");
    [self.chatTimer invalidate];
    self.chatTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onChatTimer) userInfo:nil repeats:YES];
    [self onChatTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"Stopping timer");
    [self.chatTimer invalidate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onChatTimer {
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    
    // Follow relationship
    [query whereKey:@"group" equalTo:self.group.pfObject];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.messages = objects;
            [self.tableview reloadData];   // Reload table
            
            // scroll to last if just typed a new message
            if (self.shouldScrollDown) {
                [self scrollToLastMessage];
                self.shouldScrollDown = NO;
            }
        } else {
            NSLog(@"Error getting messages for group: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)scrollToLastMessage {
    if (self.messages.count > 0) {
        [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *message = self.messages[indexPath.row];
    
    // getting the user who created the message
    NSString *username = [message objectForKey:@"username"];
    
    if ([username isEqualToString:[PFUser currentUser].username]) {
        UserMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserMessageCell"];
        cell.message = self.messages[indexPath.row];
        return cell;
    } else {
        GroupMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupMessageCell"];
        cell.message = self.messages[indexPath.row];
        return cell;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"Keyboard will show");
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    [UIView animateWithDuration:.24 animations:^{
        self.messageBottomConstraint.constant = keyboardFrameEndRect.size.height;
        [self.view layoutIfNeeded];
    }];
    
    [self scrollToLastMessage];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"Keyboard hidden");
    [UIView animateWithDuration:.24 animations:^{
        self.messageBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

NSInteger const DEFAULT_MESSAGETEXTVIEW_HEIGHT = 36;

- (void)textViewDidChange:(UITextView *)textView {
    NSString *trimmedMessage = [self.messageTextview.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];    if (![trimmedMessage isEqualToString:@""]) {
        [self.sendButton setEnabled:YES];
    } else {
        [self.sendButton setEnabled:NO];
    }
    
    // set height of textview if necessary
    [self updateMessageTextviewHeight];
}

- (void)updateMessageTextviewHeight {
    CGSize sizeThatShouldFitTheContent = [self.messageTextview sizeThatFits:self.messageTextview.frame.size];
    if (sizeThatShouldFitTheContent.height > DEFAULT_MESSAGETEXTVIEW_HEIGHT) {
        [UIView animateWithDuration:.24 animations:^{
            self.messageTextviewHeightConstraint.constant = sizeThatShouldFitTheContent.height;
            [self.view layoutIfNeeded];
        }];
    } else {
        [UIView animateWithDuration:.24 animations:^{
            self.messageTextviewHeightConstraint.constant = DEFAULT_MESSAGETEXTVIEW_HEIGHT;
            [self.view layoutIfNeeded];
        }];
    }
}

- (IBAction)onSend:(id)sender {
    [self.sendButton setEnabled:NO];
    
    PFObject *chat = [PFObject objectWithClassName:@"Chat"];
    PFObject *group = self.group.pfObject;
    
    NSString *trimmedMessage = [self.messageTextview.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [chat setObject:trimmedMessage forKey:@"message"];
    
    // Create relationship
    [chat setObject:[PFUser currentUser].username forKey:@"username"];
    [chat setObject:group forKey:@"group"];
    
    // Save the new post
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            self.messageTextview.text = @"";
            [self updateMessageTextviewHeight];
            self.shouldScrollDown = YES;
            [self resetTimer];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            [[[UIAlertView alloc] initWithTitle:@"Failed to send message" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
    
    // add to last message and user column
    [group setObject:trimmedMessage forKey:@"lastMessage"];
    [group setObject:[PFUser currentUser].username forKey:@"lastUser"];
    [group saveInBackground];
}

- (void)onMap {
    NSLog(@"Showing map");
    MapViewController *vc = [[MapViewController alloc] init];
    vc.group = self.group;
    [self.navigationController pushViewController:vc animated:YES];
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
