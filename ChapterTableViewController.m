//
//  ChapterTableViewController.m
//  LearningJapanese
//
//  Created by Sam Clewlow on 12/08/2017.
//  Copyright © 2017 Ronald Timoshenko. All rights reserved.
//

#import "ChapterTableViewController.h"
#import "AppDelegate.h"
#import "Chapter.h"
#import "Lesson.h"
#import "ChapterViewDataProvider.h"
#import "LessonViewController.h"


typedef NS_ENUM(NSUInteger, TableviewViewMode) {
    TableviewViewModeLessons,
    TableviewViewModeBookmarks,
    TableviewViewModeEditingBookmarks
};

@interface ChapterTableViewController () <LessonViewControllerDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray<Chapter *>* chapters;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chapterTypeSegmentedControl;
@property (strong, nonatomic) UIBarButtonItem *doneBarButton;
@property (strong, nonatomic) UIBarButtonItem *editBarButton;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL collapseDetailViewController;

@end


@implementation ChapterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.splitViewController.delegate = self;
    self.splitViewController.presentsWithGesture = YES;
    self.collapseDetailViewController = YES;
    
    // Set a defualt selected index path
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0
                                                inSection:0];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController: nil];
    
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    if (@available(iOS 11, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
        self.navigationItem.searchController = self.searchController;
    } else {
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    self.definesPresentationContext = YES;
    self.title = NSLocalizedString(@"文法ガイド", @"文法ガイド");
    
    [self updateCopyForContext:[self getSelectedDisplayType]];
    self.chapters = [self.dataProvider chaptersForSearchTerm:self.searchController.searchBar.text
                                                 displayType:[self getSelectedDisplayType]];
    
    [self createBarButtons];
    
    [self getLessonViewControllerIfExists];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupRightNavButtonForState:[self getSelectedViewMode]];
}

- (void)createBarButtons {
    self.editBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(editBarButtonTapped:)];
    
    self.doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(doneBarButtonTapped:)];
}

#pragma mark - Search Delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    self.chapters = [self.dataProvider chaptersForSearchTerm:searchController.searchBar.text
                                                 displayType:[self getSelectedDisplayType]];
    
    [self showEmptyState:(self.chapters.count < 1)];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.chapters.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    Chapter *chapter = self.chapters[section];
    return chapter.lessons.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Lesson Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    //Get associated lesson data
    Chapter *chapter = [self.chapters objectAtIndex:indexPath.section];
    Lesson *lesson = [chapter.lessons objectAtIndex:indexPath.row];
    NSInteger lessonDisplayNumber = lesson.lessonIndexPath.row;
    NSString *cellTitle = @"";
    
    // Adjust initial element (if applicable)
    if (lessonDisplayNumber < 1 && ![lesson.title isEqualToString:@""])
    {
        cellTitle = NSLocalizedString(@"Overview", @"Overview");
    }
    else
    {
        cellTitle = [[NSString alloc] initWithFormat:@"Lesson %ld", (long)lessonDisplayNumber];
    }
    
    cell.imageView.image = [self getCellIconForLesson:lesson];
    cell.textLabel.text = cellTitle;
    cell.detailTextLabel.text = lesson.slug;
    return cell;
}

