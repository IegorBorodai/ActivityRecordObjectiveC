//
//  User.h
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/19/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "ACEphemeralObject.h"

@class Geo;

@interface User : ACEphemeralObject

@property (nonatomic, retain) NSDecimalNumber * age;
@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * chat_up_line;
@property (nonatomic, retain) NSDecimalNumber * children;
@property (nonatomic, retain) Geo *geo;

@end
