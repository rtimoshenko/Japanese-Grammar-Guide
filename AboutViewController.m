//
//  AboutViewController.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController()
@end

@implementation AboutViewController

@synthesize moreAppsButton = _moreAppsButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) 
    {
        // Custom initialization
        self.title = NSLocalizedString(@"About", @"About");
    }
    return self;
}

-(IBAction)moreAppsButtonPressed:(id)sender
{
	//NSString *referralLink = @"http://itunes.apple.com/artist/ronald-timoshenko/id377785103";
    
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:referralLink]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.com/apps/ronaldtimoshenko"]];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload
{
    [self setMoreAppsButton:nil];
    
    [super viewDidUnload];
}

@end
