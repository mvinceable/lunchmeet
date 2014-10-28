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

- (void)getLatestImageUrlWithCompletion:(void (^)(NSString *imageUrl, NSError *error))completion;
- (NSString *)getStoredImageUrl;

@end
