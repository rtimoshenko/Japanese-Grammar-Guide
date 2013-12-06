//
//  BaseViewController.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/22/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "AbstractViewController.h"
#import "AppDelegate.h"
#import "LessonRepository.h"
#import "BookmarkRepository.h"
#import "Lesson.h"

@class UIViewController;


@implementation AbstractViewController

@synthesize appDelegate = _appDelegate;

-(LessonRepository *)lessonRepository
{
    return [self.appDelegate lessonRepository];
}

-(BookmarkRepository *)bookmarkRepository
{
    return [self.appDelegate bookmarkRepository];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) 
    {
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}

-(NSString *)deviceNibWithName:(NSString *)nibName
{   
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        nibName = [nibName stringByAppendingString:@"_iPhone"];
    else
        nibName = [nibName stringByAppendingString:@"_iPad"];
    
    return nibName;
}

/*-(LessonRepository *)lessonRepository
{
	if (!_lessonRepository)
		_lessonRepository = [[LessonRepository alloc] init];
    
	return _lessonRepository;
}

-(BookmarkRepository *)bookmarkRepository
{
	if (!_bookmarkRepository)
		_bookmarkRepository = [[BookmarkRepository alloc] init];
    
	return _bookmarkRepository;
}*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    
	return YES;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
