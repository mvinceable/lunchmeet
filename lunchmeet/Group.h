//
//  Group.h
//  lunchmeet
//
//  Created by Vince Magistrado on 10/26/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Group : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSArray *members;
@property (strong, nonatomic) NSString *lastUser;
@property (strong, nonatomic) NSString *lastMessage;
@property (strong, nonatomic) PFObject *pfObject;

- (id) initWithObject:(PFObject *)object;
- (id) initWithDictionary:(NSDictionary *)dictionary;

- (void)saveNewGroupWithCompletion:(void (^)(NSString *objectId, NSError *error))completion;

+ (NSArray *)groupsWithArray:(NSArray *)array;

@end
