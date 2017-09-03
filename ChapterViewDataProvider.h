//
//  ChapterViewDataProvider.h
//  LearningJapanese
//
//  Created by Sam Clewlow on 20/08/2017.
//  Copyright © 2017 Ronald Timoshenko. All rights reserved.
//

typedef NS_ENUM(NSInteger, ChapterViewDisplayType) {
    ChapterViewDisplayTypeChapters = 0,
    ChapterViewDisplayTypeBookmarks = 1
};

#import <Foundation/Foundation.h>

@class Chapter;
@class Lesson;

@interface ChapterViewDataProvider : NSObject

@property (nonatomic, strong) NSArray<Chapter *> *allChapters;
@property (nonatomic, strong) NSArray<Chapter *> *allBookmarks;

- (instancetype)initWithChapters:(NSArray<Chapter *> *)chapters;
- (BOOL)isLessonBookmarked:(Lesson *)lesson;
- (Lesson *)getNextLessonForLesson:(Lesson *)lesson;
- (BOOL)hasNextLessonForLesson:(Lesson *)lesson;
- (Lesson *)getPreviousLessonForLesson:(Lesson *)lesson;
- (BOOL)hasPreviousLessonForLesson:(Lesson *)lesson;

- (NSArray<Chapter *> *)chaptersForSearchTerm:(NSString *)searchTerm
                                  displayType:(ChapterViewDisplayType)displayType;
- (NSArray<Chapter *> *)chaptersAfterDeletingBookmarkedLesson:(Lesson *)lesson
                                                 searchString:(NSString *)searchString;

@end
