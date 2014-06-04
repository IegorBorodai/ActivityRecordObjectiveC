//
//  PHMappedObject.m
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/30/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "PHMappedObject.h"

@implementation PHMappedObject

- (id)initWithProperties:(NSDictionary *)properties
{
    if (self = [super init])
    {
        [EKMapper fillObject:self fromExternalRepresentation:properties withMapping:[[self class] objectMapping]];
    }
    
    return self;
}

+ (EKObjectMapping *)objectMapping
{
    return nil;
}

- (void)saveAsManagedObject
{
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:NULL];
}

@end
