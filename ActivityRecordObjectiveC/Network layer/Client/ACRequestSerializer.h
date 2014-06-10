//
//  ACRequestSerializer.h
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/9/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "PHNetworkRequest.h"

@interface ACRequestSerializer : AFHTTPRequestSerializer <AFURLRequestSerialization>

-(NSMutableURLRequest *)serializeRequestFromNetworkRequest:(PHNetworkRequest*)networkRequest error:(NSError* __autoreleasing*)error;

@end
