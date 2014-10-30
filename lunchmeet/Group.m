//
//  Group.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "Group.h"
#import <Parse/Parse.h>

@implementation Group

- (id)initWithObject:(PFObject *)object {
    self = [super init];
    if (self) {
        self.name = object[@"name"];
        self.desc = object[@"description"];
        self.lastMessage = object[@"lastMessage"];
        self.lastUser = object[@"lastUser"];
        self.pfObject = object;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        self.desc = dictionary[@"description"];
        self.members = dictionary[@"members"];
    }
    return self;
}

- (void)saveNewGroupWithCompletion:(void (^)(NSString *objectId, NSError *))completion {
    PFObject *group = [PFObject objectWithClassName:@"Group"];
    [group setObject:self.name forKey:@"name"];
    [group setObject:self.desc forKey:@"description"];
    [group setObject:[PFUser currentUser].objectId forKey:@"userId"];
    
    PFRelation *relation = [group relationForKey:@"members"];
    [relation addObject:[PFUser currentUser]];
    
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Saved group (%@).", group.objectId);
            _pfObject = group;
            [self saveGroupMembersWithCompletion:completion];
        } else {
            NSLog(@"%@", error);
            completion(nil, error);
        }
    }];
}

- (void)saveExistingGroupWithCompletion:(void (^)(NSString *, NSError *))completion {
    PFObject *group = _pfObject;
    [group setObject:self.name forKey:@"name"];
    [group setObject:self.desc forKey:@"description"];
    
    [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Saved existing group (%@).", group.objectId);
            [self saveExistingGroupMembersWithCompletion:completion];
        } else {
            NSLog(@"%@", error);
            completion(nil, error);
        }
    }];
}

- (void)saveGroupMembersWithCompletion:(void (^)(NSString *objectId, NSError *))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    
    NSLog(@"Adding members: %@", self.members);
    [query whereKey:@"username" containedIn:self.members];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully found %lu members.", (unsigned long)objects.count);
            NSLog(@"%@", objects);
            self.members = objects;
            
            PFRelation *relation = [_pfObject relationForKey:@"members"];
            for (PFObject *member in objects) {
                [relation addObject:member];
            }
            
            [_pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Saved relations for group (%@).", _pfObject.objectId);
                    completion(_pfObject.objectId, nil);
                } else {
                    NSLog(@"%@", error);
                    completion(nil, error);
                }
            }];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            [[[UIAlertView alloc] initWithTitle:@"Failed to get members" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

- (void)saveExistingGroupMembersWithCompletion:(void (^)(NSString *objectId, NSError *))completion {
    [self getGroupMembersWithCompletion:^(NSArray *objects, NSError *error) {
        if (error) {
            NSString *errorString = [error userInfo][@"error"];
            [[[UIAlertView alloc] initWithTitle:@"Failed to get existing group members" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            completion(nil, error);
        } else {
            PFRelation *relation = [_pfObject relationForKey:@"members"];
            NSMutableArray *existingUsernames = [[NSMutableArray alloc] init];
            NSMutableArray *usernamesToAdd = [[NSMutableArray alloc] init];
            
            for (PFObject *object in objects) {
                if ([self.members indexOfObject:object[@"username"]] == NSNotFound) {
                    NSLog(@"User %@ will be removed", object[@"username"]);
                    [relation removeObject:object];
                } else {
                    [existingUsernames addObject:object[@"username"]];
                }
            }
            
            for (NSString *username in self.members) {
                if ([existingUsernames indexOfObject:username] == NSNotFound) {
                    NSLog(@"User %@ will be added", username);
                    [usernamesToAdd addObject:username];
                }
            }
            
            PFQuery *query = [PFQuery queryWithClassName:@"_User"];
            
            [query whereKey:@"username" containedIn:usernamesToAdd];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    NSLog(@"Only %lu members list exist and will be added", (unsigned long)objects.count);
                    
                    for (PFObject *member in objects) {
                        [relation addObject:member];
                    }
                    
                    [_pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            NSLog(@"Saved relations for group (%@).", _pfObject.objectId);
                            completion(_pfObject.objectId, nil);
                        } else {
                            NSLog(@"%@", error);
                            completion(nil, error);
                        }
                    }];
                } else {
                    NSString *errorString = [error userInfo][@"error"];
                    [[[UIAlertView alloc] initWithTitle:@"Failed to get members that match usernames" message:errorString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                    completion(nil, error);
                }
            }];
        }
    }];
}

- (void)getGroupMembersWithCompletion:(void (^)(NSArray *, NSError *))completion {
    // create a relation based on the members key
    PFRelation *relation = [_pfObject relationForKey:@"members"];
    
    // generate a query based on that relation
    PFQuery *query = [relation query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            completion(nil, error);
        } else {
            completion(objects, nil);
        }
    }];
}

+ (NSArray *)groupsWithArray:(NSArray *)array {
    NSMutableArray *groups = [NSMutableArray array];
    
    for (PFObject *object in array) {
        [groups addObject:[[Group alloc] initWithObject:object]];
    }
    
    return groups;
}

+ (NSString *)friendlyTimestamp:(NSDate *)date {
    NSDate *todayDate = [NSDate date];
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:todayDate];
    
    // check if today
    if ([self areSameDays:today secondDay:otherDay]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"h:mm a"];
        return [NSString stringWithFormat:@"Today %@", [dateFormat stringFromDate:date]];
    } else {
        // check if yesterday
        NSDate *yesterdayDate = [todayDate dateByAddingTimeInterval: -86400.0];
        NSDateComponents *yesterday = [[NSCalendar currentCalendar] components:NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:yesterdayDate];
        if ([self areSameDays:yesterday secondDay:otherDay]) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"h:mm a"];
            return [NSString stringWithFormat:@"Yesterday %@", [dateFormat stringFromDate:date]];
        } else {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"M/d/yy h:mm a"];
            return [dateFormat stringFromDate:date];
        }
    }
}

+ (BOOL)areSameDays:(NSDateComponents *)firstDay secondDay:(NSDateComponents *)secondDay {
    if ([firstDay day] == [secondDay day] &&
        [firstDay month] == [secondDay month] &&
        [firstDay year] == [secondDay year] &&
        [firstDay era] == [secondDay era]) {
        return YES;
    } else {
        return NO;
    }
}

@end