- (UIImage *)getCellIconForLesson:(Lesson *)lesson {
    
    BOOL bookmarked = [self.dataProvider isLessonBookmarked:lesson];
    BOOL containsExercise = (lesson.exercise != nil);
    
    if (!bookmarked && !containsExercise) {
        return [UIImage imageNamed:@"blank.png"];;
    
    } else if (!bookmarked && containsExercise) {
        return [UIImage imageNamed:@"icon-exercise-cell.png"];
    
    } else if (bookmarked && !containsExercise) {
        return [UIImage imageNamed:@"icon-bookmark-cell.png"];
        
    } else {
        return [UIImage imageNamed:@"icon-bookmark-exercise-cell.png"];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    Chapter *chapter = self.chapters[section];
    return chapter.title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    self.collapseDetailViewController = NO;
    Lesson *lesson = self.chapters[indexPath.section].lessons[indexPath.row];
    
    [self loadLesson:lesson];
    
    if (self.splitViewController.isCollapsed) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryHidden;
    }];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return ([self getSelectedDisplayType] == ChapterViewDisplayTypeBookmarks);
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        // Get the deleted lesson
        Chapter *bookmarkedChapter = [self.chapters objectAtIndex:indexPath.section];
        NSMutableArray *bookmarkedLessons = [bookmarkedChapter.lessons mutableCopy];
        Lesson *bookmarkedLesson = [bookmarkedLessons objectAtIndex:indexPath.row];
        
        // Keep a flag to see if we need to remove the section as well
        BOOL deleteSection = (bookmarkedChapter.lessons.count == 1);
        
        // Ask the data provider to delete the bookmark and refresh the Chapter models
        self.chapters = [self.dataProvider chaptersAfterDeletingBookmarkedLesson:bookmarkedLesson
                                                                    searchString:self.searchController.searchBar.text];
        
        // Update the table view accordingly
        [tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationRight];
        
        // No sense in keeping the chapter if there aren't any lessons attached
        if (deleteSection) {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                          withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [tableView endUpdates];
    }
    
    [self showEmptyState:(self.chapters.count < 1)];
    [self setupRightNavButtonForState:[self getSelectedViewMode]];
    
    LessonViewController *lessonViewController = [self getLessonViewControllerIfExists];
    [lessonViewController refreshBookmark];
}

#pragma mark - Actions

- (IBAction)segementedControlWasChanged:(UISegmentedControl *)sender {
    
    // Cancel ongoing search action
    self.searchController.active = NO;
    self.selectedIndexPath = nil;
    
    // Fetch the appropriate chapters to display
    self.chapters = [self.dataProvider chaptersForSearchTerm:nil
                                                 displayType:[self getSelectedDisplayType]];
    
    ChapterViewDisplayType tableViewMode = [self getSelectedDisplayType];
    
    [self updateCopyForContext:tableViewMode];
    [self showEmptyState:(self.chapters.count < 1)];
    [self.tableView reloadData];
    
    [self setupRightNavButtonForState:[self getSelectedViewMode]];
}

- (void)doneBarButtonTapped:(id)sender {
    [self setupRightNavButtonForState:TableviewViewModeBookmarks];
    [self.tableView setEditing:NO animated:YES];
    [self hideToolBar:NO];
}

- (void)editBarButtonTapped:(id)sender {
    [self setupRightNavButtonForState:TableviewViewModeEditingBookmarks];
    [self.tableView setEditing:YES animated:YES];
    [self hideToolBar:YES];
}


#pragma mark - View Manipulation

- (void)hideToolBar:(BOOL)hide {
    
    [self.navigationController setToolbarHidden:hide animated:YES];
}

- (void)setupRightNavButtonForState:(TableviewViewMode)state {
    
    switch (state) {
        case TableviewViewModeLessons:
            [self.navigationItem setRightBarButtonItem:nil animated:YES];
            break;
        case TableviewViewModeBookmarks:
            if (self.chapters.count > 0) {
                [self.navigationItem setRightBarButtonItem:self.editBarButton animated:YES];
            } else {
                [self.navigationItem setRightBarButtonItem:nil animated:YES];
            }
            break;
        case TableviewViewModeEditingBookmarks:
            if (self.chapters.count > 0) {
                [self.navigationItem setRightBarButtonItem:self.doneBarButton animated:YES];
            } else {
                
                [self.navigationItem setRightBarButtonItem:nil animated:YES];
            }
            break;
    }
}

- (ChapterViewDisplayType)getSelectedDisplayType {
    if (self.chapterTypeSegmentedControl.selectedSegmentIndex == 0) {
        return ChapterViewDisplayTypeChapters;
    } else {
        return ChapterViewDisplayTypeBookmarks;
    }
}

