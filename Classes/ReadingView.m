//
//  ReadingViewController.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/28/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "ReadingView.h"

@interface ReadingView()
@property (nonatomic) BOOL isVisible;
@property (strong, nonatomic) NSTimer *timer;
-(void)setVisibilityTimer;
@end

@implementation ReadingView

@synthesize delegate = _delegate;
@synthesize label = _label;
@synthesize timer = _timer;
@synthesize isVisible = _isVisible;
@synthesize closeButton = _closeButton;

-(void)setLabelText:(NSString *)text
{
    if (!self.isVisible)
        self.label.text = text;
}

-(void)show
{    
	if (!self.isVisible)
	{
		self.isVisible = YES;
		
		// Make sure we don't animate needlessly
		if (self.alpha < 1.0f)
		{
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.25f];
			[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self cache:YES];
			
			self.alpha = 1.0f;
			[UIView commitAnimations];
		}
		
		[self setVisibilityTimer];
    }
}

-(void)hide
{
    [self.timer invalidate];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25f];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self cache:YES];
    
    self.alpha = 0.0f;
    [UIView commitAnimations];
	
	self.isVisible = NO;
    [self.delegate didHideReadingView:self didHide:YES];
}

-(IBAction)selectedCloseButton:(id)sender
{
    [self hide];
}

-(void)setVisibilityTimer
{
	// Clear toolbartimer
	if (self.timer != nil)
		[self.timer invalidate];
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hide) userInfo:nil repeats:NO];
}

- (void)viewDidUnload
{
	self.delegate = nil;
	[self.timer invalidate];
	[self setTimer:nil];

	[self setCloseButton:nil];
    [self setLabel:nil];
}

@end
