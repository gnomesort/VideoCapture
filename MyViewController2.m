//
//  MyViewController2.m
//  VideoCapture
//
//  Created by Aleksey Orlov on 5/7/13.
//  Copyright (c) 2013 Aleksey Orlov. All rights reserved.
//

#import "MyViewController2.h"
//#import "MyViewController.h"

@interface MyViewController2 ()

@end

@implementation MyViewController2

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rotationDetected:(id)sender {
    
    NSLog(@"rotation detected");
}
@end
