//
//  MapViewController.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/27/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "LabelAnnotationView.h"
#import "MapViewController.h"
#import "ChatViewController.h"

@interface MapViewController ()

@property (strong, nonatomic) NSMutableDictionary *userPins;
@property (strong, nonatomic) NSMutableDictionary *userAnnots;
@property (strong, nonatomic) NSMutableDictionary *userLatLongs;
@property (strong, nonatomic) NSTimer *getPinsTimer;

@property (nonatomic) BOOL selectedLatestPin;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set title text
    self.navigationItem.title = [NSString stringWithFormat:@"Map: %@", self.group.name];
    
    // set right bar button
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Chat" style:UIBarButtonItemStylePlain target:self action:@selector(onChat)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    [self.mapView addAnnotations:[self createAnnotations]];
    self.mapView.showsBuildings = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.delegate = self;
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    
    CLLocationCoordinate2D coords_A[13] = {
        
        {37.418134, -122.025541},
        {37.417984, -122.025605},
        {37.417783, -122.025617},
        {37.417281, -122.025389},
        {37.417235, -122.025539},
        {37.417195, -122.025531},
        {37.417130, -122.025728},
        {37.417180, -122.025749},
        {37.417160, -122.025815},
        {37.417716, -122.026066},
        {37.418148, -122.026037},
        {37.418147, -122.025772},
        {37.418193, -122.025746}
        
    };
    
    CLLocationCoordinate2D coords_B[14] = {
        {37.419014, -122.025138},
        {37.419176, -122.025138},
        {37.419208, -122.025170},
        {37.419190, -122.025229},
        {37.419332, -122.025418},
        {37.419029, -122.025792},
        {37.418469, -122.026061},
        {37.418450, -122.026008},
        {37.418412, -122.026020},
        {37.418346, -122.025818},
        {37.418386, -122.025795},
        {37.418339, -122.025640},
        {37.418821, -122.025405},
        {37.418981, -122.025211}
        
    };
    
    CLLocationCoordinate2D coords_C[17] = {
        //        {37.419184, -122.024497},
        //        {37.418960, -122.023896},
        //        {37.417904, -122.024251},
        //        {37.417946, -122.024349},
        //        {37.417701, -122.024497},
        //        {37.417717, -122.024908},
        //        {37.417856, -122.025261},
        //        {37.418085, -122.025194},
        //        {37.418199, -122.025138},
        //        {37.418166, -122.025077},
        //        {37.418607, -122.025032},
        //        {37.418574, -122.024695},
        //        {37.419178, -122.024495}
        
        {37.419184, -122.024499},
        {37.418966, -122.023902},
        {37.417910, -122.024253},
        {37.417943, -122.024356},
        {37.417705, -122.024499},
        {37.417725, -122.024899},
        {37.417867, -122.025260},
        {37.418063, -122.025132},
        {37.418093, -122.025196},
        {37.418187, -122.025129},
        {37.418162, -122.025062},
        {37.418600, -122.025014},
        {37.418595, -122.024854},
        {37.418623, -122.024841},
        {37.418618, -122.024787},
        {37.418580, -122.024790},
        {37.418578, -122.024704}
    };
    
    CLLocationCoordinate2D coords_D[16] = {
        {37.417555, -122.024638},
        {37.417503, -122.024668},
        {37.417466, -122.024597},
        {37.417411, -122.024627},
        {37.417385, -122.024586},
        {37.417077, -122.024773},
        {37.416786, -122.024789},
        {37.416786, -122.024952},
        {37.416751, -122.024965},
        {37.416786, -122.025252},
        {37.416963, -122.025263},
        {37.416970, -122.025238},
        {37.417169, -122.025233},
        {37.417607, -122.024953},
        {37.417572, -122.024844},
        {37.417617, -122.024806}
    };
    
    CLLocationCoordinate2D coords_E[23] = {
        {37.416083, -122.025619},
        {37.416120, -122.025441},
        {37.416069, -122.025425},
        {37.416081, -122.025304},
        {37.415612, -122.025187},
        {37.415620, -122.025155},
        {37.415550, -122.025142},
        {37.415547, -122.025159},
        {37.415478, -122.025142},
        {37.415282, -122.025177},
        {37.415281, -122.025145},
        {37.415094, -122.025192},
        {37.415135, -122.025491},
        {37.415173, -122.025487},
        {37.415199, -122.025664},
        {37.415477, -122.025603},
        {37.415464, -122.025643},
        {37.415515, -122.025647},
        {37.415529, -122.025617},
        {37.415938, -122.025734},
        {37.415951, -122.025675},
        {37.416017, -122.025684},
        {37.416029, -122.025606}
    };
    CLLocationCoordinate2D coords_F[13] = {
        {37.415413, -122.024364},
        {37.415445, -122.023845},
        {37.415339, -122.023843},
        {37.415340, -122.023811},
        {37.415108, -122.023820},
        {37.415093, -122.024135},
        {37.414781, -122.024319},
        {37.414822, -122.024425},
        {37.414809, -122.024431},
        {37.414861, -122.024576},
        {37.414880, -122.024565},
        {37.414906, -122.024628},
        {37.415347, -122.024359}
    };
    CLLocationCoordinate2D coords_G[13] = {
        {37.414718, -122.024572},
        {37.414675, -122.024188},
        {37.414779, -122.023862},
        {37.414726, -122.023835},
        {37.414728, -122.023820},
        {37.414479, -122.023710},
        {37.414357, -122.024102},
        {37.414396, -122.024122},
        {37.414441, -122.024621},
        {37.414486, -122.024618},
        {37.414493, -122.024633},
        {37.414612, -122.024612},
        {37.414616, -122.024594}
    };
    CLLocationCoordinate2D coords_Roof[7] = {
        {37.418623, -122.025039},
        {37.418419, -122.025053},
        {37.418222, -122.025087},
        {37.418235, -122.025190},
        {37.418374, -122.025151},
        {37.418383, -122.025182},
        {37.418625, -122.025173}
    };
    
    CLLocationCoordinate2D coords_Bridge[5] = {
        {37.418381, -122.025790},
        {37.418343, -122.025813},
        {37.418144, -122.025912},
        {37.418150, -122.025850},
        {37.418367, -122.025737}
        
    };
    CLLocationCoordinate2D coords_Lawn[9] = {
        {37.418636, -122.025123},
        {37.418700, -122.025125},
        {37.418811, -122.025323},
        {37.418111, -122.025238},
        {37.418220, -122.025155},
        
        {37.418235, -122.025200},
        {37.418374, -122.025161},
        {37.418383, -122.025192},
        {37.418625, -122.025183}
    };
    CLLocationCoordinate2D coords_Lawn2[5] = {
        {37.418259, -122.025539},
        {37.418684, -122.025347},
        {37.418052, -122.025268},
        {37.418124, -122.025403},
        {37.418202, -122.025382}
    };
    CLLocationCoordinate2D coords_Lawn3[6] = {
        {37.418088, -122.025464},
        {37.418024, -122.025279},
        {37.418011, -122.025301},
        {37.417992, -122.025260},
        {37.417785, -122.025515},
        {37.418005, -122.025510}
    };
    
    CLLocationCoordinate2D coords_Lawn4[4] = {
        {37.417844, -122.025329},
        {37.417735, -122.025492},
        {37.417304, -122.025248},
        {37.417735, -122.025164}
    };
    
    
    
    MKPolygon *polygon_A = [MKPolygon polygonWithCoordinates:coords_A count:13];
    MKPolygon *polygon_B = [MKPolygon polygonWithCoordinates:coords_B count:14];
    MKPolygon *polygon_C = [MKPolygon polygonWithCoordinates:coords_C count:17];
    MKPolygon *polygon_D = [MKPolygon polygonWithCoordinates:coords_D count:16];
    MKPolygon *polygon_E = [MKPolygon polygonWithCoordinates:coords_E count:23];
    MKPolygon *polygon_F = [MKPolygon polygonWithCoordinates:coords_F count:13];
    MKPolygon *polygon_G = [MKPolygon polygonWithCoordinates:coords_G count:13];
    MKPolygon *polygon_Roof = [MKPolygon polygonWithCoordinates:coords_Roof count:7];
    MKPolygon *polygon_Bridge = [MKPolygon polygonWithCoordinates:coords_Bridge count:5];
    MKPolygon *polygon_Lawn= [MKPolygon polygonWithCoordinates:coords_Lawn count:9];
    MKPolygon *polygon_Lawn2= [MKPolygon polygonWithCoordinates:coords_Lawn2 count:5];
    MKPolygon *polygon_Lawn3= [MKPolygon polygonWithCoordinates:coords_Lawn3 count:6];
    MKPolygon *polygon_Lawn4= [MKPolygon polygonWithCoordinates:coords_Lawn4 count:4];
    
    polygon_A.title = @"BLDG_A";
    polygon_B.title = @"BLDG_B";
    polygon_C.title = @"BLDG_C";
    polygon_D.title = @"BLDG_D";
    polygon_E.title = @"BLDG_E";
    polygon_F.title = @"BLDG_F";
    polygon_G.title = @"BLDG_G";
    polygon_Roof.title = @"Roof";
    polygon_Bridge.title = @"Bridge";
    polygon_Lawn.title = @"Lawn";
    polygon_Lawn2.title = @"Lawn";
    polygon_Lawn3.title = @"Lawn";
    polygon_Lawn4.title = @"Lawn";
    [self.mapView addOverlay:polygon_A];
    [self.mapView addOverlay:polygon_B];
    [self.mapView addOverlay:polygon_C];
    [self.mapView addOverlay:polygon_D];
    [self.mapView addOverlay:polygon_E];
    [self.mapView addOverlay:polygon_F];
    [self.mapView addOverlay:polygon_G];
    [self.mapView addOverlay:polygon_Roof];
    [self.mapView addOverlay:polygon_Bridge];
    [self.mapView addOverlay:polygon_Lawn];
    [self.mapView addOverlay:polygon_Lawn2];
    [self.mapView addOverlay:polygon_Lawn3];
    [self.mapView addOverlay:polygon_Lawn4];
    
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
    self.userLatLongs = [NSMutableDictionary dictionary];
    
    self.selectedLatestPin = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [self resetTimer];
}

