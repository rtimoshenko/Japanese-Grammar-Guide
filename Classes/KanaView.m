//
//  KanaView.m
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/28/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import "KanaView.h"

@interface KanaView()
@property (nonatomic, strong) AVAudioPlayer *kanaPlayer;
@property (nonatomic, copy) NSString *audioPath;
@property (nonatomic, copy) NSString *syllabaryPath;
@property (nonatomic, copy) NSString *character;
@property (nonatomic, copy) NSString *loadedHtml;
@property (nonatomic) BOOL hasLoadedWebView;
-(void)setKana:(NSString *)kana syllabary:(Syllabary)syllabary;
-(void)configureView;
@end

@implementation KanaView

@synthesize characterView = _characterView;
@synthesize audioButton = _audioButton;
@synthesize audioPath = _audioPath;
@synthesize syllabaryPath = _syllabaryPath;
@synthesize character = _character;
@synthesize loadedHtml = _loadedHtml;
@synthesize closeButton = _closeButton;
@synthesize kanaPlayer = _kanaPlayer;
@synthesize hasLoadedWebView = _hasLoadedWebView;

-(void)showKana:(NSString *)kana syllabary:(Syllabary)syllabary
{
    [self setKana:kana syllabary:syllabary];
    [self configureView];
    
	// Make sure we don't animate needlessly
	if (self.alpha < 1.0f)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.25f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self cache:YES];
			
		self.alpha = 1.0f;
        self.hidden = NO;
		[UIView commitAnimations];
	}
}

-(void)setKana:(NSString *)kana syllabary:(Syllabary)syllabary
{
    NSString *syllabaryString = @"Hiragana";
    
    if (syllabary == kKatakana)
        syllabaryString = @"Katakana";
    
    self.syllabaryPath = syllabaryString;
    self.character = kana;
    self.audioPath = [NSString stringWithFormat:@"%@/Audio/%@.mp3", [[NSBundle mainBundle] resourcePath], kana];
}

-(void)configureView
{
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
	// Configure the web view
	// Did we already load the resource?
	if ([self.loadedHtml length] < 1)
	{
		// Load the html as a string from the file system
		NSString *path = [[NSBundle mainBundle] pathForResource:@"Web/kana" ofType:@"html"];
		NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

		self.loadedHtml = html;
	}

    NSString *parsedHtml = [[NSString alloc] initWithFormat:self.loadedHtml, self.syllabaryPath, self.character];
    
    // Tell the web view to load it
	self.characterView.hidden = NO;
    [self.characterView loadHTMLString:parsedHtml baseURL:baseURL];

    
    // Set up audio
    NSURL *audioUrl = [NSURL fileURLWithPath:self.audioPath];
    NSError *error;
    
    self.kanaPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:&error];
    self.kanaPlayer.delegate = self;
	[self.kanaPlayer prepareToPlay];
    
    self.audioButton.enabled = YES;

	[self.audioButton setTitle:@"Playing" forState:UIControlStateSelected];
	[self.audioButton setTitle:@"Playing" forState:UIControlStateDisabled];
}

-(IBAction)selectedAudioButton:(id)sender
{
    [self.kanaPlayer play];
           
    self.audioButton.enabled = NO;
    self.kanaPlayer.volume = 1.0;
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	self.audioButton.enabled = YES;
}

-(IBAction)selectedCloseButton:(id)sender
{
    [self hide];
}

-(void)hide
{
	self.kanaPlayer.delegate = nil;
	[self.kanaPlayer stop];
	[self setKanaPlayer:nil];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self cache:YES];
    
    self.alpha = 0.0f;
    self.hidden = YES;
	self.characterView.hidden = YES;
    [UIView commitAnimations];

	// Clear out the webview
	[self.characterView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

-(void)viewDidUnload
{
	[self setCloseButton:nil];
    [self setCharacterView:nil];
	[self setAudioButton:nil];
	[self setKanaPlayer:nil];
}

@end
