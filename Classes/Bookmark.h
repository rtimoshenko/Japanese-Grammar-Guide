//
//  Bookmark.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/18/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bookmark : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) int bookmarkNumber;
@property (nonatomic) int lessonNumber;
@property (nonatomic) int sortOrder;

@end