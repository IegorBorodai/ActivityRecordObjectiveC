//
//  PHClassTypeConvertor.h
//  Phoenix
//
//  Created by Iegor Borodai on 1/10/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

@import Foundation;

@interface PHClassTypeConvertor : NSObject

- (NSMutableDictionary*)convertDictionary:(NSDictionary*)initialDict forProtocol:(Protocol*)protocol error:(NSError *__autoreleasing *)error;

- (NSMutableArray*)convertArray:(NSArray*)initialArray forProtocol:(Protocol*)protocol error:(NSError *__autoreleasing *)error;

- (id)convertValue:(id)value toClass:(id)class;

@end
