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

@protocol LessonViewControllerDelegate
- (void) didChangeToLessonAt:(NSIndexPath *)indexPath;
- (void) didActivateNightMode:(BOOL)active;
@end


@interface LessonViewController : AbstractViewController <OptionsViewDelegate, ReadingViewDelegate, ChapterViewDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, CAAnimationDelegate>


@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *showTableButton;
@property (weak, nonatomic) IBOutlet ReadingView *readingView;
@property (weak, nonatomic) IBOutlet KanaView *kanaView;
@property (weak, nonatomic) IBOutlet ChapterView *chapterView;
@property (weak, nonatomic) IBOutlet OptionsView *optionsView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@property (weak, nonatomic) IBOutlet UIToolbar *optionsToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *moreOptionsToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *filterToolbar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterControl;
@property (nonatomic, weak) id<LessonViewControllerDelegate> delegate;

- (void)shouldLoadLesson:(id)sender lesson:(Lesson *)lesson;

- (void)refreshBookmark;

@property (strong, nonatomic) Lesson *lesson;
@property (strong, nonatomic) Lesson *exercise;
@property (nonatomic) BOOL isExercise;

@end
