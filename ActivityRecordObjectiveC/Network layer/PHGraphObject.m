//
//  PHGraphObject.m
//  Phoenix
//
//  Created by Boroday on 30.09.13.
//  Copyright (c) 2013 massinteractiveserviceslimited. All rights reserved.
//

#import "PHGraphObject.h"
@import ObjectiveC.runtime;
#import "PHClassTypeConvertor.h"

// used internally by the category impl
typedef enum _SelectorInferredImplType {
    SelectorInferredImplTypeNone  = 0,
    SelectorInferredImplTypeGet = 1,
    SelectorInferredImplTypeSet = 2
} SelectorInferredImplType;


// internal-only wrapper
@interface PHGraphObjectArray : NSMutableArray

- (id)initWrappingArray:(NSArray *)otherArray;
- (id)graphObjectifyAtIndex:(NSUInteger)index;
- (void)graphObjectifyAll;

@end

@interface PHGraphObject ()

- (id)initWrappingDictionary:(NSDictionary *)otherDictionary;
- (void)graphObjectifyAll;
- (id)graphObjectifyAtKey:(id)key;

+ (id)graphObjectWrappingObject:(id)originalObject;
+ (SelectorInferredImplType)inferredImplTypeForSelector:(SEL)sel;
+ (BOOL)isProtocolImplementationInferable:(Protocol *)protocol checkFBGraphObjectAdoption:(BOOL)checkAdoption;

@end

@implementation PHGraphObject {
    NSMutableDictionary *_jsonObject;
}

#pragma mark Lifecycle

- (id)initWrappingDictionary:(NSDictionary *)jsonObject {
    (self = [super init]);
    if (self) {
        if ([jsonObject isKindOfClass:[PHGraphObject class]]) {
            // in this case, we prefer to return the original object,
            // rather than allocate a wrapper
            
            // no wrapper needed, returning the object that was provided
            return (PHGraphObject*)jsonObject;
        } else {
            _jsonObject = [NSMutableDictionary dictionaryWithDictionary:jsonObject];
        }
    }
    return self;
}


#pragma mark -
#pragma mark Public Members

+ (NSMutableDictionary<PHGraphObject>*)graphObject {
    return [PHGraphObject graphObjectWrappingDictionary:[NSMutableDictionary dictionary]];
}

+ (NSMutableDictionary<PHGraphObject>*)graphObjectWrappingDictionary:(NSDictionary*)jsonDictionary {
    return [PHGraphObject graphObjectWrappingObject:jsonDictionary];
}

+ (NSMutableDictionary<PHGraphObject>*)graphObjectWrappingDictionary:(NSDictionary*)jsonDictionary withProtocolConversion:(Protocol*)protocol subProtocols:(NSArray*)subProtocols error:(NSError *__autoreleasing *)error
{
    if (subProtocols && subProtocols.count > 0) {
        for (Protocol* proto in subProtocols) {
            Protocol* testProto = objc_getProtocol(protocol_getName(proto));
            if (!testProto) {
                objc_registerProtocol(proto);
            }
        }
    }
    PHClassTypeConvertor* convertor = [PHClassTypeConvertor new];
    return [PHGraphObject graphObjectWrappingObject:[convertor convertDictionary:jsonDictionary forProtocol:protocol error:error]];
}


+ (NSArray<PHGraphObject>*)graphObjectWrappingArray:(NSArray*)jsonArray {
    return [PHGraphObject graphObjectWrappingObject:jsonArray];
}

+ (NSArray<PHGraphObject>*)graphObjectWrappingArray:(NSArray*)jsonArray withProtocolConversion:(Protocol*)protocol subProtocols:(NSArray*)subProtocols error:(NSError *__autoreleasing *)error
{
    if (subProtocols && subProtocols.count > 0) {
        for (Protocol* proto in subProtocols) {
            Protocol* testProto = objc_getProtocol(protocol_getName(proto));
            if (!testProto) {
                objc_registerProtocol(proto);
            }
        }
    }
     PHClassTypeConvertor* convertor = [PHClassTypeConvertor new];
    return [PHGraphObject graphObjectWrappingArray:[convertor convertArray:jsonArray forProtocol:protocol error:error]];
}

#pragma mark -
#pragma mark NSObject overrides

// make the respondsToSelector method do the right thing for the selectors we handle
- (BOOL)respondsToSelector:(SEL)sel
{
    return  [super respondsToSelector:sel] ||
    ([PHGraphObject inferredImplTypeForSelector:sel] != SelectorInferredImplTypeNone);
}

