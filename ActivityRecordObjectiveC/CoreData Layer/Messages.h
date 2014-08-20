//
//  Messages.h
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 7/18/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "ACEphemeralObject.h"

@class User;

@interface Messages : ACEphemeralObject

@property (nonatomic, retain) NSString * autoreplyDescription;
@property (nonatomic, retain) NSString * msgType;
@property (nonatomic, retain) NSString * autoreplySubject;
@property (nonatomic, retain) User *user;

@end
