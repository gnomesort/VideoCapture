//
//  CameraViewController+HandTracking.m
//  VideoCapture
//
//  Created by Aleksey Orlov on 6/19/13.
//  Copyright (c) 2013 Aleksey Orlov. All rights reserved.
//

#import "CameraViewController+HandTracking.h"
#import "CameraViewController.h"


//#import "opencv2/opencv.hpp"
//#import "opencv2/highgui/highgui.hpp"


@implementation CameraViewController (HandTracking)

//using namespace cv;
//using namespace std;

-(void) htInit{
    
//    thr_image.create(image_input.size(),CV_8UC1);
//	temp_image1.create(image_input.size(),CV_8UC1);
//	temp_image3.create(image_input.size(),CV_8UC3);
//	kernel.create(cv::Size(9,9),CV_8UC1);
//	
//	/*ctx->fingers = new CvPoint[NUM_FINGERS];
//     ctx->defects = new CvPoint[NUM_DEFECTS];*/
//    
//	fingers.resize(NUM_FINGERS);
//	defects.resize(NUM_DEFECTS);
    
}

-(void) htFindContour{
    
   

//    double threshTop = [self.thresholdTop value] * 400 + 10;
//    double threshBottom = [self.thresholdBottom value] * threshTop + 10;
//    
//    
//    //cvtColor(image, image_grayscale, CV_BGR2GRAY);
//    //Canny(image_grayscale, canny_output, threshTop, threshBottom);
//    
//	//thr_image.copyTo(temp_image1,NULL);
//    thr_image = temp_image1.clone();
//	cvtColor( temp_image3, temp_image1, CV_BGR2GRAY );
//    
//	Canny( temp_image1, canny_output, threshTop, threshBottom );
//    
//    
//    findContours(temp_image1, contours, hierarchy, CV_RETR_EXTERNAL,  CV_CHAIN_APPROX_SIMPLE, cv::Point(0,0));
//	
//	/* Select contour having greatest area */
//    
//    
//	for (int i=0; i < contours.size(); i++){
//		area = abs(contourArea(contours[i]));
//		if (area > max_area) {
//			max_area = area;
//			contour = contours[i];
//		}
//	}
//    
//	if (!contour.empty()) {
//		
//		approxPolyDP(contour, contour , 2, false);
//	}
}

-(void) htFindConvexHull{
    
//    //vector<Vec4i> defects;
//    vector<Vec4i> defect_array;
//    
//    
//	int i;
//	int x = 0, y = 0;
//	int dist = 0;
//    
//    
//    if (!contour.empty())
//        convexHull(contour, hull, true);
//    
//    if (!hull.empty()){
//        convexityDefects(contour,hull, defects);
//        
//		//if (defects && defects->total) {
//		if (!defects.empty()) {
//            
//			/*defect_array = calloc(defects->total,
//             sizeof(CvConvexityDefect));*/
//            
//			//defect_array = new CvConvexityDefect[defects->total];
//            
//			
//            
//			//cvCvtSeqToArray(defects, defect_array, CV_WHOLE_SEQ);
//            
//			defect_array = defects;
//            
//            
//			/* Average depth points to get hand center */
//			/*for (i = 0; i < defects->total && i < NUM_DEFECTS; i++) {
//             x += defect_array[i].depth_point->x;
//             y += defect_array[i].depth_point->y;
//             
//             ctx->defects[i] = cvPoint(defect_array[i].depth_point->x,
//             defect_array[i].depth_point->y);
//             }*/
//            
//			for (i = 0; i < defects.size() && i < NUM_DEFECTS; i++) {
//                
//				x += hull[defect_array[i][2]].x;
//				y += hull[defect_array[i][2]].y;
//                
//				
//			}
//            
//			x /= defects.size();
//			y /= defects.size();
//            
//            
//			num_defects = defects.size();
//			hand_center = cvPoint(x, y);
//            
//			/* Compute hand radius as mean of distances of
//             defects' depth point to hand center */
//            
//			for (i = 0; i < defects.size(); i++) {
//                
//				/*int d = (x - defect_array[i].depth_point->x) *
//                 (x - defect_array[i].depth_point->x) +
//                 (y - defect_array[i].depth_point->y) *
//                 (y - defect_array[i].depth_point->y);*/
//                
//				int d = (x - hull[defect_array[i][2]].x) *
//                (x - hull[defect_array[i][2]].x) +
//                (y - hull[defect_array[i][2]].y) *
//                (y - hull[defect_array[i][2]].y);
//                
//				dist += sqrt(d);
//			}
//            
//			hand_radius = dist / defects.size();
//			defect_array.clear();
//            
//		}
//    }

    
}


