//
//  KanaView.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/28/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "AbstractViewController.h"

typedef NS_ENUM(NSInteger, DisplayType) {
    kLessons,
    kBookmarks,
    kSearch,
};

@class Lesson;

@protocol ChapterViewDelegate
@optional
-(void)shouldLoadLesson:(id)sender lesson:(Lesson *)lesson;
-(void)didBeginSearch:(id)sender;
-(void)didCancelSearch:(id)sender;
-(void)didDeleteBookmark:(id)sender;
@end

@interface ChapterView : UIView <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, UIScrollViewDelegate, CAAnimationDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UIView *searchOverlayView;
@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *filterToolbar;
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (unsafe_unretained, nonatomic) IBOutlet UISearchBar *searchBar;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *resultsLabel;

@property (nonatomic, strong) UIView *disableOverlayView;
@property (unsafe_unretained, nonatomic) id <ChapterViewDelegate> delegate;
@property (unsafe_unretained, nonatomic) UINavigationItem *parentNavigationItem;
@property (unsafe_unretained, nonatomic) UINavigationController *parentNavigationController;
@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *settingsButton;
@property (nonatomic, strong) NSIndexPath *cameFromIndexPath;
@property (nonatomic, strong) NSArray *chapters;
@property (nonatomic, strong) NSMutableArray *bookmarkedChapters;
@property (nonatomic, strong) NSMutableArray *foundChapters;
@property (nonatomic) DisplayType displayType;
@property (nonatomic) BOOL isNightMode;

-(void)configureView;
-(void)resetSearchField;
-(void)reloadAsNightTheme:(BOOL)useNightMode;
-(void)didHideChapterView:(BOOL)didHide;
-(BOOL)hasNextLesson;
-(BOOL)hasPreviousLesson;
-(BOOL)lessonNumberIsBookmarked:(NSInteger)lessonNumber;
-(Lesson *)loadNextLessonAndSaveIndexPath:(BOOL)shouldSave;
-(Lesson *)loadPreviousLessonAndSaveIndexPath:(BOOL)shouldSave;
-(Lesson *)lessonWithIndexPath:(NSIndexPath *)indexPath;


@end
