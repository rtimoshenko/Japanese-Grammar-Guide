//
//  LessonViewController.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LessonViewController.h"
#import "LessonRepository.h"
#import "BookmarkRepository.h"
#import "Chapter.h"
#import "Lesson.h"
#import "ChapterViewDataProvider.h"

@interface LessonViewController()
@property (nonatomic) BOOL navIsVisible;
@property (nonatomic) BOOL tableIsVisible;
@property (nonatomic) BOOL isReloading;
@property (nonatomic) BOOL isLoadingPrevious;
@property (nonatomic) BOOL shouldIgnoreShowMessage;
@property (nonatomic) BOOL hasLoadedRootWebView;
@property (nonatomic) NSInteger lastContentOffset;
@property (nonatomic, strong) AVAudioPlayer *kanaPlayer;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSURLRequest *storedRequest;
@property (copy, nonatomic) NSString *loadedHtml;

@end

@implementation LessonViewController

#pragma mark - View lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.lesson == nil) {
        [self shouldLoadLesson:nil lesson:[self.dataProvider getLastViewedLesson]];
    }

    if (!self.isExercise) {
        self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        self.navigationItem.leftItemsSupplementBackButton = YES;
    }
    // Custom initialization
    self.optionsView.delegate = self;
    self.readingView.delegate = self;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    
    [self.webView addGestureRecognizer:doubleTap];
    
    for (id subview in self.webView.subviews)
    {
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
        {
            ((UIScrollView *)subview).scrollsToTop = YES;
            ((UIScrollView *)subview).bounces = NO;
            ((UIScrollView *)subview).delegate = self;
        }
    }
    
    [self setupView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Invalidate options timer, otherwise we'll get an exc_bad_access
    // when the view disappears
    [self.optionsView.timer invalidate];
}

- (void)viewDidUnload
{
    self.webView.delegate = nil;
    
    [self setKanaPlayer:nil];
    [self setShowTableButton:nil];
    [self setFilterControl:nil];
    [self setFilterToolbar:nil];
    [self setLoadingView:nil];
    [self setReadingView:nil];
    [self setKanaView:nil];
    [self setMoreOptionsToolbar:nil];
    [self setOptionsToolbar:nil];
    [self setOptionsView:nil];
    [self setWebView:nil];
    
    [super viewDidUnload];
}

// Loads lesson without modifying current view
-(void)loadLesson:(Lesson *)lesson
{   
    self.lesson = lesson;
    self.hasLoadedRootWebView = NO;
    
    [self hideOptionsWithNav:NO];
    [self setupView];
    [self.delegate didChangeToLessonAt:lesson.lessonIndexPath];
    
}

- (void)setupView {
    
    [self.optionsView.brightnessSlider setValue:[[UIScreen mainScreen] brightness]];
        
    // Did we already load the resource?
    if ([self.loadedHtml length] < 1)
    {
        
        // Load the html as a string from the file system
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Web/index" ofType:@"html"];
        NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        
        self.loadedHtml = html;
    }
    
    // Make sure we always show the navigation bar so that users
    // can abort loading at any time
    [self showNav];
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSString *parsedHtml = [[NSString alloc] initWithFormat:self.loadedHtml, self.lesson.slug, self.lesson.lessonContent];
    
    [self.dataProvider saveCurrentLesson:self.lesson];
    
    
    self.title = self.lesson.slug;
    self.exercise = self.lesson.exercise;
    
    
    CATransition *transition = [CATransition animation];
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.duration = 0.25;
    transition.type = kCATransitionFade;
    transition.delegate = self;
    
    if (self.isLoadingPrevious)
        transition.subtype = kCATransitionFromBottom;
    else
        transition.subtype = kCATransitionFromTop;
    
    
    
    [self.webView.layer addAnimation:transition forKey:nil];
    
    self.webView.hidden = YES;
    self.loadingView.hidden = NO;
    
    // Tell the web view to load it
    [self.webView stopLoading];
    [self.webView loadHTMLString:parsedHtml baseURL:baseURL];
    
    
    // If this is an exercise, let's disable various options
    if (self.isExercise)
    {
        [self.optionsView setHasBookmark:YES];
        [self.optionsView setHasNext:NO];
        [self.optionsView setHasPrevious:NO];
    }
    else
    {
        [self.optionsView setHasPrevious:[self.dataProvider hasPreviousLessonForLesson:self.lesson]];
        [self.optionsView setHasNext:[self.dataProvider hasNextLessonForLesson:self.lesson]];
        [self.optionsView setHasBookmark:[self.dataProvider hasBookmarkForLesson:self.lesson]];
    }
}

-(void)loadExercise
{
    // Get associated lesson data
    Lesson *exercise = self.exercise;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LessonViewController *lessonViewController = [storyboard instantiateViewControllerWithIdentifier:@"LessonViewController"];
    
    lessonViewController.lesson = exercise;
    lessonViewController.isExercise = YES;
    lessonViewController.hasLoadedRootWebView = NO;
    
    [self.navigationController showViewController:lessonViewController sender:nil];
}

