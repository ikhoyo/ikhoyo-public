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
#import "IkhoyoDatabase.h"
#import "IkhoyoURLManager.h"
#import "IkhoyoSocrata.h"
#import "JSONKit.h"

@implementation IkhoyoAppDelegate
@synthesize db;
@synthesize ready;
@synthesize socrata;
@synthesize urlManager;
@synthesize window=_window;
@synthesize rootViewController=_rootViewController;
@synthesize splitViewController=_splitViewController;
@synthesize detailViewController=_detailViewController;

- (NSString*) convertToColName:(NSString*) name {
    return [[[name stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByReplacingOccurrencesOfString:@"-" withString:@"_"] lowercaseString];
}

- (NSString*) convertValue:(id) val {
    if ([val isMemberOfClass:[NSNumber class]])
        return [val stringValue];
    else if ([val isKindOfClass:[NSArray class]])
        return @"";
    else if ([val isKindOfClass:[NSMutableArray class]])
        return @"";
    else if ([val isKindOfClass:[NSNull class]])
        return @"";
    else if ([val isKindOfClass:[NSString class]])
        return val;//[[@"'" stringByAppendingString:val] stringByAppendingString:@"'"];
    return @"";
}

- (void) loadTable:(id) json withColMap:(NSMutableDictionary*) map {
    id rows = [json objectForKey:@"data"];
    for (int i=0;i<[rows count];i++) {
        id row = [rows objectAtIndex:i];
        NSString* sep = @"";
        NSMutableArray* args = [NSMutableArray arrayWithCapacity:16];
        NSString* insert = @"INSERT INTO n5m4_msim VALUES (";
        NSString* values = @"(";
        for (int j=0;j<[row count];j++) {
            if (![map objectForKey:[NSNumber numberWithInt:j]])
                continue;
            id column = [row objectAtIndex:j];
            NSString* val = [self convertValue:column];
            [args addObject:val];
            insert  = [[insert stringByAppendingString:sep] stringByAppendingString:@"?"];
            values  = [[values stringByAppendingString:sep] stringByAppendingString:val];
            sep = @",";
        }
        insert = [insert stringByAppendingString:@")"];
        id ret = [self.db execFromDatabaseThread:insert withArgs:args];
        if ([ret isKindOfClass:[IkhoyoError class]])
            NSLog(@"Error inserting row %@(%@): %@",insert,values,[ret msg]);
    }
    NSNotification* not = [NSNotification notificationWithName:@"IkhoyoSocrataReady" object:self];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:not waitUntilDone:NO];
}

- (void) finishInit {
    self.urlManager = [[[IkhoyoURLManager alloc] init] autorelease];
    self.socrata = [[[IkhoyoSocrata alloc] initWithURLManager:urlManager] autorelease];
    
    NSDictionary* colTypeMap = [NSDictionary dictionaryWithObjectsAndKeys:@"INTEGER",@"integer",nil];
    [self.socrata get:@"n5m4-mism" withBlock:^(id data) {
        NSString* ct = @"CREATE TABLE n5m4_msim (id TEXT PRIMARY KEY NOT NULL";
        NSString* d = (NSString*) data;
        id json = [d objectFromJSONString];
        NSMutableDictionary* colMap = [[[NSMutableDictionary alloc] initWithCapacity:16] autorelease];
        id columns = [[[json objectForKey:@"meta"] objectForKey:@"view"] objectForKey:@"columns"];
        for (int i=0;i<[columns count];i++) {
            id col = [columns objectAtIndex:i];
            NSString* name = [self convertToColName:[col objectForKey:@"name"]];
            NSString* dataTypeName = [col objectForKey:@"dataTypeName"];
            if ([dataTypeName isEqualToString:@"meta_data"]&&![name isEqualToString:@"id"]) continue;
            NSNumber* n = [NSNumber numberWithInt:i];
            [colMap setObject:n forKey:n];
            if ([name isEqualToString:@"id"]) continue;
            
            NSString* sqliteType = [colTypeMap objectForKey:dataTypeName];
            if (sqliteType==nil)
                sqliteType = @"TEXT";
            NSString* coldef = [[[@"," stringByAppendingString:name] stringByAppendingString:@" "] stringByAppendingString:sqliteType];
            ct = [ct stringByAppendingString:coldef];
        }
        ct = [ct stringByAppendingString:@")"];
        [self.db execOnDatabaseThread:^(id obj) {
            [self.db execFromDatabaseThread:@"DROP TABLE n5m4_msim" withArgs:nil];
            id ret = [self.db execFromDatabaseThread:ct withArgs:nil];
            if ([ret isKindOfClass:[IkhoyoError class]])
                NSLog(@"Error creating table: %@",[ret msg]);
            else
                [self loadTable:json withColMap:colMap];
        }];
    }];    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];

	__block IkhoyoAppDelegate* me = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        JSONDecoder* dec = [JSONDecoder decoder]; // Dummy code to force loading of ikhoyo-socrata
        [dec retainCount]; // Gets rid of unused compiler warning
    
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* writablePath = [documentsDirectory stringByAppendingPathComponent:@"ikhoyo.sqlite"];
        me.db = [[[IkhoyoDatabase alloc] initWithPath:writablePath] autorelease];
        [me.db open:^(id dbase) {
            [me finishInit];
            me.ready = YES;
            NSNotification* not = [NSNotification notificationWithName:@"IkhoyoReady" object:me];
            [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:not waitUntilDone:NO];
        }];
        
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
