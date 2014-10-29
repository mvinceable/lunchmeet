//
//  MapOverlayView.h
//  Map
//
//  Created by Sneha Datla on 10/29/14.
//  Copyright (c) 2014 Sneha  Datla. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MapOverlayView : MKOverlayRenderer
@property (nonatomic, strong) UIImage *overlayImage;
- (instancetype)initWithOverlay:(id<MKOverlay>)overlay overlayImage:(UIImage *)overlayImage;
@end
