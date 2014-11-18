//
//  FlickrCam.h
//  lunchmeet
//
//  Created by Vince Magistrado on 10/27/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrCam : NSObject

+ (FlickrCam *)sharedInstance;

- (void)getLatestPhotosWithCompletion:(void (^)(NSArray *photos, NSError *error))completion;
- (NSString *)getImageUrlAtIndex:(NSInteger)index;
- (void)getFoodPicWithCompletion:(NSString *)foodString completion:(void (^)(NSString *photoUrl, NSError *error))completion;

@end
