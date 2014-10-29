//
//  MapOverlay.h
//  lunchmeet
//
//  Created by Sneha Datla on 10/29/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface MapOverlay : NSObject <MKOverlay>
@property (nonatomic) CLLocationCoordinate2D overlayCoordinates;
@property (nonatomic) MKMapRect overlayBoundingMapRect;
-(id)initWithMapView:(MKMapView *)mapView;

@end
