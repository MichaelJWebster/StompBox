//
//  ViewController.h
//  StompBox
//
//  Created by Michael Webster on 7/02/2015.
//  Copyright (c) 2015 Mike Webster Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TickResponder.h"

@interface ViewController : UIViewController<TickResponder>
@property (weak, nonatomic) IBOutlet UITextField *tempoText;
@property (weak, nonatomic) IBOutlet UISlider *tempoSliderOutlet;
- (IBAction)tempoSliderAction:(id)sender forEvent:(UIEvent *)event;
- (IBAction)tapButton:(id)sender forEvent:(UIEvent *)event;
@property (weak, nonatomic) IBOutlet UILabel *tempoDisplay;
@end
