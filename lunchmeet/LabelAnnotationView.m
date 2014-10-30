//
//  LabelAnnotationView.m
//  Lunchmeet
//
//  Created by Sneha Datla on 10/30/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "LabelAnnotationView.h"

@implementation LabelAnnotationView
@synthesize coordinate=_coordinate;
@synthesize title=_title;
-(id) initWithTitle:(NSString *) title AndCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    _title = title;
    _coordinate = coordinate;
    return self;
}
@end
