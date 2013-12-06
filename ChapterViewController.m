//
//  ChapterViewController.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "ChapterViewController.h"
#import "LessonViewController.h"
#import "LessonRepository.h"
#import "Chapter.h"
#import "Lesson.h"


@implementation ChapterViewController

@synthesize chapterView = _chapterView;
@synthesize filterToolbar = _filterToolbar;
@synthesize filterControl = _filterControl;


-(IBAction)didSelectFilter:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    self.chapterView.displayType = segmentedControl.selectedSegmentIndex;
    
    [self.chapterView resetSearchField];
    
    // Make sure we're always using the latest set of bookmarks
    if (segmentedControl.selectedSegmentIndex == kBookmarks)
        self.chapterView.bookmarkedChapters = (NSMutableArray *)[self.lessonRepository lessonsWithBookmarks:self.bookmarkRepository];
    
    // Make sure we show the navigation bar, since we could have come 
    // back from a search results view
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - ChapterView Delegate methods

-(void)didBeginSearch:(id)sender
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)didCancelSearch:(id)sender
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)shouldLoadLesson:(id)sender lesson:(Lesson *)lesson
{
    NSString *defaultNib = [self deviceNibWithName:@"LessonViewController"];
    
    LessonViewController *lessonViewController = [[LessonViewController alloc] initWithNibName:defaultNib bundle:nil];
    lessonViewController.chapterView = self.chapterView;
    lessonViewController.lesson = lesson;
    
    [self.navigationController pushViewController:lessonViewController animated:YES];
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    // If we're showing search results, make sure the navigation bar doesn't reappear
    if (self.chapterView.searchBar.text.length > 0)
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
    self.title = NSLocalizedString(@"文法ガイド", @"文法ガイド");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL useNightMode = [defaults boolForKey:NIGHT_MODE_KEY];
    
    [self.chapterView reloadAsNightTheme:useNightMode];
    [self.chapterView.tableView selectRowAtIndexPath:self.chapterView.cameFromIndexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.chapterView.tableView deselectRowAtIndexPath:self.chapterView.cameFromIndexPath animated:YES];

	// Since we came back to the chapter view, let's remove the saved lesson
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setInteger:0 forKey:SAVED_CHAPTER_KEY];
	[defaults setInteger:0 forKey:SAVED_LESSON_KEY];
	[defaults synchronize];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    self.chapterView.delegate = self;
    self.chapterView.chapters = self.lessonRepository.chapters;
    self.chapterView.bookmarkedChapters = (NSMutableArray *)[self.lessonRepository lessonsWithBookmarks:self.bookmarkRepository];
    self.chapterView.parentNavigationItem = self.navigationItem;
    self.chapterView.parentNavigationController = self.navigationController;
    [self.chapterView configureView];
    
    UIImage *toolBarImage = [UIImage imageNamed:@"bg-toolbar.png"];
    
    if ([self.filterToolbar respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)])
    {
        //iOS 5
        [self.filterToolbar setBackgroundImage:toolBarImage forToolbarPosition:0 barMetrics:0];
    }
    else
    {
        //iOS 4
        [self.filterToolbar insertSubview:[[UIImageView alloc] initWithImage:toolBarImage] atIndex:0];
    }
}

- (void)viewDidUnload
{
    [self setFilterControl:nil];
    [self setFilterToolbar:nil];
    [self setChapterView:nil];
    
    [super viewDidUnload];
}

@end