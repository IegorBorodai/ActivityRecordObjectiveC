//
//  PHClassTypeConvertor.m
//  Phoenix
//
//  Created by Iegor Borodai on 1/10/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "PHClassTypeConvertor.h"
@import ObjectiveC.runtime;

@interface PHClassTypeConvertor ()

@property (nonatomic, strong) NSNumberFormatter* formatter;

@end

@implementation PHClassTypeConvertor

- (id)init
{
    if (((self = [super init])))
    {
        _formatter = [[NSNumberFormatter alloc] init];
    }
    return self;
}

#pragma mark - Public methods

- (NSMutableDictionary*)convertDictionary:(NSDictionary*)initialDict forProtocol:(Protocol*)protocol error:(NSError *__autoreleasing *)error
{
    NSMutableDictionary* classDict = [self getPropertyDictonaryWithNameAndTypeForProtocol:protocol];
    return [self convertDictionary:initialDict forClassDictionary:classDict error:error];
}

- (NSMutableArray*)convertArray:(NSArray*)initialArray forProtocol:(Protocol*)protocol error:(NSError *__autoreleasing *)error
{
     NSMutableDictionary* classDict = [self getPropertyDictonaryWithNameAndTypeForProtocol:protocol];
        return [self convertArray:initialArray forClassDictionary:classDict error:error];
}

- (id)convertValue:(id)value toClass:(id)class
{
    BOOL wasObject = NO;
    if ([class respondsToSelector:@selector(isKindOfClass:)]) {
        wasObject = YES;
        class = [class class];
    }
    if ([value isKindOfClass:[NSString class]])
    {
        if ([class isSubclassOfClass:[NSNumber class]])
        {
            value = [_formatter numberFromString:value];
            value = !value ? @(0) : value;
        }
        else if ([class isSubclassOfClass:[NSArray class]])
        {
            value = @[value];
        }
        else if ([class isSubclassOfClass:[NSDictionary class]])
        {
            value = @{@"0":value};
        }
    }
    else if ([value isKindOfClass:[NSNumber class]])
    {
        if ([class isSubclassOfClass:[NSString class]])
        {
            value = [value stringValue];
        }
        else if ([class isSubclassOfClass:[NSArray class]])
        {
            value = @[value];
        }
        else if ([class isSubclassOfClass:[NSDictionary class]])
        {
            value = @{@"0":value};
        }
    }
    else if ([value isKindOfClass:[NSDictionary class]])
    {
        if ([class isSubclassOfClass:[NSString class]])
        {
            id dictValue = [[value allObjects] firstObject];
            if ([dictValue isKindOfClass:[NSNumber class]])
            {
                value = [dictValue stringValue];
            }
            else
            {
                value = dictValue;
            }
        }
        else if ([class isSubclassOfClass:[NSNumber class]])
        {
            id dictValue = [[value allObjects] firstObject];
            if ([dictValue isKindOfClass:[NSString class]])
            {
                value = [_formatter numberFromString:dictValue];
                value = !value ? @(0) : value;
            }
            else
            {
                value = dictValue;
            }
        }
        else if ([class isSubclassOfClass:[NSArray class]])
        {
            NSMutableArray* array = [[value allKeys] mutableCopy];
            
            __weak typeof(self)weakSelf = self;
            [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                if (![obj1 isKindOfClass:[NSNumber class]]) {
                    
                    obj1 = [weakSelf.formatter numberFromString:obj1];
                    obj2 = [weakSelf.formatter numberFromString:obj2];
                }
                return [obj1 compare:obj2];
            }];
            for (NSUInteger i = 0; i < array.count; i++) {
                array[i] = value[array[i]];
            }
            value = array;
        }
        
    }
    else if ([value isKindOfClass:[NSArray class]])
    {
        if ([class isSubclassOfClass:[NSString class]])
        {
            id arrayValue = [value firstObject];
            if ([arrayValue isKindOfClass:[NSNumber class]])
            {
                value = [arrayValue stringValue];
            }
            else
            {
                value = arrayValue;
            }
            
        }
        else if ([class isSubclassOfClass:[NSNumber class]])
        {
            id arrayValue = [value firstObject];
            if ([arrayValue isKindOfClass:[NSString class]])
            {
                value = [_formatter numberFromString:arrayValue];
                value = !value ? @(0) : value;
            }
            else
            {
                value = arrayValue;
            }
            
        }
        else if ([class isSubclassOfClass:[NSDictionary class]])
        {
            NSMutableDictionary* dict = [NSMutableDictionary new];
            if (wasObject) {
                dict = [value firstObject];
            }
            else
            {
                [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    dict[@(idx)] = obj;
                }];
            }
            value = dict;
        }
    }
    
    if ([value isEqual:[NSNull null]] || !value) {
        value = [self createEmptyObjectForClass:class];
    }
    return value;
}

