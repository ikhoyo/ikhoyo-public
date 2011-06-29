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
//  IkhoyoSocrata.m
//  ikhoyo-socrata
//
//  Created by William Donahue on 6/24/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import "IkhoyoSocrata.h"

@implementation IkhoyoSocrata
@synthesize tasks;
@synthesize baseURL;
@synthesize viewURL;
@synthesize dataType;
@synthesize urlManager;
@synthesize appTokenQS;

- (id) initWithURLManager:(id) um {
    return [self initWithURLManager:um andApiKey:nil];
}

- (id) initWithURLManager:(id) um andApiKey:(NSString*) apiKey {
    return [self initWithURLManager:um andApiKey:nil andDataType:@"json"];
}

- (id) initWithURLManager:(id) um andApiKey:(NSString*) apiKey andDataType:(NSString*) dt {
	if ((self=[super init])) {
        self.dataType = dt;
		self.urlManager = um;
        if (apiKey)
            self.appTokenQS = [@"app_token=" stringByAppendingString:apiKey];
        self.baseURL = @"http://opendata.socrata.com/api";
        self.viewURL = [self.baseURL stringByAppendingString:@"/views/"];
        self.tasks = [[[NSMutableArray alloc] init] autorelease];
	}
	return self;
}

- (void) get:(NSString*) ds withBlock:(IkhoyoBlock) block {
    return [self get:ds maxRows:0 withBlock:block];
}

- (void) getMeta:(NSString*) ds withBlock:(IkhoyoBlock) block {
    NSString* sep = @"?";
    NSString* url = [[[viewURL stringByAppendingString:ds] stringByAppendingString:@"."] stringByAppendingString:self.dataType];
    if (self.appTokenQS) {
        url = [[url stringByAppendingString:sep] stringByAppendingString:ds];
        sep = @"&";
    }

    id task = [self.urlManager load:[NSURL URLWithString:url] delegate:self];
    IkhoyoTask* tb = [[IkhoyoTask alloc] init];
    tb.obj = task;
	tb.task = block;
    [self.tasks addObject:tb];
}

- (void) get:(NSString*) ds maxRows:(int)max withBlock:(IkhoyoBlock) block {
    NSString* sep = @"?";
    NSString* url = [[[viewURL stringByAppendingString:ds] stringByAppendingString:@"/rows."] stringByAppendingString:self.dataType];
    if (self.appTokenQS) {
        url = [[url stringByAppendingString:sep] stringByAppendingString:ds];
        sep = @"&";
    }
    if (max>0) {
        url = [[url stringByAppendingString:sep] stringByAppendingFormat:@"max_rows=%d",max];
        sep = @"&";
    }
    
    id task = [self.urlManager load:[NSURL URLWithString:url] delegate:self];
    IkhoyoTask* tb = [[IkhoyoTask alloc] init];
    tb.obj = task;
	tb.task = block;
    [self.tasks addObject:tb];
}

- (NSString*) convertData:(NSData*) data {
    return [[[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding: NSUTF8StringEncoding] autorelease];
}

-(void) urlTaskFailed:(IkhoyoURLTask*) task {
    [self performSelectorOnMainThread:@selector(taskFailed:) withObject:task waitUntilDone:NO];
}

-(void) urlTaskSuccessful:(IkhoyoURLTask*) task {
    [self performSelectorOnMainThread:@selector(taskDone:) withObject:task waitUntilDone:NO];    
}

- (IkhoyoTask*) getTask:(IkhoyoURLTask*) urlTask {
    for (int i=0;i<[self.tasks count];i++) {
        IkhoyoTask* task = [self.tasks objectAtIndex:i];
        if (task.obj==urlTask)
            return task;
    }
    return nil;
}

- (void) taskFailed:(IkhoyoURLTask*) urlTask {
    IkhoyoTask* task = [self getTask:urlTask];
    task.task(urlTask);
    [task release];
}

- (void) taskDone:(IkhoyoURLTask*) urlTask {
    IkhoyoTask* task = [self getTask:urlTask];
    IkhoyoURLTaskLoad* taskLoad = (IkhoyoURLTaskLoad*) urlTask;
    task.task([self convertData:taskLoad.data]);
    [task release];
}

@end
