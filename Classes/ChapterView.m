//
//  ChapterView.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/28/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "ChapterView.h"
#import "LessonRepository.h"
#import "BookmarkRepository.h"
#import "Bookmark.h"
#import "Chapter.h"
#import "Lesson.h"
#import "AboutViewController.h"


@interface ChapterView()
@property (nonatomic) BOOL isSearching;
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
-(void)editWasPressed;
-(void)doneWasPressed;
-(void)settingsWasPressed;
-(void)showToolbar;
-(void)hideToolbar;
-(void)showSearchOverlay;
-(void)hideSearchOverlay;
-(void)showSearchOverlay:(BOOL)show withDuration:(float)duration;
-(void)disableSearchbar;
-(void)enableSearchbar;
@end

@implementation ChapterView

@synthesize delegate = _delegate;
@synthesize parentNavigationItem = _parentNavigationItem;
@synthesize parentNavigationController = _parentNavigationController;
@synthesize searchOverlayView = _searchOverlayView;
@synthesize disableOverlayView = _disableOverlayView;
@synthesize filterToolbar = _toolbar;
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize editButton = _editButton;
@synthesize doneButton = _doneButton;
@synthesize settingsButton = _settingsButton;
@synthesize resultsLabel = _resultsLabel;
@synthesize cameFromIndexPath = _cameFromIndexPath;
@synthesize chapters = _chapters;
@synthesize bookmarkedChapters = _bookmarkedChapters;
@synthesize foundChapters = _foundChapters;
@synthesize displayType = _displayType;
@synthesize isSearching = _isSearching;
@synthesize isNightMode = _isNightMode;


-(void)configureView
{
    SEL editWasPressed = @selector(editWasPressed);
	self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:editWasPressed];
    
    SEL doneWasPressed = @selector(doneWasPressed);
	self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:doneWasPressed];
    
    SEL settingsWasPressed = @selector(settingsWasPressed);
	self.settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"About" style:UIBarButtonItemStylePlain target:self action:settingsWasPressed];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
        [self.parentNavigationItem setLeftBarButtonItem:self.settingsButton animated:YES];
    else
        [self.parentNavigationItem setRightBarButtonItem:self.settingsButton animated:YES];
    
	// Make sure we always show the searchbar
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        [self.tableView setContentOffset:CGPointMake(0,0)];
    
    self.searchBar.placeholder = NSLocalizedString(@"Search All Lessons", @"Search All Lessons");
}

