//
//  ViewController.m
//  StompBox
//
//  Created by Michael Webster on 7/02/2015.
//  Copyright (c) 2015 Mike Webster Ltd. All rights reserved.
//

#import "ViewController.h"
#import "CalcDelay.h"
#import "TimerThreadIf.h"

@interface ViewController ()

@end

@implementation ViewController
{
    UIColor *redColour;
    UIColor *blueColour;
    CalcDelay *fCalcDelay;
    TimerThreadIf *fTimer;
}
@synthesize tempoText;
@synthesize tempoSliderOutlet;
@synthesize tempoDisplay;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    redColour = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
    blueColour = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    fCalcDelay = [[CalcDelay alloc]init];
    [fCalcDelay setNumSamples: 5];
    fTimer = [[TimerThreadIf alloc]init];
    [fTimer setTickResponder:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tempoSliderAction:(id)sender forEvent:(UIEvent *)event {
}

- (IBAction)tapButton:(id)sender forEvent:(UIEvent *)event {
    
    NSString* tapTitle = [sender currentTitle];
    NSLog(@"Tap Button title is: %@\n", tapTitle);
    NSLog(@"Time Of Event is: %f", [event timestamp]);
    [fCalcDelay addInterval:[event timestamp]];
    NSLog(@"Current Delay is: %d", [fCalcDelay fCurrentDelay]);
    NSLog(@"Current BPM is: %d", [fCalcDelay getBpm]);
    if ([fCalcDelay fCurrentDelay] != 0)
    {
        [fTimer setDelay:fCalcDelay.fCurrentDelay];
        if (!fTimer.isRunning)
        {
            [fTimer startTimer];
        }
        else
        {
            [fTimer restart];
        }
    }
}

-(void)respondToTick
{
    NSLog(@"In respond To Tick - Current Delay is: %d", fTimer.fDelayMs);
    NSLog(@"In respond To Tick - Current BPM is: %d", [fCalcDelay getBpm]);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [tempoText setText:[NSString stringWithFormat:
                               @"%d BPM", [fCalcDelay getBpm]]];
         }];
    static bool currentlyBlue = true;
    if (currentlyBlue)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            tempoDisplay.backgroundColor = redColour;
        }];
        
        currentlyBlue = false;
    }
    else
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            tempoDisplay.backgroundColor = blueColour;
        }];
        currentlyBlue = true;
    }
    
    
}
@end
