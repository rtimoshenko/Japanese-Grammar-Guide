//
//  BookmarkRepository.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "BookmarkRepository.h"
#import "Bookmark.h"
#import "Lesson.h"
#import "FMDatabase.h"

@interface BookmarkRepository (Private)
-(void)reloadBookmarks;
-(NSArray *)queryBookmarks;
-(void)insertBookmark:(Bookmark *)bookmark;
-(void)updateBookmark:(Bookmark *)bookmark;
-(Bookmark *)bookmarkFromResultSet:(FMResultSet *)rs;
@end


@implementation BookmarkRepository

@synthesize dbPath = _dbPath;
@synthesize bookmarks = _bookmarks;


-(id)init 
{
    if (self = [super init])
    {
		// Using separate DB so that we can completely overwrite the other one on updates
		[self checkAndCreateDatabase:@"learning_japanese_bookmarks.sqlite3"];
        [self reloadBookmarks];
    }
	
	return self;
}

-(void)reloadBookmarks
{
	self.bookmarks = [self queryBookmarks];
}

-(NSArray *)queryBookmarks
{
	NSString *query = @"SELECT Title, Subtitle, LessonId, SortOrder, Id FROM Bookmarks ORDER BY SortOrder ASC";
	FMDatabase* db = [FMDatabase databaseWithPath:_dbPath];
	NSMutableArray *bookmarksTemp = [[NSMutableArray alloc] init];
	
    if (![db open]) 
	{
        NSLog(@"Could not open db.");
    }
	else
	{
		FMResultSet *rs = [db executeQuery:query];
		
		while ([rs next])
		{
			Bookmark *bookmark = [self bookmarkFromResultSet:rs];
			[bookmarksTemp addObject:bookmark];
		}

		[rs close];  
	}

	return bookmarksTemp;
}
                      
-(Bookmark *)bookmarkFromResultSet:(FMResultSet *)rs
{
	NSString *title = [[NSString alloc] initWithUTF8String:(const char *)[rs UTF8StringForColumnName:@"Title"]];
	NSString *subtitle = [[NSString alloc] initWithUTF8String:(const char *)[rs UTF8StringForColumnName:@"Subtitle"]];
	
	Bookmark *bookmark = [[Bookmark alloc] init];
	bookmark.title = title;
	bookmark.subtitle = subtitle;
	bookmark.bookmarkNumber = [rs intForColumn:@"Id"];
	bookmark.lessonNumber = [rs intForColumn:@"LessonId"];
	bookmark.sortOrder = [rs intForColumn:@"SortOrder"];
	
	return bookmark;
}

-(void)saveBookmark:(Bookmark *)bookmark
{
	if (bookmark.bookmarkNumber > 0)
		[self updateBookmark:bookmark];
	else
		[self insertBookmark:bookmark];
    
    [self reloadBookmarks];
}

-(void)saveBookmarkForLesson:(Lesson *)lesson
{
	Bookmark *bookmark = [[Bookmark alloc] init];
	bookmark.title = lesson.slug;
	bookmark.subtitle = lesson.title;
	bookmark.lessonNumber = lesson.lessonNumber;
	bookmark.sortOrder = [self.bookmarks count];

	[self saveBookmark:bookmark];
}

-(Bookmark *)bookmarkForLessonNumber:(NSInteger)lessonNumber
{
	Bookmark *bookmarkResult = nil;

    @autoreleasepool {
        for (Bookmark *bookmark in self.bookmarks)
        {
            if (bookmark.lessonNumber == lessonNumber)
            {
                bookmarkResult = bookmark;
                break;
            }
        }
    }

	return bookmarkResult;
}

-(void)insertBookmark:(Bookmark *)bookmark
{
	FMDatabase* db = [FMDatabase databaseWithPath:self.dbPath];
	[db open];
	
	[db beginTransaction];
	[db executeUpdate:@"INSERT INTO Bookmarks (Title, Subtitle, LessonId, SortOrder) VALUES (?, ?, ?, ?)",
	 [NSString stringWithFormat:@"%@", bookmark.title],
	 [NSString stringWithFormat:@"%@", bookmark.subtitle],
	 [NSNumber numberWithInteger:bookmark.lessonNumber],
	 [NSNumber numberWithInteger:[self.bookmarks count]]];
	[db commit];
	
	[db close];
}

-(void)updateBookmark:(Bookmark *)bookmark
{
	FMDatabase* db = [FMDatabase databaseWithPath:self.dbPath];
	[db open];
	
	[db beginTransaction];
	[db executeUpdate:@"UPDATE Bookmarks SET Title=?, Subtitle=?, SortOrder=? WHERE Id = ?",
		  [NSString stringWithFormat:@"%@", bookmark.title],
		  [NSString stringWithFormat:@"%@", bookmark.subtitle],
		  [NSNumber numberWithInteger:bookmark.sortOrder],
		  [NSNumber numberWithInteger:bookmark.bookmarkNumber]];
	[db commit];
	
	[db close];
}

-(void)deleteBookmark:(NSInteger)bookmarkNumber
{
	FMDatabase* db = [FMDatabase databaseWithPath:self.dbPath];
	[db open];
	
	[db beginTransaction];
	[db executeUpdate:@"DELETE FROM Bookmarks WHERE Id = ?",
			 [NSNumber numberWithInteger:bookmarkNumber]];
	[db commit];
	
	[db close];
    
    [self reloadBookmarks];
}

-(void)saveSortOrder
{
    if (self.bookmarks.count > 0)
    {
        NSInteger sortOrder = 0;
        
        @autoreleasepool {
            for (Bookmark *bookmark in self.bookmarks)
            {
                bookmark.sortOrder = sortOrder++;
                [self updateBookmark:bookmark];
            }
        }
        
        [self reloadBookmarks];
    }
}

@end
