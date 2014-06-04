//
//  PHAppDelegate.m
//  PHTestMapping
//
//  Created by Vladimir Milichenko on 5/29/14.
//  Copyright (c) 2014 massinteractiveserviceslimited. All rights reserved.
//

#import "PHAppDelegate.h"

#import "AFHTTPRequestOperationManager.h"

#import "PHManagedObjectMappingProvider.h"

#import "PHErrorResponse.h"
#import "PHResponse.h"
#import "PHError.h"

#import "PHManagedErrorResponse.h"
#import "PHManagedResponse.h"
#import "PHManagedError.h"

#import "EKManagedObjectMapper.h"

@implementation PHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"Model"];
    
    __block NSArray *errorResponses = [PHManagedErrorResponse MR_findAll];
    
    NSLog(@"count: %d", errorResponses.count);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:@"http://api.wunderground.com/api/Your_Key/conditions/q/CA/San_Francisco.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"PHManagedErrorResponse" inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
        PHManagedErrorResponse *managedErrorResponse = [[PHManagedErrorResponse alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil];
        
        errorResponses = [PHManagedErrorResponse MR_findAll];
        
        NSLog(@"count: %d", errorResponses.count);
        
//        PHErrorResponse *errorResponse = [[PHErrorResponse alloc] initWithProperties:responseObject];//[EKMapper objectFromExternalRepresentation:responseObject withMapping:[PHObjectMappingProvider errorResponseMapping]];
//        errorResponse.responseObject = responseObject;
//        
//        NSLog(@"Mapping on objects:\nError description:%@\n terms of service: %@\n version: %@\n error type: %@",
//              errorResponse.response.error.errorDescription,
//              errorResponse.response.termsofService,
//              errorResponse.response.version,
//              errorResponse.response.error.errorType);
//        
//        PHManagedErrorResponse *managedErrorResponse = [EKManagedObjectMapper objectFromExternalRepresentation:responseObject
//                                                                           withMapping:[PHManagedObjectMappingProvider errorResponseMapping]
//                                                                inManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
//        
//        NSLog(@"Mapping on managed objects:\nError description:%@\n terms of service: %@\n version: %@\n error type: %@",
//              managedErrorResponse.response.error.errorDescription,
//              managedErrorResponse.response.termsofService,
//              managedErrorResponse.response.version,
//              managedErrorResponse.response.error.errorType);
//        
//        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:NULL];
//        
//        [errorResponse saveAsManagedObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"AFHTTPRequestOperation error: %@", error);
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
