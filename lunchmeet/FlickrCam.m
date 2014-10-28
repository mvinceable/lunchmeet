//
//  FlickrCam.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/27/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "FlickrCam.h"
#import "AFNetworking.h"

@interface FlickrCam()

@property (strong, nonatomic) NSString *currentImageUrl;

@end

@implementation FlickrCam

+ (FlickrCam *)sharedInstance {
    static FlickrCam *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[FlickrCam alloc] init];
        }
    });
    
    return instance;
}

NSString *const LATEST_IMG_REQUEST_URL = @"https://api.flickr.com/services/rest/?&method=flickr.people.getPublicPhotos&api_key=ed809cd4adc84c29118dbd32f5ccb655&user_id=120759744@N07&format=json&nojsoncallback=1&per_page=1";

- (void)getLatestImageUrlWithCompletion:(void (^)(NSString *, NSError *))completion {
    NSURL *url = [NSURL URLWithString:LATEST_IMG_REQUEST_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // https://www.flickr.com/services/api/misc.urls.html
        NSDictionary *photo = responseObject[@"photos"][@"photo"][0];
        NSString *imageUrl = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_b.jpg", photo[@"farm"], photo[@"server"], photo[@"id"], photo[@"secret"]];
        
        [self storeImageUrl:imageUrl];
        completion(self.currentImageUrl, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // fail silently, return the last stored result
        completion([self getStoredImageUrl], error);
    }];
    
    [operation start];
}

- (void)storeImageUrl:(NSString *)imageUrl {
    self.currentImageUrl = imageUrl;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:imageUrl forKey:@"currentImageUrl"];
    [defaults synchronize];
}
     
- (NSString *)getStoredImageUrl {
    if (_currentImageUrl) {
        return _currentImageUrl;
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        return [defaults stringForKey:@"currentImageUrl"];
    }
}

@end