#pragma mark - Option Menu View Controller Delegate

-(void)shouldUseNightMode:(id)sender useNightMode:(BOOL)nightMode
{
    NSString *nightModeString = @"false";
    
    if (!nightMode)
    {
        for (id subview in self.webView.subviews)
        {
            if ([[subview class] isSubclassOfClass: [UIScrollView class]])
                [((UIScrollView *)subview) setIndicatorStyle:UIScrollViewIndicatorStyleDefault];
        }
        
        self.webView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        nightModeString = @"true";
        
        for (id subview in self.webView.subviews)
        {
            if ([[subview class] isSubclassOfClass: [UIScrollView class]])
                [((UIScrollView *)subview) setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        }
        
        self.webView.backgroundColor = [UIColor blackColor];
    }
    
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setNightMode(%@);", nightModeString]];
    
    [self.delegate didActivateNightMode:nightMode];
}

-(void)doChangeFontSize:(id)sender changeTo:(NSInteger)fontSize;
{
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setFontSize(%ld);", (long)fontSize]];
}

-(void)doSaveBookmark:(id)sender
{
    if (![self.dataProvider hasBookmarkForLesson:self.lesson]) {
        [self.bookmarkRepository saveBookmarkForLesson:self.lesson];
    }
}

-(void)doLoadNext:(id)sender
{
    Lesson *lesson = [self.dataProvider getNextLessonForLesson:self.lesson];
    
    // Just in case we get a nil result, let's make sure we only load valid lessons
    if (lesson)
    {
        self.isLoadingPrevious = NO;
        [self loadLesson:lesson];
        
    }
}

-(void)doLoadPrevious:(id)sender
{
    Lesson *lesson = [self.dataProvider getPreviousLessonForLesson:self.lesson];
    
    // Just in case we get a nil result, let's make sure we only load valid lessons
    if (lesson)
    {
        self.isLoadingPrevious = YES;
        [self loadLesson:lesson];
        [self.delegate didChangeToLessonAt:lesson.lessonIndexPath];
    }
}

-(void)showNav
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)hideNav
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)showOptions
{
    [self.optionsView show];
}

-(void)hideOptionsWithNav
{
    [self hideOptionsWithNav:YES];
}

-(void)hideOptionsWithNav:(BOOL)withNav
{
    [self.optionsView hideWithDelegate:withNav];
}

// Allows UIWebView to enable gesture recognizers
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handleDoubleTap
{
    if (self.hasLoadedRootWebView && !self.navigationController.isNavigationBarHidden) {
        [self hideOptionsWithNav];
    } else {
        [self showOptions];
    }
}

-(void)didShowOptionsView:(id)sender didShow:(BOOL)didShow
{
    if (didShow)
        [self showNav];
}

-(void)didHideOptionsView:(id)sender didHide:(BOOL)didHide
{
    if (didHide)
        [self hideNav];
}

-(void)didHideReadingView:(id)sender didHide:(BOOL)didHide
{
    if (didHide)
        self.shouldIgnoreShowMessage = NO;
}

-(void)configureView:(BOOL)override
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL useNightMode = [defaults boolForKey:NIGHT_MODE_KEY];
    NSInteger fontSize = [defaults integerForKey:FONT_SIZE_KEY];
    NSString *isIpad = @"false";
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        isIpad = @"true";
    
    [self.optionsView shouldUseNightMode:useNightMode];
    [self.optionsView doChangeFontSize:fontSize];
    
    if (self.exercise)
        [self.webView stringByEvaluatingJavaScriptFromString:@"addExerciseMessage();"];
    
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"prepareDocument(%@);", isIpad]];
    
    // Make sure we do all our processing before we show the view, in order to avoid DOM flashes, etc.
    [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(showWebView) userInfo:nil repeats:NO];
}

-(void)showWebView
{
    CATransition *transition = [CATransition animation];
    
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.duration = 0.25;
    transition.type = kCATransitionFade;
    transition.delegate = self;
    
    if (self.isLoadingPrevious) {
        transition.subtype = kCATransitionFromBottom;
    } else {
        transition.subtype = kCATransitionFromTop;
    }
    
    [self.webView.layer addAnimation:transition forKey:nil];
    self.webView.hidden = NO;
    self.loadingView.hidden = YES;
    
    [self showOptions];
}


#pragma mark - Kana View methods

-(void)showKana:(NSString *)kana syllabary:(Syllabary)syllabary
{
    [self.kanaView showKana:kana syllabary:syllabary];
}

-(void)hideKana
{
    [self.kanaView hide];
}


#pragma mark - Chapter View Delegate Methods - iPad only

- (void)shouldLoadLesson:(id)sender lesson:(Lesson *)lesson
{
    // Make sure we don't reload the same lesson
    if (self.lesson == nil || self.lesson.lessonNumber != lesson.lessonNumber) {
        [self loadLesson:lesson];
    }
}

- (void)refreshBookmark {
    
    [self.optionsView setHasBookmark:[self.dataProvider hasBookmarkForLesson:self.lesson]];
}


