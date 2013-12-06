//
//  OptionMenuViewController.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/25/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "AbstractViewController.h"

#define NIGHT_MODE_KEY @"NightModeKey"
#define FONT_SIZE_KEY @"FontSizeKey"

#define DEFAULT_FONT_SIZE 16
#define MAX_FONT_SIZE 20
#define MIN_FONT_SIZE 12

@class LessonViewController;

@protocol OptionsViewDelegate
@optional
-(void)didShowOptionsView:(id)sender didShow:(BOOL)didShow;
-(void)didHideOptionsView:(id)sender didHide:(BOOL)didHide;
-(void)shouldUseNightMode:(id)sender useNightMode:(BOOL)nightMode;
-(void)doChangeFontSize:(id)sender changeTo:(int)fontSize;
-(void)doSaveBookmark:(id)sender;
-(void)doLoadNext:(id)sender;
-(void)doLoadPrevious:(id)sender;
@end

@interface OptionsView : UIView

@property (nonatomic, strong) NSTimer *timer;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *extraOptionsView;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *optionsButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *previousButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *bookmarkButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *nightModeButton;
@property (unsafe_unretained, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *fontIncreaseButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *fontDecreaseButton;

-(IBAction)optionsSelected:(id)sender;
-(IBAction)previousSelected:(id)sender;
-(IBAction)nextSelected:(id)sender;
-(IBAction)bookmarkSelected:(id)sender;

-(IBAction)nightModeSelected:(id)sender;
-(IBAction)fontIncreaseSelected:(id)sender;
-(IBAction)fontDecreaseSelected:(id)sender;

@property (unsafe_unretained, nonatomic) id <OptionsViewDelegate> delegate;
@property (nonatomic) BOOL hasNext;
@property (nonatomic) BOOL hasPrevious;
@property (nonatomic) BOOL hasBookmark;
@property (nonatomic) BOOL isNightMode;
@property (nonatomic) BOOL shouldIgnoreHideMessage;
@property (nonatomic) int fontSize;
@property (nonatomic) double brightness;

-(void)show;
-(void)hide;
-(void)hideWithDelegate:(BOOL)withDelegate;
-(void)showWithDelegate:(BOOL)withDelegate;
-(void)shouldUseNightMode:(BOOL)nightMode;
-(void)doChangeFontSize:(int)fontSize;

@end
