//
//  OptionMenuViewController.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/25/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "OptionsView.h"
#import <QuartzCore/QuartzCore.h>

@interface OptionsView()
@property (nonatomic) BOOL isVisible;
@property (nonatomic) BOOL isVisibleExtraOptions;
-(void)toggleButton:(UIBarButtonItem *)button shouldEnable:(BOOL)enable;
-(void)showExtraOptions;
-(void)hideExtraOptions;
-(void)setDisplayTimer;
@end

@implementation OptionsView


@synthesize extraOptionsView = _extraOptionsView;
@synthesize optionsButton = _optionsButton;
@synthesize previousButton = _previousButton;
@synthesize nextButton = _nextButton;
@synthesize bookmarkButton = _bookmarkButton;

@synthesize nightModeButton = _nightModeButton;
@synthesize brightnessSlider = _brightnessSlider;
@synthesize fontIncreaseButton = _fontIncreaseButton;
@synthesize fontDecreaseButton = _fontDecreaseButton;

@synthesize isVisible = _isVisible;
@synthesize isVisibleExtraOptions = _isVisibleExtraOptions;
@synthesize delegate = _delegate;
@synthesize hasNext = _hasNext;
@synthesize hasPrevious = _hasPrevious;
@synthesize hasBookmark = _hasBookmark;
@synthesize isNightMode = _isNightMode;
@synthesize shouldIgnoreHideMessage = _shouldIgnoreHideMessage;
@synthesize fontSize = _fontSize;
@synthesize brightness = _brightness;
@synthesize timer = _displayTimer;




-(void)show
{
    [self showWithDelegate:YES];
}

-(void)showWithDelegate:(BOOL)withDelegate
{
	if (self.fontSize < 1)
	{
		self.fontSize = DEFAULT_FONT_SIZE;
	}
	else if (self.fontSize < MIN_FONT_SIZE)
	{
		self.fontSize = MIN_FONT_SIZE;
	}
	else if (self.fontSize > MAX_FONT_SIZE)
	{
		self.fontSize = MAX_FONT_SIZE;
	}
    
	[self toggleButton:self.fontIncreaseButton shouldEnable:(self.fontSize < MAX_FONT_SIZE)];
    [self toggleButton:self.fontDecreaseButton shouldEnable:(self.fontSize > MIN_FONT_SIZE)];

    
	if (!self.isVisible)
	{
		self.isVisible = YES;
		
		// Make sure we don't animate needlessly
		if (self.alpha != 1.0f)
		{
			CATransition *transition = [CATransition animation];
            
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.duration = 0.25;
            transition.type = kCATransitionPush;
            transition.subtype = kCATransitionFromTop;
            transition.delegate = self;
            
            [self.layer addAnimation:transition forKey:nil];
            self.hidden = NO;
            self.alpha = 1.0f;
		}
        
        if (withDelegate)
            [self.delegate didShowOptionsView:self didShow:YES];
    }
    
    // Always reset the timer
    [self setDisplayTimer];
}

-(void)hide
{
    [self hideWithDelegate:YES];
}

-(void)hideWithDelegate:(BOOL)withDelegate
{
    if (!self.shouldIgnoreHideMessage && self.isVisible)
    {
		[self.timer invalidate];

        CATransition *transition = [CATransition animation];
        
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.duration = 0.25;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromBottom;
        transition.delegate = self;
        
        [self.layer addAnimation:transition forKey:nil];
        self.hidden = YES;
        self.alpha = 0.0f;
        
        self.isVisible = NO;
        
        [self hideExtraOptions];
        
        if (withDelegate)
            [self.delegate didHideOptionsView:self didHide:YES];
    }
}

-(void)showExtraOptions
{
	if (!self.isVisibleExtraOptions)
	{
        self.shouldIgnoreHideMessage = YES;
		self.isVisibleExtraOptions = YES;
		
		// Make sure we don't animate needlessly
		if (self.extraOptionsView.alpha < 1.0f)
		{
			CATransition *transition = [CATransition animation];
            
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.duration = 0.25;
            transition.type = kCATransitionPush;
            transition.subtype = kCATransitionFromTop;
            transition.delegate = self;
            
            [self.extraOptionsView.layer addAnimation:transition forKey:nil];
            self.extraOptionsView.hidden = NO;
            self.extraOptionsView.alpha = 1.0f;
        }
        
        // UIScreen access only available in iOS5
        [self.brightnessSlider setValue:[[UIScreen mainScreen] brightness]];
        
        // UIButton tint color only available in iOS5
        self.optionsButton.tintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    }
}

