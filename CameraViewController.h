//
//  CameraViewController.h
//  VideoCapture
//
//  Created by Aleksey Orlov on 5/14/13.
//  Copyright (c) 2013 Aleksey Orlov. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <opencv2/highgui/cap_ios.h>




#define NUM_FINGERS	5
#define NUM_DEFECTS	8

@interface CameraViewController : UIViewController<CvVideoCameraDelegate>{
    
    IBOutlet UIButton *startButton;
    IBOutlet UIImageView *imageView;
    IBOutlet UIButton *stopButton;
    IBOutlet UISlider *commonSlider;
    //IBOutlet UIProgressView *commonProgressBar;
//    IBOutlet UIRotationGestureRecognizer *rotationRecognizer;
//    IBOutlet UILongPressGestureRecognizer *longPressRecognizer;
//    IBOutlet UIPanGestureRecognizer *gestureRecognizer;
    

    
    //HT
    
    
    
    
}

//- (id)initializeWithTag:(int) tag;
- (void) pinchRec;
- (IBAction)startButtonClick:(id)sender;
- (IBAction)stopButtonClick:(id)sender;

- (IBAction)rotDetected:(id)sender;
- (IBAction)longPressDetected:(id)sender;
- (IBAction)gestureDetected:(id)sender;
- (IBAction)tapDetected:(id)sender;
- (IBAction)panDetected:(id)sender;
- (IBAction)commonSliderValueChanged:(id)sender;


-(void) htInit;
-(void) htFindContour;
-(void) htFindConvexHull;
-(void) htFilterAndThreshold;
-(void) htFindFingers;
-(void) htDisplay;


-(void) bsInit;

@property (nonatomic) int tag;
@property (nonatomic) IBOutlet UIProgressView *commonProgressBar;
@property (strong, nonatomic) IBOutlet UISlider *thresholdTop;
@property (strong, nonatomic) IBOutlet UISlider *thresholdBottom;
@property (strong, nonatomic) IBOutlet UISlider *erosionSize;
@property (strong, nonatomic) IBOutlet UISlider *dilationSize;
@property (strong, nonatomic) IBOutlet UISlider *oneMoreSlider;

#ifndef __cplusplus
//- (void)processImage:(cv::Mat&)image;
#endif


@end
