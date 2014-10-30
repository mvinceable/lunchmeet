//
//  MapViewController.m
//  lunchmeet
//
//  Created by Vince Magistrado on 10/27/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView.showsBuildings = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.delegate = self;
    
    self.listOfPins = [[NSMutableArray alloc] init];
    
    CLLocationCoordinate2D pt = CLLocationCoordinate2DMake(37.418475, -122.024540);
    //MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pt, 20, 20);
    MKMapCamera* camera = [MKMapCamera
                           cameraLookingAtCenterCoordinate:(CLLocationCoordinate2D)pt
                           fromEyeCoordinate:(CLLocationCoordinate2D)pt
                           eyeAltitude:(CLLocationDistance)30];
    [self.mapView setCamera:camera animated:YES];
//    [self.mapView setRegion:region animated:YES];
    
    self.buildingMap = [[BuildingMap alloc] initWithCoordinates];
    MapOverlay *overlay = [[MapOverlay alloc] initWithBuildingMap:self.buildingMap];
    [self.mapView addOverlay:overlay];
    
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.7; //user needs to press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];
    
    [self findPins];
    
   
    
    
}

- (void)getPinsWithCompletion:(void (^)(NSArray *, NSError *))completion {
    
    NSDate *now = [NSDate date];
    NSDate *oneDayAgo = [now dateByAddingTimeInterval:-1*24*60*60];
    PFQuery *query = [PFQuery queryWithClassName:@"Point"];
    [query whereKey:@"group" equalTo:self.group.pfObject];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:oneDayAgo];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            completion(objects, nil);
        }
        else{
            completion(nil, error);
        }
    }];

}

- (void)retrievePinsWithCompletion:(PFObject *)pfObj completionHandler:(void (^)(NSArray *objects, NSError *))completion{
    PFRelation *relation = pfObj[@"createdBy"];
    PFQuery *query = [relation query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    if (error) {
        completion(nil, error);
    } else {
       // NSLog(@"Person who created %@", objects[0][@"username"]);
        completion(objects, nil);
    }
    }];
}
-(void)findPins{
    
    
    [self getPinsWithCompletion:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error getting pins");
            //completion(nil, error);
        } else {
            
            for(int i = 0; i < objects.count; i++)
            {
                MapAnnotation *annot = [[MapAnnotation alloc] init];
                PFObject *obj = [objects objectAtIndex:i];
                annot.latitude = [obj[@"lat"] floatValue];
                annot.longitude = [obj[@"long"] floatValue];
                [self retrievePinsWithCompletion:obj completionHandler:^(NSArray *objects, NSError *error) {
                    if(error)
                    {
                        NSLog(@"errorrr");
                        
                    }
                    else
                    {
                        annot.pinUser = objects[0][@"username"];
                        
                        PFQuery *query2 = [PFQuery queryWithClassName:@"Chat"];
                        [query2 whereKey:@"group" equalTo:self.group.pfObject];
                        [query2 whereKey:@"username" equalTo:annot.pinUser];
                        [query2 orderByDescending:@"createdAt"];
                        
                        [query2 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            if(!error)
                            {
                                if(object != nil)
                                {
                                    annot.lastMsg = object[@"message"];
                                }
                            }
                            else
                            {
                                annot.lastMsg = @"";
                                
                            }
                            if([annot.pinUser isEqualToString:[PFUser currentUser].username])
                            {
                                annot.pinColor = @"green";
                            }
                            [self.mapView addAnnotation:annot];

                        }];

                    }
                }];
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
    annot.pinUser = user.username;
    PFRelation *relation = [point relationForKey:@"createdBy"];
    [relation addObject:[PFUser currentUser]];
    PFRelation *relation2 = [point relationForKey:@"group"];
    [relation2 addObject:self.group.pfObject];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"group" equalTo:self.group.pfObject];
    [query whereKey:@"username" equalTo:user.username];
    [query orderByDescending:@"createdAt"];
    
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if(!error)
            {
                if(object != nil)
                {
                    NSLog(@"THis is the user's last message %@", object[@"message"]);
                    annot.lastMsg = object[@"message"];
                }
            }
        }];
    
    
    annot.latitude = touchMapCoordinate.latitude;
    annot.longitude = touchMapCoordinate.longitude;
    annot.pinColor = @"green";
    NSString *lat = [NSString stringWithFormat:@"%f", annot.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", annot.longitude];
    [point setObject:lat forKey:@"lat"];
    [point setObject:longitude forKey:@"long"];
    
    [point saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Saved location point (%@, %@)", lat, longitude);
                } else {
                    NSLog(@"%@", error);
                    
                }
            }];
    
    
    [self.mapView addAnnotation:annot];
    
    PFObject *chat = [PFObject objectWithClassName:@"Chat"];
    PFObject *group = self.group.pfObject;
    
    NSString *message = @"I'm here!";
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
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:MapOverlay.class]) {
        UIImage *mapImage = [UIImage imageNamed:@"map.png"];
        MapOverlayView *overlayView = [[MapOverlayView alloc] initWithOverlay:overlay overlayImage:mapImage];
        
        return overlayView;
    }
    
    return nil;
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
