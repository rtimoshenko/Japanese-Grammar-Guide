//
//  ReadingViewController.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/28/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReadingViewDelegate
@optional
-(void)didHideReadingView:(id)sender didHide:(BOOL)didHide;
@end

@interface ReadingView : UIView

@property (weak, nonatomic) id <ReadingViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

-(void)show;
-(void)hide;
-(void)setLabelText:(NSString *)text;

@end
