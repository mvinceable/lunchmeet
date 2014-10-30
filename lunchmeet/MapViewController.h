//
//  MapViewController.h
//  lunchmeet
//
//  Created by Vince Magistrado on 10/27/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "BuildingMap.h"
#import "Group.h"
#import "MapAnnotation.h"
#import "MapAnnotationView.h"
#import "MapOverlayView.h"
#import "MapOverlay.h"
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MapViewController : UIViewController <UIGestureRecognizerDelegate, MKMapViewDelegate>
@property (strong, nonatomic)Group *group;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer;
@property (nonatomic, strong) NSMutableArray *listOfPins;
- (void)getPinsWithCompletion:(void (^)(NSArray *objects, NSError *error))completion;
-(void)findPins;
@property (nonatomic, strong) BuildingMap *buildingMap;
@end
