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

-(instancetype)initWithJsonDictionary:(NSDictionary *)jsonDictionary
{
    self = [self init];
    if (self) {
        self.jsonDictionary = [jsonDictionary mutableCopy];
        [self makeSubObjectsEphemeral];
    }
    return self;
}

+ (instancetype)createInMemoryFromJsonDictionary:(NSDictionary *)jsonDictionary
{
    ACEphemeralObject* obj = [[ACEphemeralObject alloc] initWithJsonDictionary:jsonDictionary];
    return obj;
}

+ (instancetype)create
{
    ACEphemeralObject* obj = [[ACEphemeralObject alloc] init];
    obj.managedObject = [NSManagedObject MR_createEntity];
    return obj;
}

- (void)convertToManagedObject {
    if (!self.managedObject && self.jsonDictionary) {
        self.managedObject = [ACEphemeralObject convertInMemoryObjectToManaged:self class:self.class];
    }
}

- (void)saveWithCompletionBlock:(void (^)(BOOL success, NSError *error))completion
{
    [self convertToManagedObject];
    [[self.managedObject managedObjectContext] MR_saveOnlySelfWithCompletion:completion];
}

- (void)saveAndWait
{
    [self convertToManagedObject];
    [[self.managedObject managedObjectContext] MR_saveOnlySelfAndWait];
}

- (void)delete
{
    if (self.managedObject) {
        [self.managedObject MR_deleteEntity];
    } else if(self.jsonDictionary) {
        [self.jsonDictionary removeAllObjects];
    }
}

+ (NSArray *)findAll
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context]];
    
    return [NSManagedObject MR_executeFetchRequest:request inContext:context];
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


+ (id)ephemeralObjectWrappingObject:(id)originalObject {
    id result = originalObject;
    
    if ([originalObject isKindOfClass:[NSDictionary class]]) {
        result = [ACEphemeralObject createInMemoryFromJsonDictionary:originalObject];
    }
    else if ([originalObject isKindOfClass:[NSArray class]]) {
        NSMutableOrderedSet* orderedSet = [NSMutableOrderedSet new];
        for (id obj in originalObject) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [orderedSet addObject:[ACEphemeralObject ephemeralObjectWrappingObject:obj]];
            } else {
                [orderedSet addObject:obj];
            }
            result = orderedSet;
        }
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
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    
    for (NSUInteger i = 0; i < count; i++)
    {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *name = [NSString stringWithCString:propName
                                                encoding:[NSString defaultCStringEncoding]];
            if (ephemObj.jsonDictionary[name]) {
                if ([ephemObj.jsonDictionary[name] isKindOfClass:[ACEphemeralObject class]]) {
                    Class subClass = [self getClassFromPropertyAttributes:property];
                    NSManagedObject* subObj = [self convertInMemoryObjectToManaged:ephemObj.jsonDictionary[name] class:subClass];
                    [obj setValue:subObj forKeyPath:name];
                } else if ([ephemObj.jsonDictionary[name] isKindOfClass:[NSOrderedSet class]]) {
                    
                } else {
                    [obj setValue:ephemObj.jsonDictionary[name] forKeyPath:name];
                }
            }
        }
    }
    free(properties);
    
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
