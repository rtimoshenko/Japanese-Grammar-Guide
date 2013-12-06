//
//  BookmarkRepository.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractRepository.h"

@class Bookmark;
@class Lesson;

@interface BookmarkRepository : AbstractRepository

@property (nonatomic, strong) NSArray *bookmarks;

-(void)saveBookmark:(Bookmark *)bookmark;
-(void)saveBookmarkForLesson:(Lesson *)lesson;
-(Bookmark *)bookmarkForLessonNumber:(int)lessonNumber;
-(void)deleteBookmark:(int)bookmarkNumber;
-(void)saveSortOrder;

@end