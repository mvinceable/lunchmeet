//
//  MapViewController.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/27/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "LabelAnnotationView.h"
#import "MapViewController.h"

@interface MapViewController ()

@property (strong, nonatomic) NSMutableDictionary *userPins;
@property (strong, nonatomic) NSMutableDictionary *userAnnots;
@property (strong, nonatomic) NSTimer *getPinsTimer;

@property (nonatomic) BOOL selectedLatestPin;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set title text
    self.navigationItem.title = @"Campus Map";
    
    [self.mapView addAnnotations:[self createAnnotations]];
    self.mapView.showsBuildings = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.delegate = self;
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    
    CLLocationCoordinate2D coords[13] = {
        {37.419184, -122.024497},
        {37.418960, -122.023896},
        {37.417904, -122.024251},
        {37.417946, -122.024349},
        {37.417701, -122.024497},
        {37.417717, -122.024908},
        {37.417856, -122.025261},
        {37.418085, -122.025194},
        {37.418199, -122.025138},
        {37.418166, -122.025077},
        {37.418607, -122.025032},
        {37.418574, -122.024695},
        {37.419178, -122.024495}
    };
    MKPolygon *polygon = [MKPolygon polygonWithCoordinates:coords count:13];
    [self.mapView addOverlay:polygon];
    
    
    self.listOfPins = [[NSMutableArray alloc] init];
    
//    CLLocationCoordinate2D pt = CLLocationCoordinate2DMake(37.418475, -122.024540);
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pt, 20, 20);
//    MKMapCamera* camera = [MKMapCamera
//                           cameraLookingAtCenterCoordinate:(CLLocationCoordinate2D)pt
//                           fromEyeCoordinate:(CLLocationCoordinate2D)pt
//                           eyeAltitude:(CLLocationDistance)30];
//    [self.mapView setCamera:camera animated:YES];
    
    
    CLLocationCoordinate2D pt = CLLocationCoordinate2DMake(37.418109, -122.024740);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pt, 1, 1);
    [self.mapView setRegion:region animated:YES];
    
//    self.buildingMap = [[BuildingMap alloc] initWithCoordinates];
//    MapOverlay *overlay = [[MapOverlay alloc] initWithBuildingMap:self.buildingMap];
//    [self.mapView addOverlay:overlay];
    
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.24; //user needs to press for .24 seconds
    [self.mapView addGestureRecognizer:lpgr];
    
    self.userPins = [NSMutableDictionary dictionary];
    self.userAnnots = [NSMutableDictionary dictionary];
    
    self.selectedLatestPin = NO;
    
    [self findPins];
}

- (void)getPinsWithCompletion:(void (^)(NSArray *, NSError *))completion {
    
    NSDate *now = [NSDate date];
    NSDate *oneDayAgo = [now dateByAddingTimeInterval:-1*24*60*60];
    PFQuery *query = [PFQuery queryWithClassName:@"Point"];
    [query whereKey:@"group" equalTo:self.group.pfObject];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:oneDayAgo];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            completion(objects, nil);
        }
        else{
            completion(nil, error);
        }
    }];

}

