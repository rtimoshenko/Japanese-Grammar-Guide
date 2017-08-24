//
//  LessonRepository.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractRepository.h"

@class Lesson;
@class BookmarkRepository;

@interface LessonRepository : AbstractRepository

@property (nonatomic, strong) NSArray *chapters;
@property (nonatomic, strong) NSArray *lessons;
@property (nonatomic, strong) NSArray *exercises;

-(Lesson *)lessonWithId:(NSInteger)lessonNumber;
-(Lesson *)lessonWithIndexPath:(NSIndexPath *)indexPath;
-(NSString *)sectionTitle:(NSInteger)lessonNumber;
-(Lesson *)nextLesson:(NSInteger)currentLessonNumber;
-(Lesson *)previousLesson:(NSInteger)currentLessonNumber;
-(Lesson *)exerciseForLesson:(NSInteger)lessonNumber;
-(NSArray *)lessonsWithBookmarks:(BookmarkRepository *)bookmarkRepository;
-(BOOL)hasNextLesson:(NSInteger)currentLessonNumber;
-(BOOL)hasPreviousLesson:(NSInteger)currentLessonNumber;

@end