- (BOOL)conformsToProtocol:(Protocol *)protocol {
    return  [super conformsToProtocol:protocol] ||
    ([PHGraphObject isProtocolImplementationInferable:protocol
                           checkFBGraphObjectAdoption:YES]);
}

// returns the signature for the method that we will actually invoke
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    SEL alternateSelector = sel;
    
    // if we should forward, to where?
    switch ([PHGraphObject inferredImplTypeForSelector:sel]) {
        case SelectorInferredImplTypeGet:
            alternateSelector = @selector(objectForKey:);
            break;
        case SelectorInferredImplTypeSet:
            alternateSelector = @selector(setObject:forKey:);
            break;
        case SelectorInferredImplTypeNone:
        default:
            break;
    }
    
    return [super methodSignatureForSelector:alternateSelector];
}

// forwards otherwise missing selectors that match the FBGraphObject convention
- (void)forwardInvocation:(NSInvocation *)invocation {
    // if we should forward, to where?
    switch ([PHGraphObject inferredImplTypeForSelector:[invocation selector]]) {
        case SelectorInferredImplTypeGet: {
            // property getter impl uses the selector name as an argument...
            NSString *propertyName = NSStringFromSelector([invocation selector]);
            [invocation setArgument:&propertyName atIndex:2];
            //... to the replacement method objectForKey:
            invocation.selector = @selector(objectForKey:);
            [invocation invokeWithTarget:self];
            break;
        }
        case SelectorInferredImplTypeSet: {
            // property setter impl uses the selector name as an argument...
            NSMutableString *propertyName = [NSMutableString stringWithString:NSStringFromSelector([invocation selector])];
            // remove 'set' and trailing ':', and lowercase the new first character
            [propertyName deleteCharactersInRange:NSMakeRange(0, 3)];                       // "set"
            [propertyName deleteCharactersInRange:NSMakeRange(propertyName.length - 1, 1)]; // ":"
            
            NSString *firstChar = [[propertyName substringWithRange:NSMakeRange(0,1)] lowercaseString];
            [propertyName replaceCharactersInRange:NSMakeRange(0, 1) withString:firstChar];
            // the object argument is already in the right place (2), but we need to set the key argument
            [invocation setArgument:&propertyName atIndex:3];
            // and replace the missing method with setObject:forKey:
            invocation.selector = @selector(setObject:forKey:);
            [invocation invokeWithTarget:self];
            break;
        }
        case SelectorInferredImplTypeNone:
        default:
            [super forwardInvocation:invocation];
            return;
    }
}

- (id)graphObjectifyAtKey:(id)key {
    id object = [_jsonObject objectForKey:key];
    // make certain it is FBObjectGraph-ified
    id possibleReplacement = [PHGraphObject graphObjectWrappingObject:object];
    if (object != possibleReplacement) {
        // and if not-yet, replace the original with the wrapped object
        [_jsonObject setObject:possibleReplacement forKey:key];
        object = possibleReplacement;
    }
    return object;
}

- (void)graphObjectifyAll {
    NSArray *keys = [_jsonObject allKeys];
    for (NSString *key in keys) {
        [self graphObjectifyAtKey:key];
    }
}


#pragma mark -

#pragma mark NSDictionary and NSMutableDictionary overrides

- (NSUInteger)count {
    return _jsonObject.count;
}

- (id)objectForKey:(id)key {
    return [self graphObjectifyAtKey:key];
}

- (NSEnumerator *)keyEnumerator {
    [self graphObjectifyAll];
    return _jsonObject.keyEnumerator;
}

- (void)setObject:(id)object forKey:(id)key {
    return [_jsonObject setObject:object forKey:key];
}

- (void)removeObjectForKey:(id)key {
    return [_jsonObject removeObjectForKey:key];
}


#pragma mark -
#pragma mark Private Class Members

+ (id)graphObjectWrappingObject:(id)originalObject {
    // non-array and non-dictionary case, returns original object
    id result = originalObject;
    
    // array and dictionary wrap
    if ([originalObject isKindOfClass:[NSDictionary class]]) {
        result = [[PHGraphObject alloc] initWrappingDictionary:originalObject];
    }
    else if ([originalObject isKindOfClass:[NSArray class]]) {
        result = [[PHGraphObjectArray alloc] initWrappingArray:originalObject];
    }

    // return our object
    return result;
}

