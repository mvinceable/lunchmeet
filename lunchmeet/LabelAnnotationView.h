//
//  LabelAnnotationView.h
//  Lunchmeet
//
//  Created by Sneha Datla on 10/30/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface LabelAnnotationView : NSObject <MKAnnotation>
@property (nonatomic,copy) NSString *title;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
-(id) initWithTitle:(NSString *) title AndCoordinate:(CLLocationCoordinate2D)coordinate;
@end
