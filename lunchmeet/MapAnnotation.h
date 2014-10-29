//
//  MapAnnotation.h
//  lunchmeet
//
//  Created by Sneha Datla on 10/29/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface MapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, strong) NSString *pinUser;
@property (nonatomic, strong) NSString *lastMsg;
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic, strong) NSString *pinColor;

@end
