//
//  Geo.h
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/19/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "ACEphemeralObject.h"

@class User;

@interface Geo : ACEphemeralObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) User *user;

@end
