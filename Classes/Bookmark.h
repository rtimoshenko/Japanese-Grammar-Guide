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
@property (nonatomic) NSInteger bookmarkNumber;
@property (nonatomic) NSInteger lessonNumber;
@property (nonatomic) NSInteger sortOrder;

@end
