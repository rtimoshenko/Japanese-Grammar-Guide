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
        
        if ([self getTargetChaptersFor:ChapterViewDisplayTypeBookmarks].count == 0) {
            
//            for (Lesson *lesson in self.allChapters[5].lessons) {
//                [self.bookmarkRepository saveBookmarkForLesson:lesson];
//            }
            // TODO: disabled for testing
//
//            if (![self.chapterView lessonNumberIsBookmarked:self.lesson.lessonNumber])
//                [self.bookmarkRepository saveBookmarkForLesson:self.lesson];
        }
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
    NSArray<Chapter *> *chapters = [self getTargetChaptersFor:ChapterViewDisplayTypeChapters];
    
    Chapter *currentChapter = chapters[lesson.lessonIndexPath.section];
    NSArray <Lesson *> *currentChapterLessons = currentChapter.lessons;
    
    if (currentChapterLessons.count > lesson.lessonIndexPath.row + 1) {
        return currentChapterLessons[lesson.lessonIndexPath.row + 1];
        
    } else if (chapters.count > lesson.lessonIndexPath.section) {
        Chapter *nextChapter = chapters[lesson.lessonIndexPath.section + 1];
        return nextChapter.lessons[0];
        
    } else {
        return nil;
    }
}

- (BOOL)hasNextLessonForLesson:(Lesson *)lesson {
    return ([self getNextLessonForLesson:lesson] != nil);
}

- (Lesson *)getPreviousLessonForLesson:(Lesson *)lesson {
    
    NSArray<Chapter *> *chapters = [self getTargetChaptersFor:ChapterViewDisplayTypeChapters];
    
    Chapter *currentChapter = chapters[lesson.lessonIndexPath.section];
    NSArray <Lesson *> *currentChapterLessons = currentChapter.lessons;
    
    if (lesson.lessonIndexPath.row > 0) {
        return currentChapterLessons[lesson.lessonIndexPath.row - 1];
        
    } else if (lesson.lessonIndexPath.section > 0) {
        
        Chapter *previousChapter = chapters[lesson.lessonIndexPath.section - 1];
        return previousChapter.lessons[previousChapter.lessons.count - 1];
        
    } else {
        return nil;
    }
}

- (BOOL)hasPreviousLessonForLesson:(Lesson *)lesson {
    return ([self getPreviousLessonForLesson:lesson] != nil);
}

- (NSString *)getChapterTitleForChapter:(Chapter *)chapter {
    return @"";
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
