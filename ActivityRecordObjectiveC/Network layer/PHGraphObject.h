//
//  PHGraphObject.h
//  Phoenix
//
//  Created by Boroday on 30.09.13.
//  Copyright (c) 2013 massinteractiveserviceslimited. All rights reserved.
//

@import Foundation;

@protocol PHGraphObject<NSObject>

- (NSUInteger)count;
- (id)objectForKey:(id)aKey;
- (NSEnumerator *)keyEnumerator;
- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id)aKey;

@end

@interface PHGraphObject : NSMutableDictionary<PHGraphObject>

+ (NSMutableDictionary<PHGraphObject>*)graphObject;
+ (NSMutableDictionary<PHGraphObject>*)graphObjectWrappingDictionary:(NSDictionary*)jsonDictionary;
+ (NSArray<PHGraphObject>*)graphObjectWrappingArray:(NSArray*)jsonArray;

+ (NSMutableDictionary<PHGraphObject>*)graphObjectWrappingDictionary:(NSDictionary*)jsonDictionary withProtocolConversion:(Protocol*)protocol subProtocols:(NSArray*)subProtocols error:(NSError *__autoreleasing *)error;
+ (NSArray<PHGraphObject>*)graphObjectWrappingArray:(NSArray*)jsonArray withProtocolConversion:(Protocol*)protocol subProtocols:(NSArray*)subProtocols error:(NSError *__autoreleasing *)error;

@end
