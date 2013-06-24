//
//  MyViewController.m
//  VideoCapture
//
//  Created by Aleksey Orlov on 5/7/13.
//  Copyright (c) 2013 Aleksey Orlov. All rights reserved.
//

#import "MyViewController.h"
#import "MyViewController2.h"

@interface MyViewController ()

@end

@implementation MyViewController

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

-(void)pinchRec{
    NSLog(@"pinch detected");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToWin2Click:(id)sender {
   }

- (IBAction)goToWin2:(id)sender {
    NSLog(@"go to win 2");
    MyViewController2 * mvc2 = [[MyViewController2 alloc] init];
    [self presentViewController:mvc2 animated:YES completion:nil];
    
}
@end
