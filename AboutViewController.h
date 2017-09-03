//
//  AboutViewController.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractViewController.h"

@interface AboutViewController : AbstractViewController

@property (weak, nonatomic) IBOutlet UIButton *moreAppsButton;

-(IBAction)moreAppsButtonPressed:(id)sender;

@end
