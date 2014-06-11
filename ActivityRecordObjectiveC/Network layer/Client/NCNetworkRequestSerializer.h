//
//  ACRequestSerializer.h
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/9/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "NCNetworkRequest.h"

@interface NCNetworkRequestSerializer : AFHTTPRequestSerializer <AFURLRequestSerialization>

-(NSMutableURLRequest *)serializeRequestFromNetworkRequest:(NCNetworkRequest*)networkRequest error:(NSError* __autoreleasing*)error;
-(NSMutableURLRequest *)serializeRequestForDownloadingPath:(NSString*)path error:(NSError* __autoreleasing*)error;

@end
