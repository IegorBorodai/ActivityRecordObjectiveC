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

+ (instancetype)createInMemoryFromJsonDictionary:(NSDictionary *)jsonDictionary;
+ (instancetype)create;

+ (NSManagedObject*)convertInMemoryObjectToManaged:(ACEphemeralObject*)ephemObj class:(Class)class;

- (instancetype)initWithJsonDictionary:(NSDictionary *)jsonDictionary;
- (void)saveWithCompletionBlock:(void (^)(BOOL success, NSError *error))completion;
- (void)saveAndWait;
- (void)delete;
- (void)convertToManagedObject;

+ (NSArray *)findAll;

@end
