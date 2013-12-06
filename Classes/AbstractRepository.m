//
//  AbstractRepository.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/23/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "AbstractRepository.h"
#import "FMDatabase.h"

@implementation AbstractRepository

@synthesize dbPath = _dbPath;

-(void)checkAndCreateDatabase:(NSString *)dbName
{
	// Get the path to the documents directory and append the databaseName
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [documentPaths objectAtIndex:0];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	self.dbPath = [documentsDir stringByAppendingPathComponent:dbName];
	
	// If the database already exists then return without doing anything
	if([fileManager fileExistsAtPath:self.dbPath]) 
		return;
	
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
	
	// Copy the database from the package to the users filesystem
	[fileManager copyItemAtPath:databasePathFromApp toPath:self.dbPath error:nil];
}

@end
