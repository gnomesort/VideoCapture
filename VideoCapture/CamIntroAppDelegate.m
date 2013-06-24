//
//  CamIntroAppDelegate.m
//  VideoCapture
//
//  Created by Aleksey Orlov on 5/7/13.
//  Copyright (c) 2013 Aleksey Orlov. All rights reserved.
//

#import "CamIntroAppDelegate.h"
#import "MyViewController.h"
#import "MyViewController2.h"
#import "CameraViewController.h"


@implementation CamIntroAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Override point for customization after application launch.
    
    //MyViewController * mvc1 = [[MyViewController alloc]init];
    //MyViewController2 * mvc2 = [[MyViewController2 alloc]init];
    
    CameraViewController * camVC1 = [[CameraViewController alloc]init];
    CameraViewController * camVC2 = [[CameraViewController alloc]init];
    CameraViewController * camVC3 = [[CameraViewController alloc]init];
    CameraViewController * camVC4 = [[CameraViewController alloc]init];
    
    [camVC1.tabBarItem setTitle: @"+"];
    [camVC2.tabBarItem setTitle: @"+"];
    [camVC3.tabBarItem setTitle: @"+"];
    [camVC4.tabBarItem setTitle: @"+"];
    
    
    [camVC1 setTag:10];
    [camVC2 setTag:20];
    [camVC3 setTag:30];
    [camVC4 setTag:40];
    
    
    
    UIPinchGestureRecognizer * pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:camVC1 action:@selector(pinchRec)];
    [[camVC1 view] addGestureRecognizer: pinchRecognizer];
    [[camVC2 view] addGestureRecognizer: pinchRecognizer];
    [[camVC3 view] addGestureRecognizer: pinchRecognizer];
    [[camVC4 view] addGestureRecognizer: pinchRecognizer];
    
    
    UITabBarController * tbc = [[UITabBarController alloc] init];
    
    //[mvc1.tabBarItem setTitle:@"mvc1"];
    //[mvc2.tabBarItem setTitle:@"mvc2"];
    
    //[tbc setViewControllers:[NSArray arrayWithObjects:camVC, mvc1,mvc2, nil]];
    [tbc setViewControllers:[NSArray arrayWithObjects:camVC1, camVC2, camVC3, camVC4, nil]];
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [self.window setRootViewController: tbc];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
