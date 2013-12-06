//
//  AbstractRepository.h
//  LearningJapanese
//
//  Created by Ronald Timoshenko on 1/23/12.
//  Copyright (c) 2012 Ronald Timoshenko. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMResultSet;

@interface AbstractRepository : NSObject

@property (nonatomic, copy) NSString *dbPath;

-(void)checkAndCreateDatabase:(NSString *)dbName;

@end
