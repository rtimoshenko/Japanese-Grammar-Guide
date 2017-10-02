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
#import "ChapterViewDataProvider.h"

@implementation AbstractViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(LessonRepository *)lessonRepository
{
    return [self.appDelegate lessonRepository];
}

-(BookmarkRepository *)bookmarkRepository
{
    return [self.appDelegate bookmarkRepository];
}

- (ChapterViewDataProvider *)dataProvider
{
    return [self.appDelegate dataProvider];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    
	return YES;
}

@end