#pragma mark - Explicit class converting

- (id)createEmptyObjectForClass:(Class)class
{
    if ([class isSubclassOfClass:[NSString class]]) {
        return @"";
    }
    else if ([class isSubclassOfClass:[NSNumber class]]) {
        return @(0);
    }
    else if ([class isSubclassOfClass:[NSArray class]]) {
        return @[];
    }
    else if ([class isSubclassOfClass:[NSDictionary class]]) {
        return @{};
    }
    
    return [NSNull null];
}

- (BOOL)compareClassForObject:(id)obj1 withObject:(id)obj2
{
    if ([obj1 isKindOfClass:[NSArray class]] && [obj2 isKindOfClass:[NSArray class]]) {
        return YES;
    }
    if ([obj1 isKindOfClass:[NSDictionary class]] && [obj2 isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    if ([obj1 isKindOfClass:[NSString class]] && [obj2 isKindOfClass:[NSString class]]) {
        return YES;
    }
    if ([obj1 isKindOfClass:[NSNumber class]] && [obj2 isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    return NO;
}

- (NSMutableArray*)convertArray:(NSArray*)initialArray forClassDictionary:(NSDictionary*)classDict error:(NSError *__autoreleasing *)error
{
    NSMutableArray* newArray = [initialArray mutableCopy];
    
    for (NSUInteger i = 0; i < newArray.count; i++) {
        if ([newArray[i] isKindOfClass:[NSDictionary class]]) {
            newArray[i] = [self convertDictionary:newArray[i] forClassDictionary:classDict error:error];
        }
    }
    return newArray;
}

- (NSMutableDictionary*)convertDictionary:(NSDictionary*)initialDict forClassDictionary:(NSDictionary*)classDict error:(NSError *__autoreleasing *)error
{
    NSMutableDictionary* newDict = [initialDict mutableCopy];
    __block NSError* localError = nil;
    if (error) {
        localError = *error;
    }
    
    for (id key in [newDict allKeys])
    {
        id obj = newDict[key];
        if (classDict[key])
        {
            if (![classDict[key] respondsToSelector:@selector(isSubclassOfClass:)] && [self compareClassForObject:classDict[key] withObject:obj]) //it's object, not a class
            {
                if ([classDict[key] isKindOfClass:[NSDictionary class]]) {
                    newDict[key] = [self convertDictionary:obj forClassDictionary:classDict[key] error:&localError];
                }
                else if([classDict[key] isKindOfClass:[NSArray class]])
                {
                    newDict[key] = [self convertArray:obj forClassDictionary:[classDict[key] firstObject] error:&localError];
                }
            }
            else
            {
                if (!obj || [obj isEqual:[NSNull null]]) {
                    newDict[key] = [self createEmptyObjectForClass:classDict[key]];
                }
                else if (![obj isKindOfClass:classDict[key]])
                {
                    Class class = classDict[key];
                    if ([class respondsToSelector:@selector(isKindOfClass:)]) {
                        class = [class class];
                    }
                    
                    NSString* errorText = [NSString stringWithFormat:@"Class Conversion in request | key:%@ | from:%@ to %@", key, [obj class],class];
                    if (![obj conformsToProtocol:@protocol(NSFastEnumeration)])
                    {
                        errorText = [errorText stringByAppendingString:[NSString stringWithFormat:@"\n value: %@", [obj description]]];
                    }
                    
                    newDict[key] = [self convertValue:obj toClass:classDict[key]];
//                    LOG_CONVERSION(@"%@", errorText);
                    if (error && !localError &&![localError domain]) {
                        localError = [NSError errorWithDomain:@"conversion" code:2 userInfo:@{NSLocalizedDescriptionKey: errorText}];
                    }
                }
                else
                {
                    __block BOOL needUpdateValue = NO;
                    id newValue;
                    if ([newDict[key] isKindOfClass:[NSDictionary class]]) {
                        __block NSUInteger counter = 0;
                        NSArray* objectArray = [newDict[key] allObjects];
                        newValue = [newDict[key] mutableCopy];
                        [newDict[key] enumerateKeysAndObjectsUsingBlock:^(id subkey, id subobj, BOOL *supstop) {
                            if ([subobj isEqual:[NSNull null]])
                            {
                                needUpdateValue = YES;
                                Class initialObjectClass = nil;
                                if (objectArray.count > 1)
                                {
                                    if (counter != 0) {
                                        initialObjectClass = [[objectArray firstObject] class];
                                    }
                                    else
                                    {
                                        initialObjectClass = [[objectArray lastObject] class];
                                    }
                                    
                                }
                                else
                                {
                                    initialObjectClass = [NSString class];
                                }
                                newValue[subkey] = [self createEmptyObjectForClass:initialObjectClass];
                            }
                            counter++;
                        }];
                    } else if ([newDict[key] isKindOfClass:[NSArray class]]) {
                        newValue = [newDict[key] mutableCopy];
                        [newDict[key] enumerateObjectsUsingBlock:^(id subobj, NSUInteger idx, BOOL *stop) {
                            if ([subobj isEqual:[NSNull null]])
                            {
                                needUpdateValue = YES;
                                Class initialObjectClass = nil;
                                if (((NSMutableArray*)newValue).count > 1)
                                {
                                    if (idx != 0) {
                                        initialObjectClass = [[newValue firstObject] class];
                                    }
                                    else
                                    {
                                        initialObjectClass = [[newValue lastObject] class];
                                    }
                                    
                                }
                                else
                                {
                                    initialObjectClass = [NSString class];
                                }
                                newValue[idx] = [self createEmptyObjectForClass:initialObjectClass];
                            }
                            
                        }];
                        
                    }
                    if (needUpdateValue) {
                        newDict[key] = newValue;
                        NSString* errorText = [NSString stringWithFormat:@"Null Conversion in request | key:%@ \nvalue:%@ \n from:<null> to %@", key, obj, classDict[key]];
//                        LOG_CONVERSION(@"%@", errorText);
                        if (error && !localError &&![localError domain]) {
                            localError = [NSError errorWithDomain:@"conversion" code:2 userInfo:@{NSLocalizedDescriptionKey: errorText}];
                        }
                    }
                }
                if (![classDict[key] respondsToSelector:@selector(isSubclassOfClass:)]) {
                    if ([classDict[key] isKindOfClass:[NSDictionary class]]) {
                        newDict[key] = [self convertDictionary:newDict[key] forClassDictionary:classDict[key] error:&localError];
                    }
                    else if([classDict[key] isKindOfClass:[NSArray class]])
                    {
                        newDict[key] = [self convertArray:newDict[key] forClassDictionary:[classDict[key] firstObject] error:&localError];
                    }
                    
                }
            }
        }
    }
    if (error) {
        *error = localError;
    }
    return newDict;
}

- (NSMutableDictionary*)getPropertyDictonaryWithNameAndTypeForProtocol:(Protocol*)protocol
{
    NSMutableDictionary *propetryWithTypeDict = [NSMutableDictionary dictionary];
    unsigned count;
    unsigned i;
    
    objc_property_t *properties = protocol_copyPropertyList(protocol, &count);
    for (i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *name = [NSString stringWithCString:propName
                                                encoding:[NSString defaultCStringEncoding]];
            
            const char *propType = property_getAttributes(property);
            NSString *propString = [NSString stringWithUTF8String:propType];
            NSArray *attrArray = [propString componentsSeparatedByString:@","];
            NSString *class=[attrArray firstObject];
            NSString *classNameWithProtocol = [[class stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"T@" withString:@""];
            NSArray *classesAndProtocols = [classNameWithProtocol componentsSeparatedByString:@"<"];
            if (classesAndProtocols.count > 1) //it's means that we have dictionary, that conforms to another protocol -> make resursive here
            {
                NSString* protocolNameWithSymbols = [classesAndProtocols lastObject];
                NSString* protocolName = [protocolNameWithSymbols substringToIndex:[protocolNameWithSymbols length] - 1];
                const char *protocolNameCharString = [protocolName UTF8String];
                Protocol* protocol = objc_getProtocol(protocolNameCharString);
                
                if ([[classesAndProtocols firstObject] isEqualToString:@"NSArray"])
                {
                    NSArray* array = @[[self getPropertyDictonaryWithNameAndTypeForProtocol:protocol]];
                    propetryWithTypeDict[name] = array;
                }
                else
                {
                    propetryWithTypeDict[name] = [self getPropertyDictonaryWithNameAndTypeForProtocol:protocol];
                }
            }
            else
            {
                propetryWithTypeDict[name] = objc_getClass([classNameWithProtocol UTF8String]);
            }
            
        }
    }
    
    free(properties);
    
    return propetryWithTypeDict;
}
@end
