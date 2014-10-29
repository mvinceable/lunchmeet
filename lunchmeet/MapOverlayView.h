//
//  MapOverlayView.h
//  lunchmeet
//
//  Created by Sneha Datla on 10/29/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MapOverlayView : MKOverlayView

@property (nonatomic, strong) UIImage *overlayImage;
- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context;
- (instancetype)initWithOverlay:(id<MKOverlay>)overlay overlayImage:(UIImage *)overlayImage;

@end
