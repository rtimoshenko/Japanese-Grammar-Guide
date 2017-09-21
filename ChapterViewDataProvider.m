//
//  ChapterViewDataProvider.m
//  LearningJapanese
//
//  Created by Sam Clewlow on 20/08/2017.
//  Copyright © 2017 Ronald Timoshenko. All rights reserved.
//

#import "ChapterViewDataProvider.h"

#import "LessonRepository.h"
#import "BookmarkRepository.h"
#import "Bookmark.h"
#import "AppDelegate.h"
#import "Chapter.h"
#import "Lesson.h"


@implementation ChapterViewDataProvider


#pragma mark - Init

- (instancetype)initWithChapters:(NSArray<Chapter *> *)chapters {
    if (self = [super init]) {
        
        self.allChapters = [self lessonRepository].chapters;
    }
    return self;
}


#pragma mark - Chapter View Model Access

- (NSArray<Chapter *> *)chaptersForSearchTerm:(NSString *)searchTerm
                                  displayType:(ChapterViewDisplayType)displayType {
    
    NSArray *targetChapters = [self getTargetChaptersFor:displayType];
    return [self filterChapters:targetChapters forSearchTerm:searchTerm];
}

- (NSArray<Chapter *> *)chaptersAfterDeletingBookmarkedLesson:(Lesson *)lesson
                                                 searchString:(NSString *)searchString {
    
    Bookmark *bookmark = [self.bookmarkRepository bookmarkForLessonNumber:lesson.lessonNumber];
    [self.bookmarkRepository deleteBookmark:bookmark.bookmarkNumber];
    
    return [self chaptersForSearchTerm:searchString
                           displayType:ChapterViewDisplayTypeBookmarks];
}

- (BOOL)isLessonBookmarked:(Lesson *)lesson {
    
    NSArray<Chapter *> *bookmarkChapters = [self getTargetChaptersFor:ChapterViewDisplayTypeBookmarks];
    for (Chapter *bookmarkChapter in bookmarkChapters) {
        for (Lesson *bookmarkLesson in bookmarkChapter.lessons) {
            if (bookmarkLesson.lessonNumber == lesson.lessonNumber) {
                return YES;
            }
        }
    }
    
    return NO;
}

- (Lesson *)getNextLessonForLesson:(Lesson *)lesson {
    
    return [self.lessonRepository nextLesson:lesson.lessonNumber];
}

- (BOOL)hasNextLessonForLesson:(Lesson *)lesson {
    return  [self.lessonRepository hasNextLesson:lesson.lessonNumber];
}

- (Lesson *)getPreviousLessonForLesson:(Lesson *)lesson {
    return [self.lessonRepository previousLesson:lesson.lessonNumber];
}

- (BOOL)hasPreviousLessonForLesson:(Lesson *)lesson {
    return [self.lessonRepository hasPreviousLesson:lesson.lessonNumber];
}

- (NSString *)getChapterTitleForChapter:(Chapter *)chapter {
    return @"";
}

- (BOOL)hasBookmarkForLesson:(Lesson *)lesson {
    
    NSArray<Bookmark *> *bookmarks = [self.bookmarkRepository bookmarks];
    for (Bookmark *bookmark in bookmarks) {
        if (bookmark.lessonNumber == lesson.lessonNumber) {
            return YES;
        }
    }
    
    return NO;
}

- (void)saveCurrentLesson:(Lesson *)lesson {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:lesson.lessonIndexPath.section forKey:SAVED_CHAPTER_KEY];
    [defaults setInteger:lesson.lessonIndexPath.row forKey:SAVED_LESSON_KEY];
    [defaults synchronize];
}

- (Lesson *)getLastViewedLesson {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger chapter = [defaults integerForKey:SAVED_CHAPTER_KEY];
    NSInteger lesson = [defaults integerForKey:SAVED_LESSON_KEY];
    
    return self.lessonRepository.chapters[chapter].lessons[lesson];
}

#pragma mark - Private Helpers

- (NSArray<Chapter *> *)getTargetChaptersFor:(ChapterViewDisplayType)type {
    
    switch (type) {
        case ChapterViewDisplayTypeBookmarks:
            return [self.lessonRepository lessonsWithBookmarks:self.bookmarkRepository];
            break;
        case ChapterViewDisplayTypeChapters:
            return self.allChapters;
            break;
    }
}

- (NSArray<Chapter *> *)filterChapters:(NSArray<Chapter *> *)chapters
                         forSearchTerm:(NSString *)searchTerm {
    
    if (searchTerm == nil || searchTerm.length == 0) {
        return chapters;
    }
    
    NSMutableArray *lessonResults = nil;
    NSMutableArray *chapterResults = [NSMutableArray array];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(lessonContent contains[cd] %@) or (title contains[cd] %@)", searchTerm, searchTerm];
    
    // Update the filtered array based on the search text
    for (Chapter *chapter in chapters)
    {
        // Since we will be modifying the source array using a
        // predicate, let's make sure to create copies
        lessonResults = [chapter.lessons mutableCopy];
        [lessonResults filterUsingPredicate:searchPredicate];
        
        if ([lessonResults count] > 0)
        {
            Chapter *chapterResult = [[Chapter alloc] initWithChapterNumber:chapter.chapterNumber];
            chapterResult.lessons = lessonResults;
            chapterResult.title = chapter.title;
            
            [chapterResults addObject:chapterResult];
        }
    }
    
    return chapterResults;
}

#pragma mark - Lazy properties

- (LessonRepository *)lessonRepository
{
    return [self.appDelegate lessonRepository];
}

- (BookmarkRepository *)bookmarkRepository
{
    return [self.appDelegate bookmarkRepository];
}

-  (AppDelegate *)appDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

@end
