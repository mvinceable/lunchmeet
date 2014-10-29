//
//  MapAnnotation.m
//  lunchmeet
//
//  Created by Sneha Datla on 10/29/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "MapAnnotation.h"

@implementation MapAnnotation

-(CLLocationCoordinate2D)coordinate{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    return coord;
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    [self setLatitude:newCoordinate.latitude];
    [self setLongitude:newCoordinate.longitude];
}

-(NSString *)title{
    return [self pinUser];
}

-(NSString *)subtitle{
    return [self lastMsg];
}



@end
