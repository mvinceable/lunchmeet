//
//  MapViewController.h
//  lunchmeet
//
//  Created by Vince Magistrado on 10/27/14.
//  Copyright (c) 2014 Vince Magistrado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController <UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *mapImageView;


-(void) onLongPress:(id)sender;
-(void) onPinch:(id)sender;
-(void) onRotate:(id)sender;
@end