-(void) htFilterAndThreshold{
//	//cvSmooth(ctx->image, ctx->temp_image3, CV_GAUSSIAN, 11, 11, 0, 0);
//	/* Remove some impulsive noise */
//	//cvSmooth(ctx->temp_image3, ctx->temp_image3, CV_MEDIAN, 11, 11, 0, 0);
//    
//	GaussianBlur(image_input, temp_image3, cv::Size(11,11), 0, 0);
//	medianBlur(temp_image3, temp_image3, 11);
//	
//    
//	//cvCvtColor(ctx->temp_image3, ctx->temp_image3, CV_BGR2HSV);
//	cvtColor(temp_image3,temp_image3, CV_BGR2HSV);
//    
//	/*cvInRangeS(ctx->temp_image3,
//     cvScalar(0, 0, 160, 0),
//     cvScalar(255, 400, 300, 255),
//     ctx->thr_image);*/
//    
//	inRange(temp_image3, Scalar(0,0,160,0), Scalar(255,400,300,255),thr_image);
//    
//	/*
//     cvMorphologyEx(ctx->thr_image, ctx->thr_image, NULL, ctx->kernel,
//     CV_MOP_OPEN, 1);
//     */
//    
//	morphologyEx(thr_image, thr_image, CV_MOP_OPEN, kernel);
//    
//	//morphologyEx(thr_image, thr_image,
    
}



-(void) htFindFingers{
//	int n;
//	int i;
//	vector<cv::Point> points;
//	cv::Point max_point;
//	int dist1 = 0, dist2 = 0;
//	int finger_distance[NUM_FINGERS + 1];
//    
//	num_fingers = 0;
//    
//	if (contour.empty() || hull.empty())
//		return;
//    
//	n = contour.size();
//	//points = calloc(n, sizeof(CvPoint));
//	points.resize(n); // ?
//	points = contour;
//    
//	//cvCvtSeqToArray(ctx->contour, points, CV_WHOLE_SEQ);
//    
//	for (i = 0; i < n; i++) {
//		int dist;
//		int cx = hand_center.x;
//		int cy = hand_center.y;
//        
//		dist = (cx - points[i].x) * (cx - points[i].x) +
//        (cy - points[i].y) * (cy - points[i].y);
//        
//		if (dist < dist1 && dist1 > dist2 && max_point.x != 0
//			&& max_point.y < image_input.rows - 10) {
//            
//			finger_distance[num_fingers] = dist;
//			fingers[num_fingers++] = max_point;
//			if (num_fingers >= NUM_FINGERS + 1)
//				break;
//		}
//        
//		dist2 = dist1;
//		dist1 = dist;
//		max_point = points[i];
//	}
    
}


-(void) htDisplay {
//	int i;
//    
//	if (num_fingers == NUM_FINGERS) {
//        
//        //#if defined(SHOW_HAND_CONTOUR)
//        //		cvDrawContours(ctx->image, ctx->contour,
//        //			       CV_RGB(0,0,255), CV_RGB(0,255,0),
//        //			       0, 1, CV_AA, cvPoint(0,0));
//        //#endif
//        
//        
//		//cvCircle(ctx->image, ctx->hand_center, 5, CV_RGB(255, 0, 255), 1, CV_AA, 0);
//		//cvCircle(ctx->image, ctx->hand_center, ctx->hand_radius, CV_RGB(255, 0, 0), 1, CV_AA, 0);
//        
//		circle(image_input, hand_center, hand_radius, Scalar(255,0,255), 1);
//        
//		for (i = 0; i < num_fingers; i++) {
//            
//			//cvCircle(ctx->image, ctx->fingers[i], 10, CV_RGB(0, 255, 0), 3, CV_AA, 0);
//			//cvLine(ctx->image, ctx->hand_center, ctx->fingers[i], CV_RGB(255,255,0), 1, CV_AA, 0);
//            
//			circle(image_input, fingers[i], 10, Scalar(0,255,0), 3);
//			line(image_input, hand_center, fingers[i], Scalar(255,255,0), 1);
//            
//		}
//        
//		for (i = 0; i < num_defects; i++) {
//            
//			//cvCircle(ctx->image, ctx->defects[i], 2, CV_RGB(200, 200, 200), 2, CV_AA, 0);
//            
//
//            //circle(image, defects[i], 2, Scalar(200,200,200), 2 );
//		}
//	}
//    
//	imshow("output", image_input);
//	imshow("thresholded", thr_image);
}




@end
