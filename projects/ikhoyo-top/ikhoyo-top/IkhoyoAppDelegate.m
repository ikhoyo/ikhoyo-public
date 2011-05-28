//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  ikhoyo_topAppDelegate.m
//  ikhoyo-top
//
//  Created by William Donahue on 5/24/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import "IkhoyoAppDelegate.h"
#import "RootViewController.h"

@implementation IkhoyoAppDelegate
@synthesize ready;
@synthesize window=_window;
@synthesize splitViewController=_splitViewController;
@synthesize rootViewController=_rootViewController;
@synthesize detailViewController=_detailViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];

	__block IkhoyoAppDelegate* me = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        me.ready = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IkhoyoReady" object:me];
    });
    
    return YES;
}

- (Boolean) isIkhoyoReady {
    return self.ready;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_splitViewController release];
    [_rootViewController release];
    [_detailViewController release];
    [super dealloc];
}

@end