- (TableviewViewMode)getSelectedViewMode {
    
    ChapterViewDisplayType displayType = [self getSelectedDisplayType];
    if (displayType == ChapterViewDisplayTypeChapters) {
        return TableviewViewModeLessons;
    } else if (self.tableView.isEditing) {
        return TableviewViewModeEditingBookmarks;
    } else {
        return TableviewViewModeBookmarks;
    }
}

- (void)updateCopyForContext:(ChapterViewDisplayType)displayType {
    
    switch (displayType) {
        case ChapterViewDisplayTypeChapters:
            self.noResultsLabel.text = NSLocalizedString(@"No Matches Found", @"No Matches Found");
            self.searchController.searchBar.placeholder = NSLocalizedString(@"Search All Lessons", @"Search All Lessons");
            break;
        case ChapterViewDisplayTypeBookmarks:
            self.noResultsLabel.text = NSLocalizedString(@"No Bookmarks", @"No Bookmarks");
            self.searchController.searchBar.placeholder = NSLocalizedString(@"Search Bookmarks", @"Search Bookmarks");
            break;
    }
}

- (void)showEmptyState:(BOOL)isEmpty {
    if (isEmpty) {
        self.tableView.hidden = YES;
        self.noResultsLabel.hidden = NO;
        [self hideToolBar:NO];
    } else {
        self.tableView.hidden = NO;
        self.noResultsLabel.hidden = YES;
    }
}

#pragma mark - UISplitViewControllerDelegate

- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)svc {
    return UISplitViewControllerDisplayModeAutomatic;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController {
    return self.collapseDetailViewController;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    
    self.chapterTypeSegmentedControl.frame = CGRectMake(0,
                                                        0,
                                                        CGRectGetWidth(self.navigationController.toolbar.frame) - 32,
                                                        CGRectGetHeight(self.navigationController.toolbar.frame) - 16);

    self.chapterTypeSegmentedControl.center = self.navigationController.toolbar.center;
    
    // Get the screen
    UIScreen *screen = [UIScreen mainScreen];
    
    if (screen.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact
        && screen.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
        // Do notihing as compact x compact never shows in split mode
        return;
    }
    
    // We are showing in regular, highlight the correct tableview cell
    if (screen.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        [self.tableView selectRowAtIndexPath:self.selectedIndexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
        
        return;
    }
    
    if (screen.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        [self.tableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
        return;
    }
}

#pragma mark - LessonViewControllerDelegate

- (void)didChangeToLessonAt:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    
    UIScreen *screen = [UIScreen mainScreen];
    
    if (screen.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular) {
        [self.tableView selectRowAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)didBookmarkLesson:(Lesson *)lesson {
    [self.tableView reloadRowsAtIndexPaths:@[lesson.lessonIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void) didActivateNightMode:(BOOL)active {
    // TODO:
}

#pragma mark - Navigation

- (void)loadLesson:(Lesson *)lesson {
    LessonViewController *lessonViewController = [self getLessonViewControllerIfExists];
    
    if (lessonViewController != nil) {
        [lessonViewController shouldLoadLesson:nil lesson:lesson];
    } else {
        [self performSegueWithIdentifier:@"show_lesson" sender:lesson];
    }
}

- (LessonViewController *)getLessonViewControllerIfExists {
    if (self.splitViewController.viewControllers.count > 1) {
        UINavigationController *nav = self.splitViewController.viewControllers[1];
        LessonViewController *lessonViewController = (LessonViewController *)nav.topViewController;
        lessonViewController.delegate = self;
        return lessonViewController;
    } else {
        return nil;
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {

    if ([segue.identifier isEqualToString:@"show_lesson"]) {

        UINavigationController *nav = segue.destinationViewController;
        LessonViewController *lessonViewController = (LessonViewController *)nav.topViewController;
        lessonViewController.delegate = self;
        [lessonViewController shouldLoadLesson:nil lesson:(Lesson *)sender];
    } else if ([segue.identifier isEqualToString:@"show_about"]) {
        // Show the about view controller, story board takes care of this
    }
}

@end
