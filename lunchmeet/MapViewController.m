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
    
    self.mapImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map.png"]];
    
    self.mapImageView.transform = CGAffineTransformScale(self.mapImageView.transform, 0.3, 0.3);
    self.mapImageView.center = CGPointMake(self.mapImageView.center.x/3.6, self.mapImageView.center.y/3.7);
    
    
    UILongPressGestureRecognizer *tapRecognizer = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(onLongPress:)];
    [tapRecognizer setNumberOfTouchesRequired:1];
    [tapRecognizer setMinimumPressDuration:1.5];
    [tapRecognizer setDelegate:self];
    self.mapImageView.userInteractionEnabled = YES;
    self.mapImageView.tag = 1111;
    [self.mapImageView addGestureRecognizer:tapRecognizer];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(onPinch:)];
    [pinchRecognizer setDelegate:self];
    self.mapImageView.userInteractionEnabled = YES;
    [self.mapImageView addGestureRecognizer:pinchRecognizer];
    
    
    UIRotationGestureRecognizer *rotateRecognizer = [[UIRotationGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(onRotate:)];
    [rotateRecognizer setDelegate:self];
    self.mapImageView.userInteractionEnabled = YES;
    [self.mapImageView addGestureRecognizer:rotateRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(onPan:)];
    [panRecognizer setDelegate:self];
    self.mapImageView.userInteractionEnabled = YES;
    [self.mapImageView addGestureRecognizer:panRecognizer];
    
    [self.view addSubview:self.mapImageView];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) onLongPress:(id)sender
{
    NSLog(@"TESTING LONG PRESS");
    CGPoint touchedPoint = [sender locationInView:self.mapImageView];
    NSLog(@"x coord: %f, y coord: %f", touchedPoint.x, touchedPoint.y);
    //UIButton *pin = [[UIButton alloc] initWithFrame:CGRectMake(touchedPoint.x -10, touchedPoint.y - 10, 20, 20)];
    //pin.backgroundColor = [UIColor purpleColor];

    UIButton *pin = [[UIButton alloc] initWithFrame:CGRectMake(touchedPoint.x - 50, touchedPoint.y - 87, 100, 100)];
    UIImage *buttonImage = [UIImage imageNamed:@"image.png"];
    [pin setImage:buttonImage forState:UIControlStateNormal];
    [self.mapImageView addSubview:pin];
}

-(void) onPinch:(UIPinchGestureRecognizer *)sender {
    
   // NSLog(@"TESTING PINCH");
    self.mapImageView.transform = CGAffineTransformScale(self.mapImageView.transform, sender.scale, sender.scale);
    sender.scale = 1;
}
-(void) onRotate:(UIRotationGestureRecognizer *)sender
{
   // NSLog(@"TESTING ROTATE");
    self.mapImageView.transform = CGAffineTransformRotate(self.mapImageView.transform, sender.rotation);
    sender.rotation = 0;
    
}
-(void)onPan:(UIPanGestureRecognizer *)sender {
    
  //  NSLog(@"TESTING PAN");
    CGPoint translation = [sender translationInView:self.mapImageView.superview];
    self.mapImageView.center = CGPointMake(self.mapImageView.center.x + translation.x, self.mapImageView.center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self.mapImageView.superview];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
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
