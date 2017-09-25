//
//  KanaView.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/28/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AbstractViewController.h"

@interface KanaView : UIView <UIWebViewDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *characterView;
@property (weak, nonatomic) IBOutlet UIButton *audioButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

-(IBAction)selectedAudioButton:(id)sender;
-(IBAction)selectedCloseButton:(id)sender;

-(void)showKana:(NSString *)kana syllabary:(Syllabary)syllabary;
-(void)hide;

@end
