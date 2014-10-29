//
//  MapViewController.h
//  lunchmeet
//
//  Created by Vince Magistrado on 10/27/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

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

-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay;
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer;
@property (nonatomic, strong) NSMutableArray *listOfPins;
- (void)getPinsWithCompletion:(void (^)(NSArray *objects, NSError *error))completion;
- (void)retrievePinsWithCompletion:(PFObject *)pfObj completionHandler:(void (^)(NSArray *objects, NSError *))completion;
-(void)findPins;

@end