#pragma mark - Web View Delegate Methods

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    // since this method is triggered any time any object finishes loading,
    // let's make sure we run our set up only once
    if (!self.hasLoadedRootWebView)
    {
        self.hasLoadedRootWebView = YES;
        //[self hideTableView];
        [self configureView:NO];
    }
}

-(BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
navigationType:(UIWebViewNavigationType)navigationType
{
    // Since webview calls are unpredictable, let's try to catch exceptions
    @try
    {
        self.shouldIgnoreShowMessage = YES;
        NSString *urlString = [[request URL] absoluteString];
        
        if(navigationType == UIWebViewNavigationTypeLinkClicked)
        {
            NSRange httpRange = [urlString rangeOfString:@"http"];
            NSRange wwwRange = [urlString rangeOfString:@"www"];
            
            // [urlString hasPrefix:@"somefakeurlscheme://video-ended"]
            if ((wwwRange.length != NSNotFound && wwwRange.length > 0) || (httpRange.length != NSNotFound && httpRange.length > 0))
            {
                // Save request
                self.storedRequest = request;
                
                /* open an alert with OK and Cancel buttons */
                NSString *message = @"This link will take you out of the \"Learning Japanese\" application. Would you like to open this page in Safari?";
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notice"
                                                                               message:message
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                __weak __typeof(&*self)weakSelf = self;
                
                [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                                                        }]];
                
                [alert addAction:[UIAlertAction actionWithTitle:@"Safari"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
                                                            // Proceed to Safari
                                                            [[UIApplication sharedApplication] openURL:weakSelf.storedRequest.URL];
                                                            
                                                            weakSelf.storedRequest = nil;
                                                            weakSelf.shouldIgnoreShowMessage = NO;
                                                            [weakSelf dismissViewControllerAnimated:NO completion:nil];
                                                            
                                                        }]];
                
                [self presentViewController:alert
                                   animated:YES
                                 completion:nil];
                
                return NO;
            }
        }
        else if (navigationType == UIWebViewNavigationTypeOther)
        {
            NSRange stringRange = [urlString rangeOfString:@"ljapp"];
            
            if (stringRange.length != NSNotFound && stringRange.length > 0)
            {
                NSArray *components = [urlString componentsSeparatedByString:@":"];
                
                if ([components count] > 1)
                {
                    NSString *action = (NSString *)[components objectAtIndex:1];
                    if ([action isEqualToString:@"reading"])
                    {
                        NSString *definitionString = [(NSString *)[components objectAtIndex:2] stringByRemovingPercentEncoding];
                        NSString *readingString = [(NSString *)[components objectAtIndex:3] stringByRemovingPercentEncoding];
                        NSString *characterString = [(NSString *)[components objectAtIndex:4] stringByRemovingPercentEncoding];
                        
                        [self.readingView setLabelText:[NSString stringWithFormat:@"%@ \n %@ \n %@", characterString, readingString, definitionString]];
                        [self.readingView show];
                        
                        return NO;
                    }
                    else if ([action isEqualToString:@"playclip"])
                    {
                        [self.readingView setLabelText:@"Playing Audio"];
                        
                        NSString *characterString = [(NSString *)[components objectAtIndex:2] stringByRemovingPercentEncoding];
                        NSString *audioPath = [NSString stringWithFormat:@"%@/Audio/%@.mp3", [[NSBundle mainBundle] resourcePath], characterString];
                        
                        // Set up audio
                        NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
                        NSError *error;
                        
                        self.kanaPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:&error];
                        //self.kanaPlayer.delegate = self;
                        [self.kanaPlayer prepareToPlay];
                        [self.kanaPlayer play];
                        self.kanaPlayer.volume = 1.0;
                        
                        [self.readingView show];
                        
                        return NO;
                    }
                    else if ([action isEqualToString:@"hiragana"])
                    {
                        [self showKana:(NSString *)[components objectAtIndex:2] syllabary:kHiragana];
                        
                        return NO;
                    }
                    else if ([action isEqualToString:@"katakana"])
                    {
                        [self showKana:(NSString *)[components objectAtIndex:2] syllabary:kKatakana];
                        
                        return NO;
                    }
                    else if ([action isEqualToString:@"exercise"])
                    {
                        [self loadExercise];
                        
                        return NO;
                    }
                }
            }
        }
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception - %@",[exception description]);
    }
    
    return YES;
}



#pragma mark UIScrollView Delegate Methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.self.lastContentOffset = scrollView.contentOffset.y;
}

- (void) scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > self.self.lastContentOffset) {
        if (scrollView.contentSize.height - scrollView.contentOffset.y < 800) {
            [self showNav];
            [self showOptions];
        } else {
            [self hideOptionsWithNav];
        }
    } else {
        [self showNav];
        [self showOptions];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    
    if (scrollView.contentOffset.y > self.self.lastContentOffset) {
        if (scrollView.contentSize.height - scrollView.contentOffset.y < 800) {
            [self showNav];
            [self showOptions];
        } else {
            [self hideOptionsWithNav];
        }
    } else {
        [self showNav];
        [self showOptions];
    }
}

@end
