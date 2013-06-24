//
//  CameraViewController.m
//  VideoCapture
//
//  Created by Aleksey Orlov on 5/14/13.
//  Copyright (c) 2013 Aleksey Orlov. All rights reserved.
//

#import "CameraViewController.h"


#import "opencv2/opencv.hpp"
#import "opencv2/highgui/highgui.hpp"
#import "opencv2/imgproc/imgproc.hpp"

#import <stdio.h>


#define VIDEO_FILE	"video.avi"
#define VIDEO_FORMAT	CV_FOURCC('M','J','P','G')
#define NUM_FINGERS	5
#define NUM_DEFECTS	8


using namespace cv;
static const int N = 30;


@interface CameraViewController (){
    
    //UI

    Mat frame[N];
    long int frameIndex;
    //GLfloat X,Y; for panRecognizer;
    double kSlider; // commonSlider;
    
    
    // common
    
    cv::Size frameSize;

    
    
    // Hand Tracking
    
    double area;
    double max_area;
    int indexOfMaxArea;
    
    Mat image_input;
    Mat image_grayscale;
    Mat canny_output;
    Mat image_contours;
    Mat temp_image1;
    Mat temp_image3;
    Mat thr_image;   /* After filtering and thresholding */
    Mat kernel;
    Mat scalarField;
    
    
    vector<vector<cv::Point>> contours;
    vector<vector<cv::Point>> hulls;
    vector<cv::Vec4i> hierarchy;
    vector<cv::Point> max_contour;
    vector<cv::Point> temp;
    vector<cv::Point> contour;
    vector<cv::Point> hull;
    
    
    vector<cv::Point> fingers;	/* Detected fingers positions */
	vector<cv::Vec4i> defects;	/* Convexity defects depth points */
    
    cv::Point hand_center;
    
    int		num_fingers;
	int		hand_radius;
	int		num_defects;
    
    double threshTop;
    double threshBottom;
    
    
    // Background Substracting
    
    BackgroundSubtractorMOG2 backgroundSubstractor;
    //BackgroundSubtractorMOG backgroundSubstractor;
    
    
    int bsHistory;
    int bsNmixtures;
    double bsBackgroundRatio;
    int bsThreshold;
    
