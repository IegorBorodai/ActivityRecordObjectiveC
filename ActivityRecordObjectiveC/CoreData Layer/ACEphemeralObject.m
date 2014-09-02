//
//  ACEphemeralObject.m
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/19/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "ACEphemeralObject.h"
@import ObjectiveC.runtime;

typedef enum _SelectorInferredImplType {
    SelectorInferredImplTypeNone  = 0,
    SelectorInferredImplTypeGet = 1,
    SelectorInferredImplTypeSet = 2
} SelectorInferredImplType;

@interface ACEphemeralObject ()

@property (nonatomic, strong, readwrite) NSMutableDictionary     *jsonDictionary;
@property (nonatomic, strong, readwrite) NSManagedObject         *managedObject;

@end

@implementation ACEphemeralObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.jsonDictionary = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - Public methods

-(instancetype)initWithJsonDictionary:(NSDictionary *)jsonDictionary
{
    self = [self init];
    if (self) {
        self.jsonDictionary = [jsonDictionary mutableCopy];
        [self makeSubObjectsEphemeral];
    }
    return self;
}

-(instancetype)initWithManagedObject:(NSManagedObject *)managedObject
{
    self = [self init];
    if (self) {
        self.managedObject = managedObject;
    }
    return self;
}

+ (instancetype)create
{
    ACEphemeralObject* obj = [[self.class alloc] init];
    obj.managedObject = [NSManagedObject MR_createEntity];
    return obj;
}

- (void)convertToManagedObject {
    if (!self.managedObject && self.jsonDictionary) {
        self.managedObject = [ACEphemeralObject convertInMemoryObjectToManaged:self class:self.class];
        self.jsonDictionary = nil;
    }
}

- (void)saveWithCompletionBlock:(void (^)(BOOL success, NSError *error))completion
{
    [self convertToManagedObject];
    [[self.managedObject managedObjectContext] MR_saveToPersistentStoreWithCompletion:completion];
}

- (void)saveAndWait
{
    [self convertToManagedObject];
    [[self.managedObject managedObjectContext] MR_saveToPersistentStoreAndWait];
}

- (void)delete
{
    if (self.managedObject) {
        [self.managedObject MR_deleteEntity];
    } else if(self.jsonDictionary) {
        [self.jsonDictionary removeAllObjects];
    }
}


+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context]];
    if(predicate) {
        [request setPredicate:predicate];
    }
    if(sortDescriptors) {
        [request setSortDescriptors:sortDescriptors];
    }
    
    NSArray* array = [NSManagedObject MR_executeFetchRequest:request inContext:context];
    
    NSMutableArray *ephemeralArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSManagedObject *obj in array) {
        [ephemeralArray addObject:[ACEphemeralObject ephemeralObjectWrappingObject:obj]];
    }
    
    return ephemeralArray;
}

+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate
{
    return [self findAllWithPredicate:predicate sortDescriptors:nil];
}


+ (NSArray *)findAllWithSortDescriptors:(NSArray *)sortDescriptors
{
    return [self findAllWithPredicate:nil sortDescriptors:sortDescriptors];
}

+ (NSArray *)findAll
{
    return [self findAllWithPredicate:nil sortDescriptors:nil];
}


#pragma mark - Merge methods

- (void)mergeWithManagedObject:(NSManagedObject *)managedObj
{
    if (self.managedObject) {
        unsigned count;
        objc_property_t *properties = class_copyPropertyList(self.class, &count);
        
        for (NSUInteger i = 0; i < count; i++)
        {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if(propName) {
                NSString *name = [NSString stringWithCString:propName
                                                    encoding:[NSString defaultCStringEncoding]];
                if ([managedObj valueForKey:name]) {
                    [self.managedObject setValue:[managedObj valueForKey:name] forKey:name];
                }
            }
        }
    } else if (self.jsonDictionary) {
        self.managedObject = managedObj;
        [self mergeWithJsonDictionary:self.jsonDictionary];
        self.jsonDictionary = nil;
    } else {
        self.managedObject = managedObj;
    }
}

- (void)mergeWithJsonDictionary:(NSDictionary *)jsonDictionary
{
    if (self.managedObject) {
        [ACEphemeralObject addJsonDictionary:jsonDictionary toManagedObject:self.managedObject class:self.class];
    } else if (self.jsonDictionary) {
        for (NSString *key in jsonDictionary) {
            if ([self.jsonDictionary[key] isKindOfClass:[NSOrderedSet class]] && [jsonDictionary[key] isKindOfClass:[NSOrderedSet class]]) {
                NSMutableOrderedSet *set = [self.jsonDictionary[key] mutableCopy];
                [set unionOrderedSet:jsonDictionary[key]];
                self.jsonDictionary[key] = set;
            } else {
                self.jsonDictionary[key] = jsonDictionary[key];
            }
        }
    } else {
        self.jsonDictionary = [jsonDictionary mutableCopy];
    }
}


