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
    self.mapView.showsUserLocation = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.delegate = self;
    
    self.listOfPins = [[NSMutableArray alloc] init];
    
    CLLocationCoordinate2D pt = CLLocationCoordinate2DMake(37.418167, -122.024921);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(pt, 0.5, 0.5);
    [self.mapView setRegion:region animated:YES];
    
    MapOverlay *mapOverlay = [[MapOverlay alloc] initWithMapView:self.mapView];
    
    [self.mapView addOverlay:mapOverlay];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0; //user needs to press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];
    
    [self findPins];
    
   
    
    
}

- (void)getPinsWithCompletion:(void (^)(NSArray *, NSError *))completion {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Point"];
    [query whereKey:@"group" equalTo:self.group.pfObject];
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
                                    NSLog(@"THis is the user's last message %@", object[@"message"]);
                                    annot.lastMsg = object[@"message"];
                                }
                            }
                            else
                            {
                                annot.lastMsg = @"";
                                
                            }
                            NSLog(@"THIS IS THE USER %@", annot.pinUser);
                            if([annot.pinUser isEqualToString:[PFUser currentUser].username])
                            {
                                annot.pinColor = @"green";
                            }
                            NSLog(@"THIS IS THE LAT %f", annot.latitude);
                            NSLog(@"THIS IS THE LONG %f", annot.longitude);

                            NSLog(@"THIS IS THE MSG %@", annot.lastMsg);
                            
                            [self.mapView addAnnotation:annot];

                        }];

                        
                        
                        //[self addAn:annot.pinUser msg:annot.lastMsg lat:annot.latitude longitude:annot.longitude];
                        

                        
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


-(MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if([overlay isMemberOfClass:[MapOverlay class]]) {
        
        
        // DimOverlayVIew *dimOverlayView = [[DimOverlayVIew alloc] initWithOverlay:overlay];
        UIImage *mapImage = [UIImage imageNamed:@"map.png"];
        
        MapOverlayView *overlayView = [[MapOverlayView alloc] initWithOverlay:overlay overlayImage:mapImage];
        
        return overlayView;
    }
    return nil;
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
   
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    
    MapAnnotation *ann = (MapAnnotation *)annotation;
    NSLog(@"ANNN %@", ann.pinColor );
    //NSLog(@"ANNNN %@", ann.pinUser);
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
        annotationView.draggable = YES;
        annotationView.canShowCallout = YES;
        return annotationView;
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
