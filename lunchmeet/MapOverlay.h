//
//  MapOverlay.h
//  Map
//
//  Created by Sneha  Datla on 10/27/14.
//  Copyright (c) 2014 Sneha  Datla. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@class BuildingMap;

@interface MapOverlay : NSObject <MKOverlay>

- (instancetype)initWithBuildingMap:(BuildingMap *)buildingMap;

@end
