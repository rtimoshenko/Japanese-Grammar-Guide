//
//  LessonViewController.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractViewController.h"
#import "OptionsView.h"
#import "ReadingView.h"
#import "KanaView.h"
#import "ChapterView.h"

@class Lesson;

@interface LessonViewController : AbstractViewController <OptionsViewDelegate, ReadingViewDelegate, ChapterViewDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, CAAnimationDelegate>


@property (unsafe_unretained, nonatomic) IBOutlet UIWebView *webView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *showTableButton;
@property (unsafe_unretained, nonatomic) IBOutlet ReadingView *readingView;
@property (unsafe_unretained, nonatomic) IBOutlet KanaView *kanaView;
@property (unsafe_unretained, nonatomic) IBOutlet ChapterView *chapterView;
@property (unsafe_unretained, nonatomic) IBOutlet OptionsView *optionsView;
@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *optionsToolbar;
@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *moreOptionsToolbar;
@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *filterToolbar;
@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *filterControl;

-(IBAction)didSelectFilter:(id)sender;
-(IBAction)didPressShowTableButton:(id)sender;
- (void)shouldLoadLesson:(id)sender lesson:(Lesson *)lesson;

@property (strong, nonatomic) Lesson *lesson;
@property (strong, nonatomic) Lesson *exercise;
@property (nonatomic) BOOL isExercise;

@end