-(void)hideExtraOptions
{
    CATransition *transition = [CATransition animation];
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.duration = 0.25;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    
    [self.extraOptionsView.layer addAnimation:transition forKey:nil];
    self.extraOptionsView.hidden = YES;
    self.extraOptionsView.alpha = 0.0f;
	
    self.shouldIgnoreHideMessage = NO;
	self.isVisibleExtraOptions = NO;

    self.optionsButton.tintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    [self setDisplayTimer];
}

-(void)setHasNext:(BOOL)hasNext
{
	_hasNext = hasNext;

	[self toggleButton:self.nextButton shouldEnable:hasNext];
}

-(void)setHasPrevious:(BOOL)hasPrevious
{
	_hasPrevious = hasPrevious;

	[self toggleButton:self.previousButton shouldEnable:hasPrevious];
}

-(void)setHasBookmark:(BOOL)hasBookmark
{
	_hasBookmark = hasBookmark;

	[self toggleButton:self.bookmarkButton shouldEnable:!hasBookmark];
}

-(void)setDisplayTimer
{
	// Clear toolbartimer
	if (self.timer != nil)
		[self.timer invalidate];
	
	//self.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hide) userInfo:nil repeats:NO];
}

-(IBAction)optionsSelected:(id)sender
{
    if (self.isVisibleExtraOptions)
        [self hideExtraOptions];
    else
        [self showExtraOptions];
    
    [self setDisplayTimer];
}

-(IBAction)previousSelected:(id)sender
{
    [self.delegate doLoadPrevious:self];
    
    [self setDisplayTimer];
}

-(IBAction)nextSelected:(id)sender
{
    [self.delegate doLoadNext:self];
    
    [self setDisplayTimer];
}

-(IBAction)bookmarkSelected:(id)sender
{
    [self.delegate doSaveBookmark:self];
    [self setHasBookmark:YES];
    
    [self setDisplayTimer];
}

-(IBAction)nightModeSelected:(id)sender
{
    [self shouldUseNightMode:!self.isNightMode];
    
    [self setDisplayTimer];
}

-(IBAction)brightnessChanges:(UISlider *)sender 
{
    [[UIScreen mainScreen] setBrightness:[sender value]];
    [[UIScreen mainScreen] setWantsSoftwareDimming:YES];
}

-(IBAction)fontIncreaseSelected:(id)sender
{
    NSInteger newSize = self.fontSize + 1;
    
    if (newSize > MAX_FONT_SIZE)
        newSize = MAX_FONT_SIZE;
    
    [self doChangeFontSize:newSize];
	[self toggleButton:self.fontIncreaseButton shouldEnable:(newSize < MAX_FONT_SIZE)];
    [self toggleButton:self.fontDecreaseButton shouldEnable:(newSize > MIN_FONT_SIZE)];
}

-(IBAction)fontDecreaseSelected:(id)sender
{
    NSInteger newSize = self.fontSize - 1;
    
    if (newSize < MIN_FONT_SIZE)
        newSize = MIN_FONT_SIZE;
    
    [self doChangeFontSize:newSize];
    [self toggleButton:self.fontIncreaseButton shouldEnable:(newSize < MAX_FONT_SIZE)];
	[self toggleButton:self.fontDecreaseButton shouldEnable:(newSize > MIN_FONT_SIZE)];
}




-(void)shouldUseNightMode:(BOOL)nightMode
{
    self.isNightMode = nightMode;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	[defaults setBool:nightMode forKey:NIGHT_MODE_KEY];
	[defaults synchronize];
    
	[self.delegate shouldUseNightMode:self useNightMode:nightMode];
}

-(void)doChangeFontSize:(NSInteger)fontSize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	[defaults setInteger:fontSize forKey:FONT_SIZE_KEY];
	[defaults synchronize];
    
    self.fontSize = fontSize;
	[self.delegate doChangeFontSize:self changeTo:fontSize];
}


-(void)toggleButton:(UIBarButtonItem *)button shouldEnable:(BOOL)enable
{
    button.enabled = enable;
    
    if (enable) {
        button.tintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    } else {
        button.tintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
    }
}


- (void)viewDidUnload
{
	self.delegate = nil;
	[self.timer invalidate];
	[self setTimer:nil];

	[self setExtraOptionsView:nil];
    [self setOptionsButton:nil];
    [self setPreviousButton:nil];
    [self setNextButton:nil];
    [self setBookmarkButton:nil];
    
    [self setNightModeButton:nil];
	[self setBrightnessSlider:nil];
    [self setFontIncreaseButton:nil];
    [self setFontDecreaseButton:nil];
}

@end