    Mat back;
    Mat fore;
    Mat fore_grayscale;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

-(void) drawOpticalFlow:(cv::Mat&)flow toImage:(cv::Mat&)image;
-(void) multImage:(Mat&)image toScalarField:(Mat&)scalarField;




//#ifndef __cplusplus
//- (void)processImage:(cv::Mat&)image;
//#endif

@property (retain, nonatomic) CvVideoCamera * videoCamera;
@property (retain, nonatomic) IBOutlet UIRotationGestureRecognizer *rotationRecognizer;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressRecognizer;
@property (strong, nonatomic) IBOutlet UIGestureRecognizer *gestureRecognizer;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panRecognizer;
@property (nonatomic) CGPoint translation;


@end



@implementation CameraViewController
@synthesize tag;
@synthesize translation;
@synthesize commonProgressBar;

@synthesize thresholdTop;
@synthesize thresholdBottom;
@synthesize erosionSize;
@synthesize dilationSize;
@synthesize oneMoreSlider;




//- (id)initializeWithTag:(int) tag{
//    
//    //self = [super init];
//
//    [self setTag:tag];
//    return self;
//    
//}

#pragma mark KVO [


#pragma mark ] KVO




-(void) pinchRec{
    NSLog(@"pinch pinch pinch");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    self.videoCamera.delegate = self;
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    
    
    
    self.rotationRecognizer = [[UIRotationGestureRecognizer alloc] init];
    self.longPressRecognizer = [[UILongPressGestureRecognizer alloc] init];
    self.gestureRecognizer = [[UIGestureRecognizer alloc] init];
    self.tapRecognizer = [[UITapGestureRecognizer alloc] init];
    self.panRecognizer = [[UIPanGestureRecognizer alloc] init];
    self.panRecognizer.minimumNumberOfTouches = 1;
    
    
    //[self.panRecognizer setTranslation:translation inView:self.view];
    
    double k = [self.commonProgressBar progress];

    kSlider = [self thresholdTop].value;

    
    
    frameIndex = 0;
    frameSize.height = self.videoCamera.imageHeight;
    frameSize.width = self.videoCamera.imageWidth;
    
    frameSize.height = 288;
    frameSize.width = 352;
    
    [self htInit];
    //[self bsInit];
    
}


-(IBAction)viewDidAppear:(BOOL)animated{
    [self.videoCamera start];
}
-(IBAction)viewDidDisappear:(BOOL)animated{
    if ([self.videoCamera running])
        
        [self.videoCamera stop];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startButtonClick:(id)sender {
    [self.videoCamera start];
    
}

-(IBAction)stopButtonClick:(id)sender{
    if ([self.videoCamera running])
    [self.videoCamera stop];
}

- (IBAction)rotDetected:(id)sender {
    //if respond
        //[self performSelector:@selector(stopButtonClick:)];
    if ([self.videoCamera running])
    [self.videoCamera stop];
}

- (IBAction)longPressDetected:(id)sender {
    GLfloat dist = [(UILongPressGestureRecognizer*)sender allowableMovement];
    NSLog(@"%f", dist);
    
}

- (IBAction)gestureDetected:(id)sender {
    //GLfloat dist = [(UIGestureRecognizer*)sender ];
    
}

- (IBAction)tapDetected:(id)sender {

    
}

- (IBAction)panDetected:(id)sender {
    //GLfloat dist = [sender allowableMovement];
    //X = [sender translationInView:self.view].x;
    //Y = [sender translationInView:self.view].y;
    
    //NSLog(@"x = %f  y = %f", X, Y);
    
    
}

- (IBAction)commonSliderValueChanged:(id)sender {
    kSlider = [(UISlider*)sender value];
    //[thresholdBottom setValue:kSlider];
    bsHistory = [(UISlider*)sender value]*400 + 1;
    
}


/*
 ctx.filter_and_threshold();
 ctx.find_contour();
 ctx.find_convex_hull();
 ctx.find_fingers();
 ctx.display();
 */



#pragma mark processImage


- (void)processImage:(Mat&)image{
    
    
    //cvtColor(image, image, CV_BGR2HLS);
    Mat imageHist;
    vector<Mat> image_ch;
    split(image, image_ch);
    int histSize = 256;
    float range[] = {0,256};
    const float* histRange = {range};
    bool uniform = true;
    bool accumulate = false;
    
    Mat hist0, hist1, hist2;
    equalizeHist(hist0, hist0);
    equalizeHist(hist1, hist1);
    equalizeHist(hist2, hist2);
    
    
    
    calcHist(&image_ch[0], 1, 0, Mat(), hist0, 1, &histSize, &histRange);
    calcHist(&image_ch[1], 1, 0, Mat(), hist1, 1, &histSize, &histRange);
    calcHist(&image_ch[2], 1, 0, Mat(), hist2, 1, &histSize, &histRange);
    
    int histW = 300;
    int histH = 300;
    int binW = int((double)histW/histSize);
    
    imageHist.create(histH, histW, CV_8UC3);
    imageHist.ones(histH, histW, CV_8UC3);
    Mat imageFloodFill;
    //imageFloodFill.create(frameSize, CV_8UC3);
    imageFloodFill.create(image.rows, image.cols, CV_8UC3);
    
    
//    normalize(hist0, hist0, 250, NORM_MINMAX);
//    normalize(hist1, hist1, 250, NORM_MINMAX);
//    normalize(hist2, hist2, 250, NORM_MINMAX);
    
    
    double scy = 0.02;
    
    int shy0 = 10;
    int shy1 = 130;
    int shy2 = 230;
    
    //imageHist = imageHist*200;
    Mat mask;
    //mask.create(frameSize.width+3, frameSize.height+3, CV_8UC1);
    mask.create(image.rows + 2, image.cols+2, CV_8UC1);
    
    //line(imageHist, cv::Point(100,100), cv::Point(100,200), Scalar(0,200,0), 1, 8, 0);
    
    for (int i=0; i<histSize; i++){
        
        histH = 0;
        line(imageHist, cv::Point(histH + shy0, binW*i),
             cv::Point(histH + (int)(hist0.at<float>(i)*scy + shy0), binW*i),
             Scalar(0,0,200), 1, 8, 0);
        
        line(imageHist, cv::Point(histH + shy1, binW*i),
             cv::Point(histH + (int)(hist1.at<float>(i)*scy + shy1), binW*i),
             Scalar(0,200,0), 1, 8, 0);
        
        line(imageHist, cv::Point(histH + shy2, binW*i),
             cv::Point(histH + (int)(hist2.at<float>(i)*scy + shy2), binW*i),
             Scalar(200,0,0), 1, 8, 0);
        
    }
    
    
    
    
    switch (tag){
        case 10:{
            //image = imageHist.clone();
            //image = imageHist;
            //floodFill(image, mask, cv::Point(200,200), Scalar(200,0,0));
            

            cv::Point seedPoint = cv::Point(170,250);
            
            cv::Scalar newVal = Scalar(200,200,200);
            
            int df0 = [self erosionSize].value * 250;
            int df1 = [self dilationSize].value * 250;
            int df2 = [self oneMoreSlider].value * 250;
            
            
            cv::Scalar loDiff = Scalar(df0, df1, df2);
            //cv::Scalar upDiff = Scalar(upDf, upDf, upDf);
            cv::Scalar upDiff = loDiff;
            
            
            @try{
                int typeImage = image.type();
                int typeImageFlood = imageFloodFill.type();
                
                //image.convertTo(imageFloodFill, 16);
                image.convertTo(image,16);
                
                
                typeImageFlood = imageFloodFill.type();
                typeImage = image.type();
                
                int stp = image.step1();
                
                for (int row = 0; row<image.rows; row++)
                    for (int col = 0; col<image.cols; col++){
                        imageFloodFill.data[row*imageFloodFill.step1() + col*3 + 0] = image.data[row*image.step1() + col*4 + 2];
                        imageFloodFill.data[row*imageFloodFill.step1() + col*3 + 1] = image.data[row*image.step1() + col*4 + 1];
                        imageFloodFill.data[row*imageFloodFill.step1() + col*3 + 2] = image.data[row*image.step1() + col*4 + 0];
                        
                    }
                
                //circle(imageFloodFill,seedPoint, 30, Scalar(0,0,250), 1,8,0);
                
                floodFill(imageFloodFill, seedPoint, newVal, 0, loDiff, upDiff, FLOODFILL_FIXED_RANGE );
                image = imageFloodFill;
                circle(image,seedPoint, 20, Scalar(0,0,250), 1,8,0);
            }
            @catch (NSException* ex) {
                NSLog(@"%@", ex);
            }

            
            
            if (!mask.empty()) mask.release();
            if (!imageFloodFill.empty()) imageFloodFill.release();
            if (!imageHist.empty()) imageHist.release();
            if (!image_ch[0].empty()) image_ch[0].release();
            if (!image_ch[1].empty()) image_ch[1].release();
            if (!image_ch[2].empty()) image_ch[2].release();
            

            break;
            
        }
            
        case 20:{
            //image = imageHist.clone();
            //cv::cvtColor(image_ch[0], image, CV_GRAY2BGR); // blue
            
            [self multImage:image toScalarField:scalarField];
            //image = scalarField*200;
            
            break;
            
        }
            
        case 30:{
            //image = imageHist.clone();
            
            cvtColor(image_ch[1], image, CV_GRAY2BGR); //green
            
            
            break;
            
        }
            
        case 40:{
            //image = imageHist.clone();
            
            cvtColor(image_ch[2], image, CV_GRAY2BGR); //red
            
            break;
            
        }
    }
}

- (void)processImage_opticalFlow:(Mat&)image{
    
    frameIndex++;
    
    //fore = image.clone();
    //back = image.clone();
    
    //cvtColor(image, image_grayscale, CV_BGR2GRAY);

    
    if (frameIndex == 1) {
        fore = image.clone();
        cvtColor(fore, fore_grayscale, CV_BGR2GRAY);
    }
    if (frameIndex < bsHistory || 1==1){
        fore = fore*((double)(frameIndex-1)/(double)frameIndex) + image*(1.0/(double)frameIndex);
        //fore = fore*0.1 + image*0.9;
        
        //fore_grayscale = fore_grayscale + image_grayscale;
    }
    
    backgroundSubstractor(-fore + image, back);
    //backgroundSubstractor.getBackgroundImage(back);
    
    Mat flowFarneback;
    flowFarneback.create(frameSize,CV_32FC2);
    double pyrScale = 0.9;
    int levels = 2;
    int winsize = 15;//???
    int iterations = 2;
    int poly_n = 5;
    int poly_sigma = 1.1;
    int flag = OPTFLOW_USE_INITIAL_FLOW;
    //int flag = OPTFLOW_FARNEBACK_GAUSSIAN;
    
    
    switch (tag){
        case 10:{
            //image = back.clone();
            
            //image = image_grayscale.clone();

            
            image = -fore + image;
            break;
        }
            
        case 20:{
            Mat image_grayscale_cur;
            
            cvtColor(image, image_grayscale_cur, CV_BGR2GRAY);
            @try{
                if (!image_grayscale.empty() && !image_grayscale_cur.empty())
                cv::calcOpticalFlowFarneback(image_grayscale, image_grayscale_cur, flowFarneback, pyrScale, levels, winsize, iterations, poly_n, poly_sigma, flag);
            }
            @catch (NSException* ex) {
                NSLog(@"%@", ex);
            }
            //image_input = image.clone();
            cvtColor(image, image_grayscale, CV_BGR2GRAY);
            
            [self drawOpticalFlow:flowFarneback toImage:image];
            //image = flowFarneback.clone();
            
            //image = back.clone();
            break;
        }
            
        case 30:{
            //image = (-fore + image) > kSlider*250;
            
            cvtColor((-fore + image), image_grayscale, CV_BGR2GRAY);
            image_grayscale = image_grayscale > kSlider*250;
            //image_input = image_grayscale.clone();
            cvtColor(image_grayscale, image_input, CV_GRAY2BGR);
            //image = image_input.clone();
            
            [self htFilterAndThreshold];
            [self htFindContour];

            
            image = thr_image.clone();

            
            break;
            
        }
            
        case 40:{
            cvtColor((-fore + image), image_grayscale, CV_BGR2GRAY);
            image_grayscale = image_grayscale > kSlider*250;
            //image_input = image_grayscale.clone();
            cvtColor(image_grayscale, image_input, CV_GRAY2BGR);
            //cvtColor(back, image_input, CV_GRAY2BGR);
            image_contours = image*0.2;
            

            [self htFilterAndThreshold];
            [self htFindContour];
            
            hulls.resize(contours.size());

            
            @try {
                if (!contours.empty()){
                    //NSLog(@"%i", indexOfMaxArea);
                    
                    for (int i=0; i<contours.size(); ++i){
//                            drawContours(image_contours, contours, i, i+1,2 ,8, hierarchy);
                        
                        
                    }
                    
                    drawContours(image_contours, contours, -1, Scalar(220, 200, 220),1 ,8, hierarchy);
                    drawContours(image_contours, contours, indexOfMaxArea, Scalar(0, 200, 0),4 ,8, hierarchy);
                    
                    if (!contours[indexOfMaxArea].empty() && !hulls.empty()){
                        
                        convexHull(contours[indexOfMaxArea], hulls[0], true);
                        drawContours(image_contours, hulls, 0, Scalar(0, 0, 200),1 ,8, hierarchy);
                    }
//                    if (!contours[indexOfMaxArea].empty() && !hulls.empty()){
//                        
//                        //convexHull(contours[indexOfMaxArea], hulls[0], true);
//                        //drawContours(image, hulls, -1, Scalar(0, 0, 200),1 ,8, hierarchy);
//                        @try {
//                            defects.resize(contours[indexOfMaxArea].size());
//                            //if (hulls[0].size()>3 )
//                            //convexityDefects(contours[indexOfMaxArea], hulls[0], defects);
//                            
//                        }
//                        @catch (NSException* ex) {
//                            NSLog(@"%@", ex);
//                        }
//                        
//                    }
                    //convexHull(contours[indexOfMaxArea], hulls[0], true);
                    
                    
                }
            }
            @catch (NSException* ex){
                NSLog(@"%@", ex);
            }
            
            image = image_contours.clone();


            break;
            
        }
            
    }
    

    //image = image_contours.clone();
    //NSLog(@"%f", translation.x);
    
}


- (void)processImage_HT:(Mat&)image{
    
    frameIndex++;
    
    
    
    
    image_input = image.clone();
    [self htFilterAndThreshold];
    [self htFindContour];
    //[self htFindConvexHull];
    //[self htFindFingers];
    //[self htDisplay];
    
    //temp_image3 = image_input.clone();
    
    //drawContours(image_input, contours, indexOfMaxArea, Scalar(200, 0, 0),1 ,8, hierarchy);
    //image = image_input.clone();
    hulls.resize(contours.size());
    
    
    switch (tag){
        case 10:{
            
            @try {
                if (!contours.empty()){
                    NSLog(@"%i", indexOfMaxArea);
                    //drawContours(image, contours, -1, Scalar(200, 0, 0),1 ,8, hierarchy);
                    drawContours(image, contours, indexOfMaxArea, Scalar(0, 200, 0),1 ,8, hierarchy);
                    if (!contours[indexOfMaxArea].empty() && !hulls.empty()){
                        
                        convexHull(contours[indexOfMaxArea], hulls[0], true);
                        drawContours(image, hulls, -1, Scalar(0, 0, 200),1 ,8, hierarchy);
                        @try {
                            defects.resize(contours[indexOfMaxArea].size());
                            //if (hulls[0].size()>3 )
                            //convexityDefects(contours[indexOfMaxArea], hulls[0], defects);
                            
                        }
                        @catch (NSException* ex) {
                            NSLog(@"%@", ex);
                        }
                        
                    }
                    //convexHull(contours[indexOfMaxArea], hulls[0], true);
                    
                    
                }
            }
            @catch (NSException* ex){
                NSLog(@"%@", ex);
            }
            
            
            
            break;
        }
            
        case 20:{
            image = image_input.clone();
            break;
        }
            
        case 30:{
            image = temp_image3.clone();
            break;
            
        }
            
        case 40:{
            image = thr_image.clone();
            break;
            
        }
            
    }
    
    
    //image = image_contours.clone();
    //NSLog(@"%f", translation.x);
    
}

- (void)processImage_summ:(Mat&)image{
    
    frameIndex++;
    
    
    const float D = 700;
    //GLfloat kx = X;
    //if (kx >  D) kx = D;
    //if (kx < -D) kx = -D;
    //GLfloat k = 0.5 + 0.5*kx/D;
    
    GLfloat kx = kSlider;
    GLfloat k = 0.5 + 0.5*(kx*2-1);
    
    
    for (int i=N-1; i>0; i--)
        frame[i] = frame[i-1].clone();
    
    switch (tag){
        case 10:{
            frame[0] = image*k + frame[1]*(1-k);
            break;
        }
        case 20:{
            frame[0] = image*0.05 + frame[N-1]*0.95;
            break;
        }
        case 30:{
            frame[0] = image*0.5 + frame[1]*0.5;
            break;
        }
        case 40:{
            frame[0] = image*0.5 + frame[N-1]*0.5;
            break;
        }
        default:{
            break;
        }
    }
    //frame[0] = image*0.05 + frame[1]*0.95;
    //double index = sin((double)frameIndex/10.0)*N/2  +  N/2;
    //NSLog(@"index = %f", index);
    //image = frame[(int)index].clone();
    
    image = frame[0].clone();
    //NSLog(@"%f", translation.x);
    
}


#pragma mark Hand Tracking

-(void) multImage:(Mat&)image toScalarField:(Mat&)scalarField{
    
    cv::Size sz1 = image.size();
    cv::Size sz2 = scalarField.size();
    
    if (image.size() != scalarField.size()) return;
    
    int chans = image.channels();
    
    
    for (int row = 0; row<image.rows; row++)
        for (int col = 0; col<image.cols; col++){
            
            
            for (int ch = 0; ch<chans; ++ch)
                
                image.data[row*image.step1() + col*chans + ch] *=
                scalarField.data[row*scalarField.step1() + col];
    
        }
}

-(void) drawOpticalFlow:(cv::Mat&)flow toImage:(cv::Mat&)image
{
    
    Mat flow_ch[2];
    flow_ch[0].create(frameSize, CV_32FC1);
    flow_ch[1].create(frameSize, CV_32FC1);
    
    split(flow, flow_ch);
    int d = 30;
    double scl = 0.1;
    for (int x = 0; x<flow.cols; x++)
        for (int y = 0; y<flow.rows; y++){
            if (x%d==0 && y%d ==0){
                double dx = flow_ch[0].data[y*flow_ch[0].step1() + x]*scl;
                double dy = flow_ch[1].data[y*flow_ch[1].step1() + x]*scl;
                
                line(image, cv::Point(x,y), cv::Point(x+dx, y+dy), Scalar(0,200,0));
                //line(image, cv::Point(y,x), cv::Point(y+dy, x+dx), Scalar(0,200,0));
            }
        }
        
    //line(image, cv::Point(0,0), cv::Point(300,300), Scalar(0,200,0));
}



-(void) htInit{
    
    frameIndex = 0;
    
    image_input.create(frameSize, CV_8UC3);
    thr_image.create(image_input.size(),CV_8UC1);
    image_grayscale.create(image_input.size(),CV_8UC1);
    fore_grayscale.create(image_input.size(),CV_8UC1);
	temp_image1.create(image_input.size(),CV_8UC1);
	temp_image3.create(image_input.size(),CV_8UC3);
	kernel.create(cv::Size(9,9),CV_8UC1);
    scalarField.create(frameSize.width, frameSize.height, CV_32FC1);
    
    int width = frameSize.width;
    int height = frameSize.height;
    
    
    int hRows = width/2;
    int hCols = width/2;
    
    for (int row = 0; row<scalarField.rows; row++)
        for (int col = 0; col<scalarField.cols; col++){
            scalarField.data[row*scalarField.step1() + col] = 
            cos((double)abs(row-hRows)/(double)hRows * CV_PI/2) *
            cos((double)abs(col-hCols)/(double)hCols * CV_PI/2);
            
        }
    

	/*ctx->fingers = new CvPoint[NUM_FINGERS];
     ctx->defects = new CvPoint[NUM_DEFECTS];*/

	fingers.resize(NUM_FINGERS);
	defects.resize(NUM_DEFECTS);
    
}

-(void) htFindContour{
    
    //threshTop = [self.thresholdTop value] * 400 + 10;
    
    threshTop = 350;
    threshBottom = [self.thresholdBottom value] * threshTop + 10;


    //cvtColor(image, image_grayscale, CV_BGR2GRAY);
    //Canny(image_grayscale, canny_output, threshTop, threshBottom);

	//thr_image.copyTo(temp_image1,NULL);
    temp_image1 = thr_image.clone();
	//cvtColor( temp_image3, temp_image1, CV_BGR2GRAY );

	Canny( temp_image1, canny_output, threshTop, threshBottom );


    findContours(temp_image1, contours, hierarchy, CV_RETR_EXTERNAL,  CV_CHAIN_APPROX_SIMPLE, cv::Point(0,0));

    //findContours(temp_image1, contours, hierarchy, CV_RETR_LIST,  CV_CHAIN_APPROX_SIMPLE, cv::Point(0,0));

	/* Select contour having greatest area */

    indexOfMaxArea = 0;
    max_area = 0;
	for (int i=0; i < contours.size(); i++){
		area = abs(contourArea(contours[i]));
		if (area > max_area) {
			max_area = area;
            indexOfMaxArea = i;
			contour = contours[i];
		}
	}

	if (!contour.empty()) {

		approxPolyDP(contour, contour , 2, false);
	}
}

-(void) htFindConvexHull{
    
    //vector<Vec4i> defects;
    vector<Vec4i> defect_array;


	int i;
	int x = 0, y = 0;
	int dist = 0;


    if (!contour.empty())
        convexHull(contour, hull, true);
    
    
    if (!hull.empty() && !contour.empty()){
        convexityDefects(contour,hull, defects);

		//if (defects && defects->total) {
		if (!defects.empty()) {

			/*defect_array = calloc(defects->total,
             sizeof(CvConvexityDefect));*/

			//defect_array = new CvConvexityDefect[defects->total];



			//cvCvtSeqToArray(defects, defect_array, CV_WHOLE_SEQ);

			defect_array = defects;


			/* Average depth points to get hand center */
			/*for (i = 0; i < defects->total && i < NUM_DEFECTS; i++) {
             x += defect_array[i].depth_point->x;
             y += defect_array[i].depth_point->y;

             ctx->defects[i] = cvPoint(defect_array[i].depth_point->x,
             defect_array[i].depth_point->y);
             }*/

			for (i = 0; i < defects.size() && i < NUM_DEFECTS; i++) {

				x += hull[defect_array[i][2]].x;
				y += hull[defect_array[i][2]].y;


			}

			x /= defects.size();
			y /= defects.size();


			num_defects = defects.size();
			hand_center = cvPoint(x, y);

			/* Compute hand radius as mean of distances of
             defects' depth point to hand center */

			for (i = 0; i < defects.size(); i++) {

				/*int d = (x - defect_array[i].depth_point->x) *
                 (x - defect_array[i].depth_point->x) +
                 (y - defect_array[i].depth_point->y) *
                 (y - defect_array[i].depth_point->y);*/

				int d = (x - hull[defect_array[i][2]].x) *
                (x - hull[defect_array[i][2]].x) +
                (y - hull[defect_array[i][2]].y) *
                (y - hull[defect_array[i][2]].y);

				dist += sqrt(d);
			}

			hand_radius = dist / defects.size();
			defect_array.clear();

		}
    }
    
    
}

-(void) htFilterAndThreshold{
	//cvSmooth(ctx->image, ctx->temp_image3, CV_GAUSSIAN, 11, 11, 0, 0);
	/* Remove some impulsive noise */
	//cvSmooth(ctx->temp_image3, ctx->temp_image3, CV_MEDIAN, 11, 11, 0, 0);

    int kerSize = 11;
	GaussianBlur(image_input, temp_image3, cv::Size(kerSize,kerSize), 0, 0);
    //  GaussianBlur(temp_image3, temp_image3, cv::Size(kerSize,kerSize), 0, 0);
    //  GaussianBlur(temp_image3, temp_image3, cv::Size(kerSize,kerSize), 0, 0);
    //
    //	medianBlur(temp_image3, temp_image3, kerSize);
    //  medianBlur(temp_image3, temp_image3, kerSize);
    medianBlur(temp_image3, temp_image3, kerSize);
    
    
    //temp_image3 = image_input.clone();


    cvtColor(temp_image3,temp_image3, CV_BGR2HSV);


	//thr_image = temp_image3.clone();
    //thr_image = image_input.clone();
    inRange(temp_image3, Scalar(0,0,160,0), Scalar(255,400,300,255),thr_image);

	/*
     cvMorphologyEx(ctx->thr_image, ctx->thr_image, NULL, ctx->kernel,
     CV_MOP_OPEN, 1);
     */

	morphologyEx(thr_image, thr_image, CV_MOP_OPEN, kernel);
//    
//    int esize = [self erosionSize].value*15 + 1;
//    int dsize = [self dilationSize].value*15 + 1;
//    
//    cv::Size erodeSize = cv::Size(esize, esize);
//    Mat erodeElement = cv::getStructuringElement(MORPH_ELLIPSE, erodeSize);
//    
//    cv::Size dilateSize = cv::Size(dsize, dsize);
//    Mat dilateElement = cv::getStructuringElement(MORPH_ELLIPSE, dilateSize);
//
//    
//    erode(thr_image, thr_image, erodeElement);
//    dilate(thr_image, thr_image, dilateElement);
    
}

-(void) htFindFingers{
	int n;
	int i;
	vector<cv::Point> points;
	cv::Point max_point;
	int dist1 = 0, dist2 = 0;
	int finger_distance[NUM_FINGERS + 1];

	num_fingers = 0;

	if (contour.empty() || hull.empty())
		return;

	n = contour.size();
	//points = calloc(n, sizeof(CvPoint));
	points.resize(n); // ?
	points = contour;

	//cvCvtSeqToArray(ctx->contour, points, CV_WHOLE_SEQ);

	for (i = 0; i < n; i++) {
		int dist;
		int cx = hand_center.x;
		int cy = hand_center.y;

		dist = (cx - points[i].x) * (cx - points[i].x) +
        (cy - points[i].y) * (cy - points[i].y);

		if (dist < dist1 && dist1 > dist2 && max_point.x != 0
			&& max_point.y < image_input.rows - 10) {

			finger_distance[num_fingers] = dist;
			fingers[num_fingers++] = max_point;
			if (num_fingers >= NUM_FINGERS + 1)
				break;
		}

		dist2 = dist1;
		dist1 = dist;
		max_point = points[i];
	}
    
}


-(void) htDisplay {
	int i;

	if (num_fingers == NUM_FINGERS) {

        //#if defined(SHOW_HAND_CONTOUR)
        //		cvDrawContours(ctx->image, ctx->contour,
        //			       CV_RGB(0,0,255), CV_RGB(0,255,0),
        //			       0, 1, CV_AA, cvPoint(0,0));
        //#endif


		//cvCircle(ctx->image, ctx->hand_center, 5, CV_RGB(255, 0, 255), 1, CV_AA, 0);
		//cvCircle(ctx->image, ctx->hand_center, ctx->hand_radius, CV_RGB(255, 0, 0), 1, CV_AA, 0);

		circle(image_input, hand_center, hand_radius, Scalar(255,0,255), 1);
        
		for (i = 0; i < num_fingers; i++) {
            
			//cvCircle(ctx->image, ctx->fingers[i], 10, CV_RGB(0, 255, 0), 3, CV_AA, 0);
			//cvLine(ctx->image, ctx->hand_center, ctx->fingers[i], CV_RGB(255,255,0), 1, CV_AA, 0);
            
			circle(image_input, fingers[i], 10, Scalar(0,255,0), 3);
			line(image_input, hand_center, fingers[i], Scalar(255,255,0), 1);
            
		}
        
		for (i = 0; i < num_defects; i++) {
            
			//cvCircle(ctx->image, ctx->defects[i], 2, CV_RGB(200, 200, 200), 2, CV_AA, 0);
            

            //circle(image, defects[i], 2, Scalar(200,200,200), 2 );
		}
	}
    
	//imshow("output", image_input);
	//imshow("thresholded", thr_image);
}


#pragma mark Background Substracting

-(void) bsInit{
    bsHistory = 45;
    
    frameSize.width =  self.videoCamera.imageWidth;
    frameSize.height = self.videoCamera.imageHeight;
    backgroundSubstractor = BackgroundSubtractorMOG2(bsHistory, bsThreshold);
    backgroundSubstractor.initialize(frameSize, image_input.type());

    
    back.create(frameSize, CV_8UC3);
    
    
}

@end
