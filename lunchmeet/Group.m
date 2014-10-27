//
//  Group.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "Group.h"
#import <Parse/Parse.h>

@interface Group()

@property PFObject *group;

@end

@implementation Group

- (id)initWithObject:(PFObject *)object {
    self = [super init];
    if (self) {
        self.name = object[@"name"];
        self.desc = object[@"description"];
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
            self.group = group;
            [self saveGroupMembersWithCompletion:completion];
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
            
            PFRelation *relation = [self.group relationForKey:@"members"];
            for (PFObject *member in objects) {
                [relation addObject:member];
            }
            
            [self.group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Saved relations for group (%@).", self.group.objectId);
                    completion(self.group.objectId, nil);
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

+ (NSArray *)groupsWithArray:(NSArray *)array {
    NSMutableArray *groups = [NSMutableArray array];
    
    for (PFObject *object in array) {
        [groups addObject:[[Group alloc] initWithObject:object]];
    }
    
    return groups;
}

@end