- (void)resetTimer {
    NSLog(@"Resetting get pins timer");
    [self.getPinsTimer invalidate];
    self.getPinsTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onGetPinsTimer) userInfo:nil repeats:YES];
    [self onGetPinsTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"Stopping get pins timer");
    [self.getPinsTimer invalidate];
}

- (void)onGetPinsTimer {
    self.selectedLatestPin = NO;
    
    [self getPinsWithCompletion:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error getting pins");
            //completion(nil, error);
        } else {
            NSLog(@"got more pins");
            NSMutableDictionary *currentPins = [NSMutableDictionary dictionary];
            for (PFObject *obj in objects) {
                if (obj[@"username"]) {
                    NSString *username = obj[@"username"];
                    // make a dictionary of current pins
                    if ([currentPins objectForKey:username] == nil) {
                        currentPins[username] = obj;
                    }
                }
            }
            // remove annotations that no longer exist
            for (NSString *username in self.userPins) {
                if ([currentPins objectForKey:username] == nil) {
                    [self.mapView removeAnnotation:self.userAnnots[username]];
                }
            }
            // don't add annotations that already exist
            for (NSString *username in currentPins) {
                PFObject *obj = currentPins[username];
                BOOL addAnnotation = YES;
                MapAnnotation *annot = [[MapAnnotation alloc] init];
                annot.latitude = [obj[@"lat"] doubleValue];
                annot.longitude = [obj[@"long"] doubleValue];
                annot.pinUser = username;
                if ([username isEqualToString:[PFUser currentUser].username]) {
                    annot.pinColor = @"green";
                } else {
                    annot.pinColor = @"purple";
                }
                
                if (self.userPins[username]) {
                    if ([[NSString stringWithFormat:@"%f:%f", [obj[@"lat"] doubleValue], [obj[@"long"] doubleValue]] isEqualToString:self.userLatLongs[username]]) {
                        addAnnotation = NO;
                        
                        // add associated message because it might have changed
                        PFQuery *query2 = [PFQuery queryWithClassName:@"Chat"];
                        [query2 whereKey:@"group" equalTo:self.group.pfObject];
                        [query2 whereKey:@"username" equalTo:annot.pinUser];
                        [query2 orderByDescending:@"createdAt"];
                        
                        [query2 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            if (!error) {
                                if(object != nil) {
                                    // if message changed, re-add it
                                    MapAnnotation *oldAnnot = (MapAnnotation *)self.userAnnots[username];
                                    if (![oldAnnot.lastMsg isEqualToString:object[@"message"]]) {
                                        NSLog(@"updating message %@ to %@", oldAnnot.lastMsg, object[@"message"]);
                                        oldAnnot.lastMsg = object[@"message"];
                                        [self.mapView removeAnnotation:oldAnnot];
                                        [self.mapView addAnnotation:oldAnnot];
                                        if (!self.selectedLatestPin) {
                                            [self.mapView selectAnnotation:oldAnnot animated:NO];
                                            self.selectedLatestPin = YES;
                                        }
                                    }
                                }
                            }
                        }];
                    } else {
                        // remove old pin
                        [self.mapView removeAnnotation:self.userAnnots[username]];
                    }
                }
                
                if (!self.userPins[username] || addAnnotation) {
                    NSLog(@"adding annotation for %@", username);
                    // add new annotations
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
                        [self.mapView addAnnotation:annot];
                        self.userAnnots[username] = annot;
                        self.userLatLongs[username] = [NSString stringWithFormat:@"%f:%f", annot.latitude, annot.longitude];
                        if (!self.selectedLatestPin) {
                            [self.mapView selectAnnotation:annot animated:NO];
                            self.selectedLatestPin = YES;
                        }
                    }];
                    self.userPins[username] = @YES;
                }
            }
        }
    }];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Stopping get pins timer for long press");
        [self.getPinsTimer invalidate];
    } else {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            NSLog(@"Restarting get pins timer after long press");
            self.getPinsTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(onGetPinsTimer) userInfo:nil repeats:YES];
        }
    }
    
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
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
    self.userLatLongs[username] = [NSString stringWithFormat:@"%f:%f", annot.latitude, annot.longitude];
    
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
        
        MKPolygon *polygon = (MKPolygon *)overlay;
        MKPolygonRenderer *polygonView = [[MKPolygonRenderer alloc] initWithPolygon:overlay];
        
        if([polygon.title isEqualToString:@"BLDG_A"]){
            polygonView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:1];
            polygonView.lineWidth = 1;
            polygonView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
        }
        else if([polygon.title isEqualToString:@"BLDG_B"])
        {
            polygonView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:1];
            polygonView.lineWidth = 1;
            polygonView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
            
        }
        else if([polygon.title isEqualToString:@"BLDG_C"]) {
            polygonView.strokeColor = [[UIColor magentaColor] colorWithAlphaComponent:0.5];
            polygonView.lineWidth = 1;
            polygonView.fillColor = [[UIColor magentaColor] colorWithAlphaComponent:0.1];
        }
        else if([polygon.title isEqualToString:@"BLDG_D"]){
            polygonView.strokeColor = [[UIColor orangeColor] colorWithAlphaComponent:1];
            polygonView.lineWidth = 1;
            polygonView.fillColor = [[UIColor orangeColor] colorWithAlphaComponent:0.4];
        }
        else if([polygon.title isEqualToString:@"BLDG_E"]){
            polygonView.strokeColor = [[UIColor yellowColor] colorWithAlphaComponent:1];
            polygonView.lineWidth = 1;
            polygonView.fillColor = [[UIColor yellowColor] colorWithAlphaComponent:0.2];
        }
        else if([polygon.title isEqualToString:@"BLDG_F"]){
            polygonView.strokeColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
            polygonView.lineWidth = 1;
            polygonView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.4];
        }
        else if([polygon.title isEqualToString:@"BLDG_G"]){
            polygonView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
            polygonView.lineWidth = 1;
            polygonView.fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.4];
        }
        else if([polygon.title isEqualToString:@"Roof"]){
            polygonView.strokeColor = [[UIColor grayColor] colorWithAlphaComponent:1];
            polygonView.lineWidth = 1;
            polygonView.fillColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
        }
        else if([polygon.title isEqualToString:@"Bridge"]){
            polygonView.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:1];
            polygonView.lineWidth = 1;
            polygonView.fillColor = [[UIColor  blackColor] colorWithAlphaComponent:0.4];
        }
        else if([polygon.title isEqualToString:@"Lawn"]){
            polygonView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:1];
            polygonView.lineWidth = 1;
            polygonView.fillColor = [[UIColor  greenColor] colorWithAlphaComponent:0.4];
        }
        
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

- (void)onChat {
    NSLog(@"Showing chat");
    ChatViewController *vc = [[ChatViewController alloc] init];
    vc.group = self.group;
    [self.navigationController pushViewController:vc animated:YES];
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