- (void)mergeWithCoreDataByPredicate:(NSPredicate *)predicate
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
    request.predicate = predicate;
    request.fetchLimit = 1;
    
    NSArray* result = [NSManagedObject MR_executeFetchRequest:request inContext:context];
    NSManagedObject* managedObj = [result lastObject];
    
    [self mergeWithManagedObject:managedObj];
}

- (void)mergeWithOtherEphemeralObject:(ACEphemeralObject *)ephemObj
{
    if (ephemObj) {
        if (ephemObj.managedObject) {
            [self mergeWithManagedObject:ephemObj.managedObject];
        } else if (ephemObj.jsonDictionary) {
            [self mergeWithJsonDictionary:ephemObj.jsonDictionary];
        }
    }
}

+ (void)addJsonDictionary:(NSDictionary *)jsonDictionary toManagedObject:(NSManagedObject *)managedObject class:(Class)class
{
    unsigned count;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *name = [NSString stringWithCString:propName
                                                encoding:[NSString defaultCStringEncoding]];
            if (jsonDictionary[name]) {
                if ([jsonDictionary[name] isKindOfClass:[ACEphemeralObject class]]) {
                    Class subClass = [ACEphemeralObject getClassFromPropertyAttributes:property];
                    NSManagedObject* subObj = [ACEphemeralObject convertInMemoryObjectToManaged:jsonDictionary[name] class:subClass];
                    [managedObject setValue:subObj forKeyPath:name];
                } else if ([jsonDictionary[name] isKindOfClass:[NSOrderedSet class]]) {
                    const char *propAttribute = property_getAttributes(property);
                    NSString *propAttributeString = [NSString stringWithUTF8String:propAttribute];
                    NSArray *attrArray = [propAttributeString componentsSeparatedByString:@","];
                    NSString *attribute=[attrArray firstObject];
                    NSString *classNameWithProtocol = [[attribute stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"T@" withString:@""];
                    NSArray *classesAndProtocols = [classNameWithProtocol componentsSeparatedByString:@"<"];
                    NSString* protocolNameWithSymbols = [classesAndProtocols lastObject];
                    NSString* protocolName = [protocolNameWithSymbols substringToIndex:[protocolNameWithSymbols length] - 1];
                    const char *protocolNameCharString = [protocolName UTF8String];
                    
                    Class subClass = objc_getClass(protocolNameCharString);
                    
                    NSMutableOrderedSet *compoundOrederedSet = [managedObject valueForKey:name];
                    if (subClass) {
                        NSMutableOrderedSet * set = [NSMutableOrderedSet new];
                        NSMutableArray *backRelationNames = nil;
                        for (ACEphemeralObject *obj in jsonDictionary[name]) {
                            NSManagedObject* subObj = [ACEphemeralObject convertInMemoryObjectToManaged:obj class:subClass];
                            
                            if (!backRelationNames) {
                                backRelationNames = [NSMutableArray new];
                                unsigned subCount;
                                objc_property_t *subProperties = class_copyPropertyList(subClass, &subCount);
                                
                                for (NSUInteger j = 0; j < subCount; j++)
                                {
                                    objc_property_t subProperty = subProperties[j];
                                    const char *subPropName = property_getName(subProperty);
                                    if(subPropName) {
                                        NSString *subName = [NSString stringWithCString:subPropName
                                                                               encoding:[NSString defaultCStringEncoding]];
                                        
                                        const char *subPropAttribute = property_getAttributes(subProperty);
                                        NSString *subPropAttributeString = [NSString stringWithUTF8String:subPropAttribute];
                                        NSArray *subAttrArray = [subPropAttributeString componentsSeparatedByString:@","];
                                        NSString *subAttribute=[subAttrArray firstObject];
                                        NSString *className = [[subAttribute stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"T@" withString:@""];
                                        const char *classNameCharString = [className UTF8String];
                                        
                                        Class managedSubClass = objc_getClass(classNameCharString);
                                        
                                        if ([managedSubClass isSubclassOfClass:class]) {
                                            [backRelationNames addObject:subName];
                                        }
                                    }
                                }
                            }
                            
                            for (NSString *backRelationName in backRelationNames) {
                                [subObj setValue:managedObject forKey:backRelationName];
                            }
                            
                            [set addObject:subObj];
                        }
                        if (compoundOrederedSet) {
                            [compoundOrederedSet unionOrderedSet:set];
                        } else {
                            compoundOrederedSet = set;
                        }
                        [managedObject setValue:compoundOrederedSet forKeyPath:name];
                    } else {
                        if (compoundOrederedSet) {
                            [compoundOrederedSet unionOrderedSet:jsonDictionary[name]];
                        } else {
                            compoundOrederedSet = jsonDictionary[name];
                        }
                        [managedObject setValue:compoundOrederedSet forKeyPath:name];
                    }
                }  else {
                    [managedObject setValue:jsonDictionary[name] forKeyPath:name];
                }
            }
        }
    }
    free(properties);
}


#pragma mark - Object tracer

- (void)makeSubObjectsEphemeral {
    NSArray *keys = [self.jsonDictionary allKeys];
    for (NSString *key in keys) {
        [self makeSubObjectEphemeralAtKey:key];
    }
}

