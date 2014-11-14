//
//  Menu.m
//  Lunchmeet
//
//  Created by Vince Magistrado on 11/13/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "Menu.h"
#import "AFNetworking.h"
#import <Parse/Parse.h>

@interface Menu()

@property (strong, nonatomic) NSMutableDictionary *cafeInfo;

@property (nonatomic, strong) void (^cafeInfoCompletion)(NSDictionary *cafeInfo, NSError *error);

@end

@implementation Menu

NSString *const MenuApiUrl = @"http://legacy.cafebonappetit.com/api/2/menus?format=jsonp&cafe=";

+ (Menu *)sharedInstance {
    static Menu *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[Menu alloc] init];
            instance.cafeInfo = [NSMutableDictionary dictionary];
        }
    });
    
    return instance;
}

- (void)getMenuForCafeWithCompletion:(NSString *)cafeId completion:(void (^)(NSDictionary *cafeInfo, NSError *error))completion {
    self.cafeInfoCompletion = completion;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", MenuApiUrl, cafeId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dayparts = responseObject[@"days"][0][@"cafes"][cafeId][@"dayparts"][0];
        NSDictionary *items = responseObject[@"items"];
        self.cafeInfo[@"dayparts"] = dayparts;
        self.cafeInfo[@"items"] = items;
        
        [self getVotesWithCompletion:cafeId completion:^(NSDictionary *cafeInfo, NSError *error) {
            completion(self.cafeInfo, nil);
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // fail silently, return the last stored result
        if (completion) {
            completion(nil, error);
        }
    }];
    
    [operation start];

}

- (void)getVotesWithCompletion:(NSString *)cafeId completion:(void (^)(NSDictionary *cafeInfo, NSError *error))completion {
    NSString *dayString = [self getTodayString];
    NSMutableDictionary *votes = [NSMutableDictionary dictionary];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Food"];
    [query whereKey:@"day" equalTo:dayString];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu votes.", (unsigned long)objects.count);
            for (PFObject *object in objects) {
                NSMutableDictionary *votesPerUser = [NSMutableDictionary dictionary];
                NSString *itemId = object[@"itemId"];
                NSString *username = object[@"username"];
                NSInteger votesForItem = 0;
                BOOL currentUserVoted = NO;
                if (votesPerUser[username] == nil) {
                    votesForItem++;
                    if ([username isEqualToString:[PFUser currentUser].username]) {
                        currentUserVoted = YES;
                    }
                    votesPerUser[username] = @YES;
                }
                votes[itemId] = @{
                                  @"votes": @(votesForItem),
                                  @"iVoted": @(currentUserVoted)
                                  };
                NSLog(@"Saw %ld votes for item %@", votesForItem, itemId);
            }
            self.cafeInfo[@"votes"] = votes;
            completion(self.cafeInfo, nil);
        } else {
            completion(nil, error);
            NSString *errorString = [error userInfo][@"error"];
            [[[UIAlertView alloc] initWithTitle:@"Failed to get votes" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];

}

- (NSString *)getTodayString {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    
    NSString *dayString = [NSString stringWithFormat:@"%ld-%ld-%ld", year, month, day];
    
    return dayString;
}

- (void)voteForFoodItem:(BOOL)vote itemId:(NSString *)foodItemId {
    NSString *dayString = [self getTodayString];
    
    if (vote) {
        PFObject *food = [PFObject objectWithClassName:@"Food"];
        [food setObject:[PFUser currentUser].username forKey:@"username"];
        [food setObject:foodItemId forKey:@"itemId"];
        [food setObject:dayString forKey:@"day"];
        
        [food saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Saved vote (%@).", food.objectId);
            } else {
                NSLog(@"%@", error);
            }
        }];
    } else {
        PFQuery *query = [PFQuery queryWithClassName:@"Food"];
        [query whereKey:@"username" equalTo:[PFUser currentUser].username];
        [query whereKey:@"itemId" equalTo:foodItemId];
        [query whereKey:@"day" equalTo:dayString];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                // The find succeeded.
                NSLog(@"Successfully retrieved %ld votes.", (long)objects.count);
                // Do something with the found objects
                for (PFObject *object in objects) {
                    [object deleteInBackground];
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
    }
}

@end
