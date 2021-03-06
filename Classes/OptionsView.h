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
-(void)doChangeFontSize:(id)sender changeTo:(NSInteger)fontSize;
-(void)doSaveBookmark:(id)sender;
-(void)doLoadNext:(id)sender;
-(void)doLoadPrevious:(id)sender;
@end

@interface OptionsView : UIView <CAAnimationDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIView *extraOptionsView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *optionsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *bookmarkButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nightModeButton;
@property (weak, nonatomic) IBOutlet UISlider *brightnessSlider;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fontIncreaseButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fontDecreaseButton;

-(IBAction)optionsSelected:(id)sender;
-(IBAction)previousSelected:(id)sender;
-(IBAction)nextSelected:(id)sender;
-(IBAction)bookmarkSelected:(id)sender;

-(IBAction)nightModeSelected:(id)sender;
-(IBAction)fontIncreaseSelected:(id)sender;
-(IBAction)fontDecreaseSelected:(id)sender;

@property (weak, nonatomic) id <OptionsViewDelegate> delegate;
@property (nonatomic) BOOL hasNext;
@property (nonatomic) BOOL hasPrevious;
@property (nonatomic) BOOL hasBookmark;
@property (nonatomic) BOOL isNightMode;
@property (nonatomic) BOOL shouldIgnoreHideMessage;
@property (nonatomic) NSInteger fontSize;
@property (nonatomic) double brightness;

-(void)show;
-(void)hide;
-(void)hideWithDelegate:(BOOL)withDelegate;
-(void)showWithDelegate:(BOOL)withDelegate;
-(void)shouldUseNightMode:(BOOL)nightMode;
-(void)doChangeFontSize:(NSInteger)fontSize;

@end