// helper method used by the catgory implementation to determine whether a selector should be handled
+ (SelectorInferredImplType)inferredImplTypeForSelector:(SEL)sel {
    // the overhead in this impl is high relative to the cost of a normal property
    // accessor; if needed we will optimize by caching results of the following
    // processing, indexed by selector
    
    NSString *selectorName = NSStringFromSelector(sel);
    NSUInteger	parameterCount = [[selectorName componentsSeparatedByString:@":"] count]-1;
    // we will process a selector as a getter if paramCount == 0
    if (parameterCount == 0) {
        return SelectorInferredImplTypeGet;
        // otherwise we consider a setter if...
    } else if (parameterCount == 1 &&                   // ... we have the correct arity
               [selectorName hasPrefix:@"set"] &&       // ... we have the proper prefix
               selectorName.length > 4) {               // ... there are characters other than "set" & ":"
        return SelectorInferredImplTypeSet;
    }
    
    return SelectorInferredImplTypeNone;
}

+ (BOOL)isProtocolImplementationInferable:(Protocol*)protocol checkFBGraphObjectAdoption:(BOOL)checkAdoption {
    // first handle base protocol questions
    if (checkAdoption && !protocol_conformsToProtocol(protocol, @protocol(PHGraphObject))) {
        return NO;
    }
    
    if (protocol == @protocol(PHGraphObject)) {
        return YES; // by definition
    }

    unsigned int count = 0;
    struct objc_method_description *methods = nil;
    
    // then confirm that all methods are required
    methods = protocol_copyMethodDescriptionList(protocol,
                                                 NO,        // optional
                                                 YES,       // instance
                                                 &count);
    if (methods) {
        free(methods);
        return NO;
    }
    
    @try {
        // fetch methods of the protocol and confirm that each can be implemented automatically
        methods = protocol_copyMethodDescriptionList(protocol,
                                                     YES,   // required
                                                     YES,   // instance
                                                     &count);
        for (unsigned int index = 0; index < count; index++) {
            if ([PHGraphObject inferredImplTypeForSelector:methods[index].name] == SelectorInferredImplTypeNone) {
                // we have a bad actor, short circuit
                return NO;
            }
        }
    } @finally {
        if (methods) {
            free(methods);
        }
    }
    
    // fetch adopted protocols
    Protocol * __unsafe_unretained *adopted = nil;
    @try {
        adopted = protocol_copyProtocolList(protocol, &count);
        for (unsigned int index = 0; index < count; index++) {
            // here we go again...
            if (![PHGraphObject isProtocolImplementationInferable:adopted[index]
                                       checkFBGraphObjectAdoption:NO]) {
                return NO;
            }
        }
    } @finally {
        if (adopted) {
            free(adopted);
        }
    }
    
    // protocol ran the gauntlet
    return YES;
}

#pragma mark internal classes

@end

@implementation PHGraphObjectArray {
    NSMutableArray *_jsonArray;
}

- (id)initWrappingArray:(NSArray *)jsonArray {
    (self = [super init]);
    if (self) {
        if ([jsonArray isKindOfClass:[PHGraphObjectArray class]]) {

            return (PHGraphObjectArray*)jsonArray;
        } else {
            _jsonArray = [NSMutableArray arrayWithArray:jsonArray];
        }
    }
    return self;
}

- (NSUInteger)count {
    return _jsonArray.count;
}

- (id)graphObjectifyAtIndex:(NSUInteger)index {
    id object = [_jsonArray objectAtIndex:index];
    // make certain it is FBObjectGraph-ified
    id possibleReplacement = [PHGraphObject graphObjectWrappingObject:object];
    if (object != possibleReplacement) {
        // and if not-yet, replace the original with the wrapped object
        [_jsonArray replaceObjectAtIndex:index withObject:possibleReplacement];
        object = possibleReplacement;
    }
    return object;
}

- (void)graphObjectifyAll {
    NSUInteger count = [_jsonArray count];
    for (NSUInteger i = 0; i < count; ++i) {
        [self graphObjectifyAtIndex:i];
    }
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self graphObjectifyAtIndex:index];
}

- (NSEnumerator *)objectEnumerator {
    [self graphObjectifyAll];
    return _jsonArray.objectEnumerator;
}

- (NSEnumerator *)reverseObjectEnumerator {
    [self graphObjectifyAll];
    return _jsonArray.reverseObjectEnumerator;
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index {
    [_jsonArray insertObject:object atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [_jsonArray removeObjectAtIndex:index];
}

- (void)addObject:(id)object {
    [_jsonArray addObject:object];
}

- (void)removeLastObject {
    [_jsonArray removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object {
    [_jsonArray replaceObjectAtIndex:index withObject:object];
}


@end
