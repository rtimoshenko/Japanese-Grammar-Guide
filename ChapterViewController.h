//
//  ChapterViewController.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractViewController.h"
#import "ChapterView.h"

@interface ChapterViewController : AbstractViewController <ChapterViewDelegate>

@property (strong, nonatomic) IBOutlet ChapterView *chapterView;
@property (unsafe_unretained, nonatomic) IBOutlet UIToolbar *filterToolbar;
@property (unsafe_unretained, nonatomic) IBOutlet UISegmentedControl *filterControl;

-(IBAction)didSelectFilter:(id)sender;

@end