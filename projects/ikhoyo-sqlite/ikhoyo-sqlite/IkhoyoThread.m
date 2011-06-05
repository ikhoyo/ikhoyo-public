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
//  IkhoyoThread.m
//  ikhoyo-sqlite
//
//  Created by William Donahue on 5/24/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import "IkhoyoThread.h"

@implementation IkhoyoError
@synthesize msg;

- (void)dealloc {
	[msg release];
	msg = nil;
    [super dealloc];
}

- (id) initWithFormat:(NSString*) fmt, ... {
    self = [super init];
    if (self) {
        va_list args;
        va_start(args,fmt);
		msg = [[NSString alloc] initWithFormat:fmt arguments:args];
        va_end(args);
    }
    return self;
}

@end


@implementation IkhoyoTask
@synthesize obj;
@synthesize main;
@synthesize task;

- (void) dealloc {
	[task release];
	[super dealloc];
}

@end

@implementation IkhoyoThread
@synthesize worker;

- (void) dealloc {
	[worker release];
	worker = nil;
	[super dealloc];
}

- (void) performBlock:(IkhoyoBlock)task withObject:(id) obj onMainThread:(Boolean) main {
	IkhoyoTask* tb = [[[IkhoyoTask alloc] init] autorelease];
	tb.obj = obj;
	tb.main = main;
	tb.task = task;
	NSThread* thread = main ? [NSThread mainThread] : self.worker;
	[self performSelector:@selector(startTask:) onThread:thread withObject:tb waitUntilDone:NO];
}

- (void) performBlock:(IkhoyoBlock)task {
	[self performBlock:task withObject:nil];
}

- (void) performBlockOnMainThread:(IkhoyoBlock)task {
	[self performBlockOnMainThread:task withObject:nil];
}

- (void) performBlock:(IkhoyoBlock)task withObject:(id) obj {
	[self performBlock:task withObject:obj onMainThread:NO];
}

- (void) performBlockOnMainThread:(IkhoyoBlock)task withObject:(id) obj {
	[self performBlock:task withObject:obj onMainThread:YES];
}

- (void) startTask:(IkhoyoTask*) tb {
	tb.task(tb.obj);
}

- (void) start {
	self.worker = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
	[self.worker start];
}

- (void) run {
	[self.worker setThreadPriority:0];
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
	while(![self.worker isCancelled]) {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		[pool drain];
	}
	[pool drain];
}

@end
