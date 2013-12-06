//
//  Chapter.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "Chapter.h"

@implementation Chapter

@synthesize chapterNumber = _chapterNumber;
@synthesize title = _title;
@synthesize lessons = _lessons;

-(id)initWithChapterNumber:(int)chapterNumber
{
	if (self = [self init])
    {
		self.chapterNumber = chapterNumber;
        self.title = @"";
    }

	return self;
}

-(NSArray *)lessons
{
	if (!_lessons)
		_lessons = [[NSArray alloc] init];

	return _lessons;
}

@end