-(void)findPins{
    [self getPinsWithCompletion:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error getting pins");
            //completion(nil, error);
        } else {
            
            for(int i = 0; i < objects.count; i++) {
                PFObject *obj = [objects objectAtIndex:i];
                
                if (obj[@"username"]) {
                    NSString *username = obj[@"username"];
                    // one pin per user
                    if ([self.userPins objectForKey:username] == nil) {
                        MapAnnotation *annot = [[MapAnnotation alloc] init];
                        annot.latitude = [obj[@"lat"] floatValue];
                        annot.longitude = [obj[@"long"] floatValue];
                        annot.pinUser = username;
                        PFQuery *query2 = [PFQuery queryWithClassName:@"Chat"];
                        [query2 whereKey:@"group" equalTo:self.group.pfObject];
                        [query2 whereKey:@"username" equalTo:annot.pinUser];
                        [query2 orderByDescending:@"createdAt"];
                        
                        [query2 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            if (!error) {
                                if(object != nil) {
                                    annot.lastMsg = object[@"message"];
                                }
                            } else {
                                annot.lastMsg = @"";
                            }
                            if([username isEqualToString:[PFUser currentUser].username]) {
                                annot.pinColor = @"green";
                            }
                            [self.mapView addAnnotation:annot];
                            self.userAnnots[username] = annot;
                            if (!self.selectedLatestPin) {
                                [self.mapView selectAnnotation:annot animated:NO];
                                self.selectedLatestPin = YES;
                            }
                        }];
                        self.userPins[username] = @YES;
                    }
                }
            }
        }
    }];
    
}
   

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    NSLog(@"touch point %f %f", touchMapCoordinate.latitude, touchMapCoordinate.longitude);
    MapAnnotation *annot = [[MapAnnotation alloc] init];
    
    PFObject *point = [PFObject objectWithClassName:@"Point"];
    PFUser *user = [PFUser currentUser];
    NSString *username = user.username;
    annot.pinUser = username;
    PFRelation *relation = [point relationForKey:@"group"];
    [relation addObject:self.group.pfObject];
    
    annot.latitude = touchMapCoordinate.latitude;
    annot.longitude = touchMapCoordinate.longitude;
    annot.pinColor = @"green";
    NSString *lat = [NSString stringWithFormat:@"%f", annot.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", annot.longitude];
    [point setObject:lat forKey:@"lat"];
    [point setObject:longitude forKey:@"long"];
    [point setObject:username forKey:@"username"];
    
    [point saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Saved location point (%@, %@)", lat, longitude);
                } else {
                    NSLog(@"%@", error);
                    
                }
            }];
    
    
    // get nearest landmark
    NSString *closestLandmark = [self getClosestLandmark:touchMapCoordinate.latitude lon:touchMapCoordinate.longitude];
    NSString *message = [NSString stringWithFormat:@"I'm at %@!", closestLandmark];
    
    annot.lastMsg = message;
    
    [self.mapView addAnnotation:annot];
    
    [self.mapView selectAnnotation:annot animated:YES];
    
    // remove previous annotation if it exists
    if ([self.userPins objectForKey:username] != nil && [self.userAnnots objectForKey:username] != nil) {
        [self.mapView removeAnnotation:self.userAnnots[username]];
    }
    self.userPins[username] = @YES;
    self.userAnnots[username] = annot;
    
    PFObject *chat = [PFObject objectWithClassName:@"Chat"];
    PFObject *group = self.group.pfObject;
    
    [chat setObject:message forKey:@"message"];
    
    // Create relationship
    [chat setObject:[PFUser currentUser].username forKey:@"username"];
    [chat setObject:group forKey:@"group"];
    
    // Save the new post
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
        } else {
            NSLog(@"Error creating chat");
        }
    }];
    
    // add to last message and user column
    [group setObject:message forKey:@"lastMessage"];
    [group setObject:[PFUser currentUser].username forKey:@"lastUser"];
    [group saveInBackground];
   
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    
    MapAnnotation *ann = (MapAnnotation *)annotation;
    if([annotation isKindOfClass:[MapAnnotation class]]){
        static NSString *userPinAnnotationId = @"userPinAnnotation";
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:userPinAnnotationId];
        if(annotationView)
        {
            annotationView.annotation = annotation;
            
        }
        else{
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userPinAnnotationId];
            if([ann.pinColor isEqualToString:@"green"])
            {
                
                annotationView.pinColor = MKPinAnnotationColorGreen;
            }
            else
            {
                 annotationView.pinColor = MKPinAnnotationColorPurple;
            }
           
            
        }
        
        annotationView.animatesDrop = YES;
        annotationView.draggable = NO;
        annotationView.canShowCallout = YES;
        return annotationView;
    }
    else if([annotation isKindOfClass:[LabelAnnotationView class]]){
        LabelAnnotationView *ann = (LabelAnnotationView *)annotation;
        NSLog(@"%@", ann.title);
        static NSString *userPinAnnotationId = @"userPinAnnotation";
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:userPinAnnotationId];
        
        MKPinAnnotationView *v = [[MKPinAnnotationView alloc] init];
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 300.f, 100.f)];
        [myLabel setFont: [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f]];
        myLabel.text = ann.title;
        [v addSubview:myLabel];
        v.transform = CGAffineTransformMakeTranslation(-15, -30);
        //[self.mapView addSubview:v];
        
        if(annotationView)
        {
            annotationView.annotation = annotation;
            annotationView = v;
            annotationView.image = nil;
        }
        else{
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userPinAnnotationId];
            annotationView = v;
            annotationView.image = nil;
        }
        return annotationView;
    }

    return nil;
}

//- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
//    if ([overlay isKindOfClass:MapOverlay.class]) {
//        UIImage *mapImage = [UIImage imageNamed:@"map.png"];
//        MapOverlayView *overlayView = [[MapOverlayView alloc] initWithOverlay:overlay overlayImage:mapImage];
//        
//        return overlayView;
//        
//    }
//    
//    return nil;
//}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if (overlay) {
        
        MKPolygonRenderer *polygonView = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
        
        polygonView.strokeColor = [[UIColor magentaColor] colorWithAlphaComponent:0.5];
        polygonView.lineWidth = 1;
        polygonView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.1];
        
        return polygonView;
    }
    return nil;
}

- (NSMutableArray *)createAnnotations
{
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    //Read locations details from plist
    NSString *path = [[NSBundle mainBundle] pathForResource:@"landmarks" ofType:@"plist"];
    NSMutableDictionary *locations = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    for (NSString *str in locations) {
        NSDictionary *row = [locations objectForKey:str];
        NSString *latitude = [row objectForKey:@"latitude"];
        NSString *longitude = [row objectForKey:@"longitude"];
        NSString *title = [row objectForKey:@"title"];
        //Create coordinates from the latitude and longitude values
        CLLocationCoordinate2D coord;
        coord.latitude = [latitude floatValue];
        coord.longitude = [longitude floatValue];
        LabelAnnotationView *annotation = [[LabelAnnotationView alloc] initWithTitle:title AndCoordinate:coord];
        NSLog(@"%@",annotation.title);
        [annotations addObject:annotation];
    }
    
    return annotations;
}

- (NSString *)getClosestLandmark:(CLLocationDegrees)lat lon:(CLLocationDegrees)lon {
    NSString *currentClosestLandmark = nil;
    CLLocationDistance currentClosestDistance = 1000;  // in meters
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    
    // iterate through landmarks and get the closest
    NSString *path = [[NSBundle mainBundle] pathForResource:@"landmarks" ofType:@"plist"];
    NSMutableDictionary *locations = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    for (NSString *str in locations) {
        NSDictionary *row = [locations objectForKey:str];
        NSString *latitude = [row objectForKey:@"latitude"];
        NSString *longitude = [row objectForKey:@"longitude"];
        NSString *title;
        if ([(NSString *)row[@"connector"] isEqualToString:@""]) {
            title = row[@"title"];
        } else {
            title = [NSString stringWithFormat:@"%@ %@", row[@"connector"], row[@"title"]];
        }
        CLLocation *locB = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        CLLocationDistance distance = [locA distanceFromLocation:locB];
        if (distance < currentClosestDistance) {
            currentClosestLandmark = title;
            currentClosestDistance = distance;
            NSLog(@"%@ is %f meters away", title, distance);
        }
    }
    return currentClosestLandmark;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
