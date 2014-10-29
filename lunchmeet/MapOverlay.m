//
//  MapOverlay.m
//  lunchmeet
//
//  Created by Sneha Datla on 10/29/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//


#import "MapOverlay.h"

@implementation MapOverlay

-(id)initWithMapView:(MKMapView *)mapView {
    self = [super init];
    if(self)
    {

    }
    return self;
}

-(CLLocationCoordinate2D)coordinate {
    return self.overlayCoordinates;
}

-(MKMapRect)boundingMapRect {
    
    
    MKMapPoint lowerLeft = MKMapPointForCoordinate(CLLocationCoordinate2DMake(37.417792, -122.025413));
    MKMapPoint upperRight = MKMapPointForCoordinate(CLLocationCoordinate2DMake(37.41900, -122.023887));
    
    MKMapRect mapRect = MKMapRectMake(lowerLeft.x + 100, upperRight.y - 400, (upperRight.x - lowerLeft.x), (lowerLeft.y - upperRight.y)*1.6);
    
    
    return mapRect;
}

-(BOOL)canReplaceMapContent{
    return NO;
}

@end
