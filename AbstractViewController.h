//
//  BaseViewController.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/22/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#define SAVED_CHAPTER_KEY @"SavedChapterKey"
#define SAVED_LESSON_KEY @"SavedLessonKey"

typedef enum 
{
	kHiragana,
	kKatakana
} Syllabary;

@interface AbstractViewController : UIViewController

-(LessonRepository *)lessonRepository;
-(BookmarkRepository *)bookmarkRepository;
@property (nonatomic, strong) AppDelegate *appDelegate;

-(NSString *)deviceNibWithName:(NSString *)nibName;

@end
