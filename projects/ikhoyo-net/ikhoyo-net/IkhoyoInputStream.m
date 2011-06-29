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
//  IkhoyoInputStream.m
//  ikhoyo-net
//

#import "IkhoyoInputStream.h"

@implementation IkhoyoInputStream
@synthesize inputs;
@synthesize length;
@synthesize lastStream;

- (void) dealloc {
	[inputs release];
	[lastStream release];
	[super dealloc];
}

- (id) init {
	if ((self=[super init])) {
		length = 0;
		inputs = [[NSMutableArray alloc] init];
		[self setDelegate:self];
	}
	return self;
}

- (id) addData:(NSData*) data {
	NSInputStream* istr = [[NSInputStream alloc] initWithData:data];
	length += [data length];
	return istr;
}

- (id) addFile:(NSString*) file {
	NSInputStream* istr = [[NSInputStream alloc] initWithFileAtPath:file];
	NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:NULL];
	length += [[attrs valueForKey:NSFileSize] unsignedLongLongValue]; 
	return istr;
}

- (void) add:(id) data {
	NSInputStream* input = [data isKindOfClass:[NSData class]] ? [self addData:data] : [self addFile:data];
	[self.inputs addObject:input];
	self.lastStream = input;
	[input release];
}

- (BOOL) hasBytesAvailable {
	return [lastStream hasBytesAvailable];
}

- (BOOL) getBuffer:(uint8_t**) buffer length:(NSUInteger*)len {
	return NO;
}

- (NSInteger) read:(uint8_t*) buffer maxLength:(NSUInteger)len {
	NSInteger total = 0;
	while (total<len&&currentInput<[self.inputs count]) {
		NSInputStream* input = [inputs objectAtIndex:currentInput];
		NSInteger read = [input read:buffer+total maxLength:len-total];
		if (read>0)	total += read;
		if (read<=0) currentInput++;
	}
	return total;
}

- (NSStreamStatus) streamStatus {
	return [lastStream streamStatus];
}

- (NSError*) streamError {
	return [lastStream streamError];
}

- (void) open {
	for (NSInputStream* input in inputs)
		[input open];
}

- (void) close {
	for (NSInputStream* input in inputs)
		[input close];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	if (delegate!=self) {
		[delegate stream:self handleEvent:streamEvent];
	}
}

- (id) delegate {
	return delegate;
}

- (id) propertyForKey:(NSString*)key {
	return [lastStream propertyForKey:key];
}

- (BOOL) setProperty:(id)property forKey:(NSString*)key {
	return [lastStream setProperty:property forKey:key];
}

- (void) scheduleInRunLoop:(NSRunLoop*)runLoop forMode:(NSString*)mode {
	[lastStream scheduleInRunLoop:runLoop forMode:mode];
}

- (void) removeFromRunLoop:(NSRunLoop*)runLoop forMode:(NSString*)mode {
	[lastStream removeFromRunLoop:runLoop forMode:mode];
}

+ (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
	return [NSInputStream methodSignatureForSelector:selector];
}

+ (void)forwardInvocation:(NSInvocation*)invocation {
	[invocation invokeWithTarget:[NSInputStream class]];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [lastStream methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	[anInvocation invokeWithTarget:lastStream];
}

- (void) setDelegate:(id) del {
	if (delegate==nil) {
		delegate = self;
		[lastStream setDelegate:nil];
	} else {
		delegate = del;
		[lastStream setDelegate:self];
	}
}

@end
