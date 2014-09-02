//
//  ACEphemeralObject.h
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/19/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

@import Foundation;

@interface ACEphemeralObject : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary     *jsonDictionary;
@property (nonatomic, strong, readonly) NSManagedObject         *managedObject;

+ (instancetype)ephemeralObjectWrappingObject:(id)originalObject;

- (void)convertToManagedObject;

- (void)saveWithCompletionBlock:(void (^)(BOOL success, NSError *error))completion;
- (void)saveAndWait;

- (void)delete;

- (void)mergeWithCoreDataByPredicate:(NSPredicate *)predicate;
- (void)mergeWithOtherEphemeralObject:(ACEphemeralObject *)ephemObj;

+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate;
+ (NSArray *)findAllWithSortDescriptors:(NSArray *)sortDescriptors;
+ (NSArray *)findAll;
+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;

@end
