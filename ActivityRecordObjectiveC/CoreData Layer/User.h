//
//  User.h
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/19/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "ACEphemeralObject.h"
#import "Geo.h"
#import "Messages.h"

@interface User : ACEphemeralObject

@property (nonatomic, retain) NSDecimalNumber * age;
@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * chat_up_line;
@property (nonatomic, retain) NSDecimalNumber * children;
@property (nonatomic, retain) Geo *geo;
@property (nonatomic, retain) NSOrderedSet *messages;

@end


@interface User (CoreDataGeneratedAccessors)

- (void)insertObject:(Messages *)value inMessagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMessagesAtIndex:(NSUInteger)idx;
- (void)insertMessages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMessagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMessagesAtIndex:(NSUInteger)idx withObject:(Messages *)value;
- (void)replaceMessagesAtIndexes:(NSIndexSet *)indexes withMessages:(NSArray *)values;
- (void)addMessagesObject:(Messages *)value;
- (void)removeMessagesObject:(Messages *)value;
- (void)addMessages:(NSOrderedSet *)values;
- (void)removeMessages:(NSOrderedSet *)values;

@end