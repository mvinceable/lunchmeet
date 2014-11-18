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

@property (strong, nonatomic) NSArray *photos;

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

NSString *const LATEST_IMG_REQUEST_URL = @"https://api.flickr.com/services/rest/?&method=flickr.people.getPublicPhotos&api_key=ed809cd4adc84c29118dbd32f5ccb655&user_id=120759744@N07&format=json&nojsoncallback=1&per_page=240";

- (void)getLatestPhotosWithCompletion:(void (^)(NSArray *, NSError *))completion {
    NSURL *url = [NSURL URLWithString:LATEST_IMG_REQUEST_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // https://www.flickr.com/services/api/misc.urls.html
        self.photos = responseObject[@"photos"][@"photo"];
        [self storePhotos];
        
        if (completion) {
            completion(self.photos, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // fail silently, return the last stored result
        if (completion) {
            completion([self getStoredPhotos], error);
        }
    }];
    
    [operation start];
}

NSString *const FoodPicAPI = @"https://api.flickr.com/services/rest/?&method=flickr.photos.search&api_key=ed809cd4adc84c29118dbd32f5ccb655&text=%@&tags=food&format=json&nojsoncallback=1&per_page=1";

- (void)getFoodPicWithCompletion:(NSString *)foodString completion:(void (^)(NSString *, NSError *))completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:FoodPicAPI, [foodString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // https://www.flickr.com/services/api/misc.urls.html
//        NSLog(@"got response for photo:%@", responseObject);
        NSArray *photos = responseObject[@"photos"][@"photo"];
        NSString *photoUrl = nil;
        if (photos.count > 0) {
            NSDictionary *photo = photos[0];
            photoUrl = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_s.jpg", photo[@"farm"], photo[@"server"], photo[@"id"], photo[@"secret"]];
        }
        
        if (completion) {
            completion(photoUrl, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed response response for photo:%@", error);
        // fail silently, return the last stored result
        if (completion) {
            completion(nil, error);
        }
    }];
    
    [operation start];
}

- (void)storePhotos {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.photos forKey:@"photos"];
    [defaults synchronize];
}
     
- (NSArray *)getStoredPhotos {
    if (self.photos) {
        return self.photos;
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        return [defaults objectForKey:@"photos"];
    }
}

- (NSString *)getImageUrlAtIndex:(NSInteger)index {
    if (self.photos.count > index) {
        NSDictionary *photo = self.photos[index];
        return [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_b.jpg", photo[@"farm"], photo[@"server"], photo[@"id"], photo[@"secret"]];
    } else {
        return nil;
    }
}

@end
