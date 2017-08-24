//
//  Lesson.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum 
{
	kLesson,
	kExercise
} ContentType;

@interface Lesson : NSObject

@property (nonatomic) NSInteger lessonNumber;
@property (nonatomic) NSInteger chapterNumber;
@property (nonatomic) NSInteger parentNumber;
@property (nonatomic) ContentType contentType;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *tableHeading;
@property (nonatomic, copy) NSString *slug;
@property (nonatomic, copy) NSString *lessonContent;
@property (nonatomic, copy) NSDate *updatedDate;
@property (nonatomic, strong) NSIndexPath *lessonIndexPath;
@property (nonatomic, strong) Lesson *exercise;

-(id)initWithLessonNumber:(NSInteger)lessonNumber parentNumber:(NSInteger)parentNumber;

@end
