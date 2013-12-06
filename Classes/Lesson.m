//
//  Lesson.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "Lesson.h"

@implementation Lesson

@synthesize lessonNumber = _lessonNumber;
@synthesize chapterNumber = _chapterNumber;
@synthesize lessonIndexPath = _lessonIndexPath;
@synthesize parentNumber = _parentNumber;
@synthesize contentType = _contentType;
@synthesize title = _title;
@synthesize tableHeading = _tableHeading;
@synthesize slug = _slug;
@synthesize lessonContent = _content;
@synthesize updatedDate = _updatedDate;
@synthesize exercise = _exercise;

-(id)initWithLessonNumber:(int)lessonNumber parentNumber:(int)parentNumber
{
	if (self = [self init]) 
	{
		self.lessonNumber = lessonNumber;
		self.parentNumber = parentNumber;
	}
	
	return self;
}

@end
