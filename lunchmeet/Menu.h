//
//  Menu.h
//  Lunchmeet
//
//  Created by Vince Magistrado on 11/13/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Menu : NSObject

+ (Menu *)sharedInstance;

- (void)getMenuForCafeWithCompletion:(NSString *)cafeId completion:(void (^)(NSDictionary *cafeInfo, NSError *error))completion;
- (void)voteForFoodItem:(BOOL)vote itemId:(NSString *)foodItemId;

@end
