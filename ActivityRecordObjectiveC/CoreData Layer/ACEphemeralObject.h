//
//  ACEphemeralObject.h
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/19/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACEphemeralObject : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary     *jsonDictionary;
@property (nonatomic, strong, readonly) NSManagedObject         *managedObject;


- (instancetype)initWithJsonDictionary:(NSDictionary *)jsonDictionary;
+ (instancetype)create;
- (void)save;
- (void)saveAndWait;
- (void)delete;

+ (NSArray *)findAll;

@end
