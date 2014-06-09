//
//  PHBaseManagedObject.h
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 6/4/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface PHBaseManagedObject : NSManagedObject

- (id)initWithDictionaryFromServer:(NSDictionary *)dictFromServer;

@end
