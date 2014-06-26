//
//  ACAppDelegate.m
//  ActivityRecordObjectiveC
//
//  Created by Iegor Borodai on 6/9/14.
//  Copyright (c) 2014 Iegor Borodai. All rights reserved.
//

#import "ACAppDelegate.h"
#import "NCNetworkClient.h"

@implementation ACAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
    [NCNetworkClient initNetworkClientWithRootPath:@"https://www.matureaffection.com"];
    [[NCNetworkClient networkClient] addObserver:self forKeyPath:@"reachabilityStatus" options:NSKeyValueObservingOptionNew context:NULL];
    
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"ActivityRecordObjectiveC"];
    
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
//    [NCNetworkClient getGenderInfoWithSuccessBlock:^(NSDictionary *genderAttributes) {
//        NSLog([genderAttributes description]);
//    } failure:^(NSError *error, BOOL isCanceled) {
//        NSLog([error localizedDescription]);
//    }];
    
    [NCNetworkClient getGrapUserWithSuccessBlock:^(NSDictionary *genderAttributes) {
        
    } failure:^(NSError *error, BOOL isCanceled) {
        NSLog(@"%@",[error localizedDescription]);
    }];

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
    // Saves changes in the application's managed object context before the application terminates.
}

@end
