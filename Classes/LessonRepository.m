//
//  LessonRepository.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "LessonRepository.h"
#import "BookmarkRepository.h"
#import "Bookmark.h"
#import "Lesson.h"
#import "Chapter.h"
#import "FMDatabase.h"

@interface LessonRepository ()
-(void)checkAndCreateDatabase;
-(NSArray *)queryChapters;
-(Lesson *)lessonFromResultSet:(FMResultSet *)rs;
-(Chapter *)chapterFromResultSet:(FMResultSet *)rs;
@end


@implementation LessonRepository

@synthesize chapters = _chapters;
@synthesize lessons = _lessons;
@synthesize exercises = _exercises;
@synthesize dbPath = _dbPath;


-(id)init 
{
    if (self = [super init])
		[self checkAndCreateDatabase];
	
	return self;
}

-(NSArray *)chapters
{
	if (!_chapters)
    {
        NSMutableArray *chapters = [NSMutableArray array];
        
        @autoreleasepool {
            for (Chapter *c in [self queryChapters])
                [chapters addObject:c];
        }
        
		_chapters = chapters;
    }
    
	return _chapters;
}

-(NSArray *)lessons
{
	if (!_lessons)
    {	
        NSMutableArray *lessons = [NSMutableArray array];
        
        @autoreleasepool {
            for (Chapter *c in self.chapters) 
            {
                for (Lesson *l in c.lessons)
                    [lessons addObject:l];
            }
        }
        
        _lessons = lessons;
    }
	
	return _lessons;
}

-(void)checkAndCreateDatabase
{
	// Get the path to the documents directory and append the databaseName
	[super checkAndCreateDatabase:@"learning_japanese_2_0_0.sqlite"];
    
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// Remove old dbs
	@try 
	{
		NSString *oldDb = [documentsDir stringByAppendingPathComponent:@"learning_japanese.sqlite3"];
		NSString *oldDbTwo = [documentsDir stringByAppendingPathComponent:@"learning_japanese_1_0_1.sqlite3"];
        NSString *oldDbThree = [documentsDir stringByAppendingPathComponent:@"learning_japanese_1_0_2.sqlite3"];
		
		if([fileManager fileExistsAtPath:oldDb])
			[fileManager removeItemAtPath:oldDb error:nil];

		if ([fileManager fileExistsAtPath:oldDbTwo])
			[fileManager removeItemAtPath:oldDbTwo error:nil];
        
		if ([fileManager fileExistsAtPath:oldDbThree])
			[fileManager removeItemAtPath:oldDbThree error:nil];
	}
	@catch (NSException * e) {} // swallow exceptions
}

-(Lesson *)lessonWithId:(int)lessonNumber
{
	Lesson *lesson = nil;
    
    @autoreleasepool {
        for (Lesson *l in self.lessons) 
        {
            if (l.lessonNumber == lessonNumber)
            {
                lesson = l;
                break;
            }
        }
    }
	
	return lesson;
}

-(Lesson *)lessonWithIndexPath:(NSIndexPath *)indexPath
{
	Chapter *chapter = [self.chapters objectAtIndex:indexPath.section];
	Lesson *lesson = [chapter.lessons objectAtIndex:indexPath.row];
    
    return lesson;
}

-(Lesson *)exerciseForLesson:(int)lessonNumber
{
	Lesson *exercise = nil;
    
    @autoreleasepool {
        for (Lesson *e in self.exercises) 
        {
            if (e.parentNumber == lessonNumber)
            {
                exercise = e;
                break;
            }
        }
    }
	
	return exercise;
}

-(NSArray *)lessonsWithBookmarks:(BookmarkRepository *)bookmarkRepository
{
    NSArray *bookmarks = bookmarkRepository.bookmarks;
    NSArray *allChapters = self.chapters;
    NSMutableArray *chapters = [NSMutableArray array];
    NSMutableArray *lessons = [NSMutableArray array];
    
    @autoreleasepool {
        for (Chapter *c in allChapters) 
        {
            [lessons removeAllObjects];
            
            for (Lesson *l in c.lessons)
            {
                for (Bookmark *b in bookmarks)
                {
                    if (b.lessonNumber == l.lessonNumber)
                    {
                        [lessons addObject:l];
                        break;
                    }
                }
            }
            
            if ([lessons count] > 0)
            {
                Chapter *chapter = [[Chapter alloc] initWithChapterNumber:c.chapterNumber];
                chapter.lessons = lessons;
                [chapters addObject:chapter];
            }
        }
    }
    
    return chapters;
}

-(NSString *)sectionTitle:(int)lessonNumber
{
    return [[self lessonWithId:lessonNumber] slug];
}

-(Lesson *)nextLesson:(int)currentLessonNumber
{
    Lesson *lesson = [self lessonWithId:currentLessonNumber];
    Lesson *next = nil;
    
    int lIndex = (int)[self.lessons indexOfObject:lesson];
    int nextIndex = lIndex + 1;
    
    // Make sure we don't request an out of bounds object
    if (nextIndex < [self.lessons count])
        next = [self.lessons objectAtIndex:nextIndex];
    
    return next;
}

