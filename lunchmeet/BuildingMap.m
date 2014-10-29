//
//  BuildingMap.m
//  Map
//
//  Created by Sneha Datla on 10/29/14.
//  Copyright (c) 2014 Sneha  Datla. All rights reserved.
//

#import "BuildingMap.h"

@implementation BuildingMap

- (instancetype)initWithCoordinates {
    self = [super init];
    if (self) {
        
        _midCoordinate = CLLocationCoordinate2DMake(34.4248,-118.5971);
        _overlayTopLeftCoordinate = CLLocationCoordinate2DMake(37.419233,-122.024908);
        _overlayTopRightCoordinate = CLLocationCoordinate2DMake(37.41900, -122.023887);
        _overlayBottomLeftCoordinate = CLLocationCoordinate2DMake(37.417792, -122.025413);
        
    }
    
    return self;
}

- (CLLocationCoordinate2D)overlayBottomRightCoordinate {
    return CLLocationCoordinate2DMake(self.overlayBottomLeftCoordinate.latitude, self.overlayTopRightCoordinate.longitude);
}

- (MKMapRect)overlayBoundingMapRect {
    
    MKMapPoint topLeft = MKMapPointForCoordinate(self.overlayTopLeftCoordinate);
    MKMapPoint topRight = MKMapPointForCoordinate(self.overlayTopRightCoordinate);
    MKMapPoint bottomLeft = MKMapPointForCoordinate(self.overlayBottomLeftCoordinate);
    
    return MKMapRectMake(topLeft.x - 300,
                         topLeft.y - 180,
                         fabs(topLeft.x - topRight.x) * 1.6,
                         fabs(topLeft.y - bottomLeft.y) * 1.4);
}



@end
