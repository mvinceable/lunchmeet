//
//  MapOverlayView.m
//  lunchmeet
//
//  Created by Sneha Datla on 10/29/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import "MapOverlayView.h"

@implementation MapOverlayView

- (instancetype)initWithOverlay:(id<MKOverlay>)overlay overlayImage:(UIImage *)overlayImage {
    self = [super initWithOverlay:overlay];
    if (self) {
        self.overlayImage = overlayImage;
        
    }
    
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    CGImageRef imageReference = self.overlayImage.CGImage;
    
    MKMapRect theMapRect = self.overlay.boundingMapRect;
    CGRect theRect = [self rectForMapRect:theMapRect];
    
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 1.0, -theRect.size.height);
    CGContextDrawImage(context, theRect, imageReference);
}

@end