-(void)reloadAsNightTheme:(BOOL)useNightMode
{
    // Makes sure that the correct theme is loaded
    // and that bookmarked chapters are updated
    self.isNightMode = useNightMode;
    [self.tableView reloadData];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && self.displayType == kLessons)
        [self.tableView selectRowAtIndexPath:self.cameFromIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

-(void)didHideChapterView:(BOOL)didHide
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self.parentNavigationItem setRightBarButtonItem:self.settingsButton animated:YES];
        [self.tableView setEditing:NO animated:YES];
        [self enableSearchbar];
        
        if (self.displayType == kLessons)
            [self.tableView selectRowAtIndexPath:self.cameFromIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

-(void)resetSearchField
{
    if (self.displayType == kBookmarks)
	{
        self.searchBar.placeholder = NSLocalizedString(@"Search Bookmarks", @"Search Bookmarks");

		if (self.bookmarkedChapters.count < 1)
        {
			self.resultsLabel.text = NSLocalizedString(@"No Bookmarks", @"No Bookmarks");
        }
        else if([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
        {
            [self.parentNavigationItem setRightBarButtonItem:self.editButton animated:YES];
        }
	}
    else 
	{
        self.searchBar.placeholder = NSLocalizedString(@"Search All Lessons", @"Search All Lessons");
        
        if([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
            [self.parentNavigationItem setRightBarButtonItem:nil animated:YES];
        
		[self.tableView setEditing:NO animated:YES];
	}

	self.searchBar.text = @"";
    self.isSearching = NO;

    
    [self.foundChapters removeAllObjects];
    [self.tableView reloadData];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && self.displayType == kLessons)
        [self.tableView selectRowAtIndexPath:self.cameFromIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}

-(BOOL)hasNextLesson
{
    return ([self loadNextLessonAndSaveIndexPath:NO] != nil);
}

-(BOOL)hasPreviousLesson
{
    return ([self loadPreviousLessonAndSaveIndexPath:NO] != nil);
}

-(Lesson *)loadNextLessonAndSaveIndexPath:(BOOL)shouldSave
{
    Lesson *lesson = nil;
    NSInteger section = self.cameFromIndexPath.section;
    NSInteger row = self.cameFromIndexPath.row;
    NSIndexPath *nextPath = nil;
    
    
    if ([self.tableView numberOfRowsInSection:section] > (row + 1))
    {
        nextPath = [NSIndexPath indexPathForRow:(row + 1) inSection:section];
    }
    else if ([self.tableView numberOfSections] > (section + 1))
    {
        nextPath = [NSIndexPath indexPathForRow:0 inSection:(section + 1)];
    }

    if (nextPath)
    {
        lesson = [self lessonWithIndexPath:nextPath];

        if (shouldSave)
        {
            self.cameFromIndexPath = nextPath;
            [self.tableView selectRowAtIndexPath:nextPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
    
    return lesson;
}

-(Lesson *)loadPreviousLessonAndSaveIndexPath:(BOOL)shouldSave
{
    Lesson *lesson = nil;
    NSInteger section = self.cameFromIndexPath.section;
    NSInteger row = self.cameFromIndexPath.row;
    NSIndexPath *previousPath = nil;
    
    if (section < 1 && row < 1)
        return nil;
 
    if (row > 0)
        previousPath = [NSIndexPath indexPathForRow:(row - 1) inSection:section];
    else
        previousPath = [NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:(section - 1)] - 1) inSection:(section - 1)];
    
    if (previousPath)
	{
        lesson = [self lessonWithIndexPath:previousPath];

		if (shouldSave)
        {
			self.cameFromIndexPath = previousPath;
            [self.tableView selectRowAtIndexPath:previousPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
	}
    
    return lesson;
}

-(Lesson *)lessonWithIndexPath:(NSIndexPath *)indexPath
{
	// Get associated lesson data
    Lesson *lesson = nil;
    
    @try 
    {
        Chapter *chapter = [self.chapters objectAtIndex:indexPath.section];
        
        if (self.isSearching)
            chapter = [self.foundChapters objectAtIndex:indexPath.section];
        else if (self.displayType == kBookmarks)
            chapter = [self.bookmarkedChapters objectAtIndex:indexPath.section];
        
        lesson = [chapter.lessons objectAtIndex:indexPath.row];
    }
    @catch (NSException *exception) {
        NSLog(@"lessonWithIndexPath: invalid index path.");
    }
    
    return lesson;
}


#pragma mark UITableView Delegate Methods

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger chapterCount = self.chapters.count;
    
    if (self.isSearching)
        chapterCount = self.foundChapters.count;
    else if (self.displayType == kBookmarks)
        chapterCount = self.bookmarkedChapters.count;
    
	// un/hide table view and "no results" label, as appropriate
    if (chapterCount < 1)
	{
        //self.tableView.hidden = YES;
		self.resultsLabel.hidden = NO;
	}
    else
	{
        //self.tableView.hidden = NO;
		self.resultsLabel.hidden = YES;
	}
    
    return chapterCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Chapter *chapter = [self.chapters objectAtIndex:section];
    
    if (self.isSearching)
        chapter = [self.foundChapters objectAtIndex:section];
    else if (self.displayType == kBookmarks)
        chapter = [self.bookmarkedChapters objectAtIndex:section];
    
    return chapter.lessons.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Lesson Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    NSString *defaultCellView = @"bg-table-cell.png";
    NSString *selectedCellView = @"bg-table-cell-dark.png";
    
    if (self.isNightMode)
    {
        defaultCellView = @"bg-table-cell-dark.png";
        selectedCellView = @"bg-table-cell-dark-night.png";
    }
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:defaultCellView] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:selectedCellView] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
    
	// Get associated lesson data
    Chapter *chapter = [self.chapters objectAtIndex:indexPath.section];
    
    if (self.isSearching)
        chapter = [self.foundChapters objectAtIndex:indexPath.section];
    else if (self.displayType == kBookmarks)
        chapter = [self.bookmarkedChapters objectAtIndex:indexPath.section];
    
    
	Lesson *lesson = [chapter.lessons objectAtIndex:indexPath.row];
    NSInteger lessonDisplayNumber = lesson.lessonIndexPath.row;
    NSString *cellTitle = @"";
    

	UIImage *icon = [UIImage imageNamed:@"blank.png"];

	// Adjust initial element (if applicable)
	if (lessonDisplayNumber < 1)
	{
		if (![lesson.title isEqualToString:@""])
			cellTitle = NSLocalizedString(@"Overview", @"Overview");

        // Assign icon
		if ([self lessonNumberIsBookmarked:lesson.lessonNumber])
			icon = [UIImage imageNamed:@"icon-bookmark-cell.png"];
	}
	else 
    {
        cellTitle = [[NSString alloc] initWithFormat:@"Lesson %ld", (long)lessonDisplayNumber];

        // Determine the appropriate icon to use
		if ([self lessonNumberIsBookmarked:lesson.lessonNumber])
		{   
			if (lesson.exercise)
				icon = [UIImage imageNamed:@"icon-bookmark-exercise-cell.png"];
			else
				icon = [UIImage imageNamed:@"icon-bookmark-cell.png"];
		}
		else if (lesson.exercise)
		{
			icon = [UIImage imageNamed:@"icon-exercise-cell.png"];
		}
    }

    cell.imageView.image = icon;
    
    // Configure the cell.

    cell.textLabel.text = cellTitle;
    cell.textLabel.backgroundColor = [UIColor clearColor];

    cell.detailTextLabel.text = lesson.slug;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    if (self.isNightMode)
    {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    else
    {
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	// Get associated lesson data
	Chapter *chapter = [self.chapters objectAtIndex:section];
    
    if (self.isSearching)
        chapter = [self.foundChapters objectAtIndex:section];
    else if (self.displayType == kBookmarks)
        chapter = [self.bookmarkedChapters objectAtIndex:section];

    
	Lesson *lesson = [chapter.lessons objectAtIndex:0];
    Chapter *actualChapter = [self.chapters objectAtIndex:lesson.lessonIndexPath.section];
    Lesson *overviewLesson = [actualChapter.lessons objectAtIndex:0];
    
	return overviewLesson.slug;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
    NSInteger width = 480;//self.tableView.frame.size.width;
    NSInteger inset = 28;
    NSInteger height = 22;
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    
    if (sectionTitle == nil)
        return nil;
    
    // Create label with section title
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    
    @autoreleasepool {
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(inset, 0, width - inset, height);
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor blackColor];
        label.shadowOffset = CGSizeMake(0.0, 1.0);
        label.font = [UIFont boldSystemFontOfSize:16];
        label.text = sectionTitle;
        
        // Create header view and add label as a subview
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-section-header.png"]];
        imageView.frame = CGRectMake(0, 0, width, height);
    
        [view addSubview:imageView];
        [view addSubview:label];
    }
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Lesson *lesson = [self lessonWithIndexPath:indexPath];
    self.cameFromIndexPath = indexPath;
    
    [self.delegate shouldLoadLesson:self lesson:lesson]; 
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{    
	if (self.displayType == kBookmarks)
		return YES;

	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if (self.displayType == kBookmarks)
		return YES;

	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];    
	
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
        Chapter *bookmarkedChapter = [self.bookmarkedChapters objectAtIndex:indexPath.section];
        NSMutableArray *bookmarkedLessons = [bookmarkedChapter.lessons mutableCopy];
        Lesson *bookmarkedLesson = [bookmarkedLessons objectAtIndex:indexPath.row];
        Bookmark *bookmark = [appDelegate.bookmarkRepository bookmarkForLessonNumber:bookmarkedLesson.lessonNumber];
        
        
        
        // Delete the row from the data source
		[tableView beginUpdates];
        
		[appDelegate.bookmarkRepository deleteBookmark:bookmark.bookmarkNumber];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [bookmarkedLessons removeObject:bookmarkedLesson];
        bookmarkedChapter.lessons = bookmarkedLessons;
        
        // No sense in keeping the chapter if there aren't any lessons attached
        if (bookmarkedChapter.lessons.count < 1)
        {
            [self.bookmarkedChapters removeObject:bookmarkedChapter];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
        
		[tableView endUpdates];
    }
}

-(void)editWasPressed 
{
	[self.parentNavigationItem setRightBarButtonItem:self.doneButton];
    [self.parentNavigationItem setLeftBarButtonItem:nil animated:YES];

    [self disableSearchbar];
    [self hideToolbar];
    
    self.doneButton.tintColor = [UIColor colorWithRed:51.0/255.0 green:135.0/255.0 blue:228.0/255.0 alpha:1]; 
	[self.tableView setEditing:YES animated:YES];
}

-(void)doneWasPressed
{
	[self.parentNavigationItem setRightBarButtonItem:self.editButton];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
        [self.parentNavigationItem setLeftBarButtonItem:self.settingsButton animated:YES];

	[self enableSearchbar];
    [self showToolbar];
    
    [self.tableView setEditing:NO animated:YES];
    self.doneButton.tintColor = nil;
	
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.bookmarkRepository saveSortOrder];
}

-(void)settingsWasPressed
{
    // Remove prior selection, just in case
    if([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
        self.cameFromIndexPath = nil;
    
    NSString *defaultNib = @"AboutViewController";
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        defaultNib = [defaultNib stringByAppendingString:@"_iPhone"];
    else
        defaultNib = [defaultNib stringByAppendingString:@"_iPad"];
    
    AboutViewController *aboutViewController = [[AboutViewController alloc] initWithNibName:defaultNib bundle:nil];
    
    [self.parentNavigationController pushViewController:aboutViewController animated:YES];   
}

-(void)showToolbar
{
    if (self.filterToolbar && self.filterToolbar.hidden)
    {
        CATransition *transition = [CATransition animation];
        
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.duration = 0.25f;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromTop;
        transition.delegate = self;
        
        [self.filterToolbar.layer addAnimation:transition forKey:nil];
        self.filterToolbar.hidden = NO;
        
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height -= self.filterToolbar.frame.size.height;
        
        self.tableView.frame = newFrame;
    }
}

-(void)hideToolbar
{
    if (self.filterToolbar && !self.filterToolbar.hidden)
    {
        CATransition *transition = [CATransition animation];
        
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.duration = 0.25f;
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromBottom;
        transition.delegate = self;
        
        [self.filterToolbar.layer addAnimation:transition forKey:nil];
        self.filterToolbar.hidden = YES;
        
        CGRect newFrame = self.tableView.frame;
        newFrame.size.height += self.filterToolbar.frame.size.height;
        
        self.tableView.frame = newFrame;
    }
}

-(void)showSearchOverlay
{
    [self showSearchOverlay:YES withDuration:0.25];
}

-(void)hideSearchOverlay
{
    [self showSearchOverlay:NO withDuration:0.25];
}

-(void)showSearchOverlay:(BOOL)show withDuration:(float)duration
{
    if (self.searchOverlayView)
    {
        // Make sure we show if it's hidden, and don't if it isn't
        if (show == self.searchOverlayView.hidden)
        {
            if (duration > 0)
            {
                CATransition *transition = [CATransition animation];
                
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.duration = duration;
                transition.type = kCATransitionFade;
                transition.delegate = self;
                
                [self.searchOverlayView.layer addAnimation:transition forKey:nil];
            }
            
            self.searchOverlayView.hidden = !show;
        }
    }
}


-(void)disableSearchbar
{
    self.disableOverlayView = [[UIView alloc] initWithFrame:self.searchBar.frame];
    self.disableOverlayView.backgroundColor = [UIColor blackColor];
    self.disableOverlayView.alpha = 0;
    
    self.disableOverlayView.alpha = 0;
    [self.searchBar addSubview:self.disableOverlayView];
    
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    self.disableOverlayView.alpha = 0.4;
    [UIView commitAnimations];
}

-(void)enableSearchbar
{
    [self.disableOverlayView removeFromSuperview];
    [self.searchBar resignFirstResponder];
}


#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar 
{
    [searchBar setShowsCancelButton:YES animated:YES];  
    [self showSearchOverlay];
    [self hideToolbar];
    [self.delegate didBeginSearch:self];
    
    return YES;  
}  

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar 
{   
    [searchBar setShowsCancelButton:NO animated:YES];
    
    if (searchBar.text.length < 1)
        [self searchBarCancelButtonClicked:searchBar];
    
    return YES;  
} 


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];   
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if ([searchText length] > 0)
	{
        // No sense if performing a search if we don't have anything to search
        if (self.displayType == kBookmarks && self.bookmarkedChapters.count < 1)
            return;
            
		self.isSearching = YES;
        [self showSearchOverlay:NO withDuration:0];
        
		[self filterContentForSearchText:searchText scope:nil];
	}
    else
    {
        // No search text, let's reset the results to all possible results
        if (self.displayType == kBookmarks)
            self.foundChapters = [self.bookmarkedChapters mutableCopy];
        else
            self.foundChapters = [self.chapters mutableCopy];
        
        [self showSearchOverlay:YES withDuration:0];
    }
    
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.isSearching = NO;
    self.searchBar.text = @"";
    
    [self.searchBar resignFirstResponder];
    [self hideSearchOverlay];
    [self showToolbar];
    [self.tableView reloadData];
    [self.delegate didCancelSearch:self];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	NSArray *targetChapters = nil;
	NSMutableArray *chapterResults = [NSMutableArray array];
	NSMutableArray *lessonResults = nil;
	NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"(lessonContent contains[cd] %@) or (title contains[cd] %@)", searchText, searchText];


    if (self.displayType == kBookmarks)
        targetChapters = [self.bookmarkedChapters copy];
	else
		targetChapters = [self.chapters copy];

    //Update the filtered array based on the search text and scope.
	[self.foundChapters removeAllObjects];

	for (Chapter *chapter in targetChapters)
	{
        // Since we will be modifying the source array using a 
        // predicate, let's make sure to create copies
		lessonResults = [chapter.lessons mutableCopy];
		[lessonResults filterUsingPredicate:searchPredicate];
	
		if ([lessonResults count] > 0)
		{
			Chapter *chapterResult = [[Chapter alloc] initWithChapterNumber:chapter.chapterNumber];
			chapterResult.lessons = lessonResults;

			[chapterResults addObject:chapterResult];
		}
	}
	
    if (chapterResults.count < 1)
		self.resultsLabel.text = NSLocalizedString(@"No Matches Found", @"No Matches Found");
    
    self.foundChapters = chapterResults;
}

-(BOOL)lessonNumberIsBookmarked:(NSInteger)lessonNumber
{
	BOOL hasBookmark = NO;

	for (Chapter *c in self.bookmarkedChapters)
	{
        for (Lesson *l in c.lessons)
        {
            if (l.lessonNumber == lessonNumber)
            {
                hasBookmark = YES;
                break;
            }
        }
	}

	return hasBookmark;
}


#pragma mark UIScrollView Delegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
    CGRect rect = self.searchBar.frame;
    
    // Lock searchbar to top while browsing results
    if (self.isSearching)
        rect.origin.y = 0;
    

    self.searchBar.frame = rect;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{    
    //[self.searchBar resignFirstResponder];
}

-(void)viewDidUnload
{
    [self setDisableOverlayView:nil];
    [self setSearchOverlayView:nil];
	[self setResultsLabel:nil];
	[self setEditButton:nil];
    [self setSearchBar:nil];
	[self setTableView:nil];
    [self setFilterToolbar:nil];
    [self setParentNavigationItem:nil];
}


@end
