//
//  ACEphemeralObject.m
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/19/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "ACEphemeralObject.h"
@import ObjectiveC.runtime;
#import "MagicalRecord.h"

// used internally by the category impl
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
    self = [super init];
    if (self) {
        self.jsonDictionary = [jsonDictionary mutableCopy];
    }
    return self;
}

+ (instancetype)create
{
    ACEphemeralObject* obj = [[ACEphemeralObject alloc] init];
    obj.managedObject = [NSManagedObject MR_createEntity];
    return obj;
}

- (void)save
{
    if (!self.managedObject && self.jsonDictionary) {
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        self.managedObject = [[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context] insertIntoManagedObjectContext:context];
        
        unsigned count;
        objc_property_t *properties = class_copyPropertyList([self class], &count);
        
        for (NSInteger i = 0; i < count; i++)
        {
            objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if(propName) {
                NSString *name = [NSString stringWithCString:propName
                                                    encoding:[NSString defaultCStringEncoding]];
                
                [self.managedObject setValue:self.jsonDictionary[name] forKeyPath:name];
                
            }
        }
        
        free(properties);
    }
    [[self.managedObject managedObjectContext] MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
        NSLog(@"All is DONE");
    }];
}

- (void)saveAndWait
{
    
}

- (void)delete
{
    
}

+ (NSArray *)findAll
{
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context]];
    
    return [NSManagedObject MR_executeFetchRequest:request inContext:context];
}

#pragma mark - Internal methods


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
        } else {
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
        [self.managedObject forwardInvocation:invocation];
    } else {
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