-(Lesson *)previousLesson:(int)currentLessonNumber
{
    Lesson *lesson = [self lessonWithId:currentLessonNumber];
    Lesson *next = nil;
    
    int lIndex = (int)[self.lessons indexOfObject:lesson];
    
    // Make sure we don't request an out of bounds object
    if (lIndex < 1)
        return nil;
    
    int nextIndex = lIndex - 1;
    
    next = [self.lessons objectAtIndex:nextIndex];
    
    return next;
}

-(BOOL)hasNextLesson:(int)currentLessonNumber
{
    return ([self nextLesson:currentLessonNumber] != nil);
}

-(BOOL)hasPreviousLesson:(int)currentLessonNumber
{
    return ([self previousLesson:currentLessonNumber] != nil);
}

-(NSArray *)queryChapters
{
	NSMutableArray *chapters = [NSMutableArray array];
    NSString *chapterQuery = @"SELECT Id, ParentId, Title, Slug, Content, ContentType, UpdatedDate FROM Content";
    NSString *lessonsQuery = @"SELECT Id, ParentId, Title, Slug, Content, ContentType, UpdatedDate FROM Content Where ParentId == ?";
    
	FMDatabase* db = [FMDatabase databaseWithPath:_dbPath];
	
    if (![db open])
    {
        NSLog(@"Could not open db.");
    }
	else
    {
		FMResultSet *rs = [db executeQuery:chapterQuery];
        NSMutableArray *exercises = [NSMutableArray array];
        
        int i = 0;

        @autoreleasepool {
            while ([rs next])
            {
                int parentId = [rs intForColumn:@"ParentId"];
                int contentType = [rs intForColumn:@"ContentType"];
                
                // If the "lesson" doesn't have a parent ID, we can assume that it's a "chapter"
                if (parentId < 1)
                {    
                    Chapter *chapter = [self chapterFromResultSet:rs];
                    FMResultSet *lrs = [db executeQuery:lessonsQuery, [NSString stringWithFormat:@"%d", chapter.chapterNumber]];
                    NSMutableArray *lessonsTemp = [NSMutableArray array];
                    
                    Lesson *overviewLesson = (Lesson *)[self lessonFromResultSet:rs];
                    overviewLesson.chapterNumber = chapter.chapterNumber;
                    overviewLesson.lessonIndexPath = [NSIndexPath indexPathForRow:0 inSection:i];
                    
                    // Add chapter overview
                    [lessonsTemp addObject:overviewLesson];
                    
                    // Add lessons
                    // Since we've already used 0, let's start at 1
                    int j = 1;
                    while ([lrs next])
                    {
                        Lesson *lesson = (Lesson *)[self lessonFromResultSet:lrs];
                        lesson.chapterNumber = chapter.chapterNumber;
                        lesson.lessonIndexPath = [NSIndexPath indexPathForRow:j inSection:i];
                        
                        [lessonsTemp addObject:lesson];
                        j++;
                    }
                    
                    chapter.lessons = lessonsTemp;
                    
                    [chapters addObject:chapter];
                }
                else if (contentType == kExercise)
                {
                    [exercises addObject:(Lesson *)[self lessonFromResultSet:rs]];
                }
                
                i++;
            }
        }
    
        self.exercises = [exercises copy];
    
        [rs close];
    }


	// One last loop
    @autoreleasepool {
        for (Chapter *c in chapters) 
        {
            for (Lesson *l in c.lessons)
                l.exercise = [self exerciseForLesson:l.lessonNumber];
        }
    }
    
    return chapters;
}

-(Chapter *)chapterFromResultSet:(FMResultSet *)rs
{
    NSString *title = [[NSString alloc] initWithUTF8String:(const char *)[rs UTF8StringForColumnName:@"Title"]];
    
    Chapter *chapter = [[Chapter alloc] initWithChapterNumber:[rs intForColumn:@"Id"]];
    chapter.title = title;
    
    return chapter;
}
                      
-(Lesson *)lessonFromResultSet:(FMResultSet *)rs
{
    NSString *title = [[NSString alloc] initWithUTF8String:(const char *)[rs UTF8StringForColumnName:@"Title"]];
    NSString *slug = [[NSString alloc] initWithUTF8String:(const char *)[rs UTF8StringForColumnName:@"Slug"]];
    NSString *content = [[NSString alloc] initWithUTF8String:(const char *)[rs UTF8StringForColumnName:@"Content"]];
    
    Lesson *lesson = [[Lesson alloc] initWithLessonNumber:[rs intForColumn:@"Id"] parentNumber:[rs intForColumn:@"ParentId"]];
    lesson.title = title;
    lesson.contentType = [rs intForColumn:@"ContentType"];
    lesson.lessonContent = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    lesson.slug = slug;
    lesson.updatedDate = nil;
    
    return lesson;
}

@end