- (id)makeSubObjectEphemeralAtKey:(id)key {
    id object = [self.jsonDictionary objectForKey:key];
    id possibleReplacement = [ACEphemeralObject ephemeralObjectWrappingObject:object];
    if (object != possibleReplacement) {
        [self.jsonDictionary setObject:possibleReplacement forKey:key];
        object = possibleReplacement;
    }
    return object;
}


+ (instancetype)ephemeralObjectWrappingObject:(id)originalObject {
    id result = originalObject;
    
    if ([originalObject isKindOfClass:[NSDictionary class]]) {
        result = [[self.class alloc] initWithJsonDictionary:originalObject];
    }
    else if ([originalObject isKindOfClass:[NSArray class]]) {
        NSMutableOrderedSet* orderedSet = [NSMutableOrderedSet new];
        for (id obj in originalObject) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [orderedSet addObject:[self.class ephemeralObjectWrappingObject:obj]];
            } else {
                [orderedSet addObject:obj];
            }
        }
        result = [orderedSet copy];
    } else if ([originalObject isKindOfClass:[NSManagedObject class]]) {
        result = [[self.class alloc] initWithManagedObject:originalObject];
    }
    
    return result;
}

#pragma mark - Internal methods

+ (Class)getClassFromPropertyAttributes:(objc_property_t)property
{
    const char *propType = property_getAttributes(property);
    NSString *propString = @(propType);
    NSArray *attrArray = [propString componentsSeparatedByString:@","];
    NSString *classString=[[[attrArray firstObject] stringByReplacingOccurrencesOfString:@"\"" withString:@""] stringByReplacingOccurrencesOfString:@"T@" withString:@""];
    Class class = objc_getClass([classString UTF8String]);
    return class;
}

+ (NSManagedObject*)convertInMemoryObjectToManaged:(ACEphemeralObject*)ephemObj class:(Class)class
{
    NSManagedObject* obj = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:NSStringFromClass(class) inManagedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]] insertIntoManagedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    [ACEphemeralObject addJsonDictionary:ephemObj.jsonDictionary toManagedObject:obj class:class];
    return obj;
}

#pragma mark - Forward invocation


- (BOOL)respondsToSelector:(SEL)sel
{
    return  [super respondsToSelector:sel] ||
    ([ACEphemeralObject inferredImplTypeForSelector:sel] != SelectorInferredImplTypeNone);
}

+ (SelectorInferredImplType)inferredImplTypeForSelector:(SEL)sel {
    
    NSString *selectorName = NSStringFromSelector(sel);
    NSUInteger	parameterCount = [[selectorName componentsSeparatedByString:@":"] count]-1;
    if (parameterCount == 0) {
        return SelectorInferredImplTypeGet;
    } else if (parameterCount == 1 &&
               [selectorName hasPrefix:@"set"] &&
               selectorName.length > 4) {
        return SelectorInferredImplTypeSet;
    }
    
    return SelectorInferredImplTypeNone;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        
        if (self.managedObject) {
            signature = [self.managedObject methodSignatureForSelector:selector];
        } else if (self.jsonDictionary) {
            switch ([ACEphemeralObject inferredImplTypeForSelector:selector]) {
                case SelectorInferredImplTypeGet: {
                    signature = [self.jsonDictionary methodSignatureForSelector:@selector(objectForKey:)];
                    break;
                }
                case SelectorInferredImplTypeSet: {
                    signature = [self.jsonDictionary methodSignatureForSelector:@selector(setObject:forKey:)];
                    break;
                }
                case SelectorInferredImplTypeNone:
                default:
                    break;
            }
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (self.managedObject) {
        invocation.target = self.managedObject;
        [invocation invoke];
    } else if (self.jsonDictionary) {
        switch ([ACEphemeralObject inferredImplTypeForSelector:[invocation selector]]) {
            case SelectorInferredImplTypeGet: {
                NSString *propertyName = NSStringFromSelector([invocation selector]);
                [invocation setArgument:&propertyName atIndex:2];
                invocation.selector = @selector(objectForKey:);
                [invocation invokeWithTarget:self.jsonDictionary];
                break;
            }
            case SelectorInferredImplTypeSet: {
                NSMutableString *propertyName = [NSMutableString stringWithString:NSStringFromSelector([invocation selector])];
                [propertyName deleteCharactersInRange:NSMakeRange(0, 3)];
                [propertyName deleteCharactersInRange:NSMakeRange(propertyName.length - 1, 1)];
                
                NSString *firstChar = [[propertyName substringWithRange:NSMakeRange(0,1)] lowercaseString];
                [propertyName replaceCharactersInRange:NSMakeRange(0, 1) withString:firstChar];
                [invocation setArgument:&propertyName atIndex:3];
                invocation.selector = @selector(setObject:forKey:);
                [invocation invokeWithTarget:self.jsonDictionary];
                break;
            }
            case SelectorInferredImplTypeNone:
            default:
                [super forwardInvocation:invocation];
                return;
        }
    }
}

@end
