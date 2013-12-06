//
//  Chapter.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chapter : NSObject

@property (nonatomic) int chapterNumber;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray *lessons;

-(id)initWithChapterNumber:(int)chapterNumber;

@end