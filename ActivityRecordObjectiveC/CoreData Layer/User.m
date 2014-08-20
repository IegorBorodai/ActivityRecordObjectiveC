//
//  User.m
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/19/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "User.h"
#import "Geo.h"


@implementation User

@dynamic age;
@dynamic birthday;
@dynamic chat_up_line;
@dynamic children;
@dynamic geo;
@dynamic messages;

- (void)addMessagesObject:(Messages *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.messages];
    [tempSet addObject:value];
    self.messages = tempSet;
}


@end
