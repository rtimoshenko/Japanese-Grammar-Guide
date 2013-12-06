//
//  BaseViewController.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/22/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LessonRepository.h"

@interface BaseViewController : UIViewController

@property (nonatomic, strong) LessonRepository *lessonRepository;
@property (nonatomic, strong) NSArray *lessons;
@property (nonatomic, strong) id appDelegate;

@end
