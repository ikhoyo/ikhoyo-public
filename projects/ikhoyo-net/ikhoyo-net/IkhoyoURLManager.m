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
//  IkhoyoUrlManager.m
//  ikhoyo-net
//
#import "IkhoyoURLManager.h"
#import "IkhoyoInputStream.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface IkhoyoURLQueue : NSObject {
	NSUInteger running;
	NSUInteger maxRunning;
	NSMutableArray* queue;
}
@property (nonatomic) NSUInteger running;
@property (nonatomic) NSUInteger maxRunning;
@property (nonatomic,retain) NSMutableArray* queue;

@end

@implementation IkhoyoURLQueue
@synthesize queue;
@synthesize running;
@synthesize maxRunning;

- (void) dealloc {
	[queue release];
	[super dealloc];
}

- (id) initWithMax:(NSUInteger) max {
	if ((self=[super init])) {
		maxRunning = max;
		queue = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) addTask:(IkhoyoURLTask*) task {
	int idx = [self.queue count];
	for (int i=0;i<[self.queue count];i++) {
		IkhoyoURLTask* t = (IkhoyoURLTask*) [self.queue objectAtIndex:i];
		if (task.priority < t.priority) {
			idx = i;
			break;
		}
	}
	[self.queue insertObject:task atIndex:idx];
	if (running<maxRunning) {
		running++;
		[task start];
	}
}

- (void) removeTask:(IkhoyoURLTask*) task {
	running--;
	[queue removeObject:task];
	for (int i=0;i<[self.queue count]&&running<maxRunning;i++) {
		IkhoyoURLTask* task = [queue objectAtIndex:i];
		if (task.started==NO) {
			running++;
			[task start];
		}
	}
}

@end

@implementation IkhoyoURLTask
@synthesize url;
@synthesize error;
@synthesize request;
@synthesize manager;
@synthesize response;
@synthesize delegate;
@synthesize challenge;
@synthesize connection;

@synthesize length;
@synthesize useMain;
@synthesize priority;
@synthesize started;
@synthesize trusted;
@synthesize canceled;
@synthesize finished;
@synthesize upLength;
@synthesize downLength;
@synthesize upProgress;
@synthesize downProgress;

- (void) dealloc {
	[url release];
	[error release];
	[request release];
	[manager release];
	[delegate release];
	[response release];
	[connection release];
	[super dealloc];
}

- (id) init:(IkhoyoURLManager*) mgr with:(id) w delegate:(id) d priority:(NSUInteger) p useMainThread:(Boolean) mt {
	if ((self=[super init])) {
		useMain = mt;
		priority = p;
		started = NO;
		canceled = NO;
		finished = NO;
		manager = [mgr retain];
		if (d==nil) d = mgr.delegate;
		delegate = [d retain];

		if ([w isKindOfClass:[NSURL class]])
			url = [w retain];
		else
			request = [w retain];
	}
	return self;
}

- (Boolean) doSelector:(SEL) selector waitUntilDone:(Boolean) wait {
	if (delegate!=nil&&[delegate respondsToSelector:selector]) {
		if (self.useMain==YES)
			[delegate performSelectorOnMainThread:selector withObject:self waitUntilDone:wait];
		else
			[delegate performSelector:selector withObject:self];
		return YES;
	}
	return NO;
}

- (Boolean) asyncPerformSelector:(SEL) selector {
	return [self doSelector:selector waitUntilDone:NO];
}

- (Boolean) syncPerformSelector:(SEL) selector {
	return [self doSelector:selector waitUntilDone:YES];
}

- (Boolean) checkTrusted:(NSURLAuthenticationChallenge*) chall {
	self.trusted = NO;
	self.challenge = chall;
	[self syncPerformSelector:@selector(isTrusted:)];
	return self.trusted;
}

- (Boolean) doAuthenticationChallenge:(NSURLAuthenticationChallenge*) chall {
	self.challenge = chall;
	return [self syncPerformSelector:@selector(authenticationChallenge:)] ? YES : NO;
}

- (void) notifyProgress {
	[self asyncPerformSelector:@selector(urlTaskProgress:)];
}

- (void) finish {
	if (self.error==nil)
		[delegate urlTaskSuccessful:self];
	else
		[delegate urlTaskFailed:self];
}

- (void) setFinished {
	self.finished = YES;
	if (delegate!=nil) {
		if (self.useMain==YES)
			[self performSelectorOnMainThread:@selector(finish) withObject:nil waitUntilDone:NO];
		else
			[self finish];
	}
	IkhoyoURLQueue* queue = [manager getQueue:self];
	[queue removeTask:self];
}
 
- (void) start {
	self.started = YES;
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void) cancel {
	[connection cancel];
	self.canceled = YES;
	[self setFinished];
}

- (void) connection:(NSURLConnection*)c didReceiveResponse:(NSURLResponse*) r {
	self.response = r;
	self.upLength = 0;
	self.downLength = 0;
	self.upProgress = 0;
	self.downProgress = 0;
	self.length = [self.response expectedContentLength];
	if ([r isKindOfClass:[NSHTTPURLResponse class]]) {
		int statusCode = [(NSHTTPURLResponse*) r statusCode];
		if (statusCode >= 400) {
			[c cancel];
			NSDictionary *errorInfo = [NSDictionary 
									   dictionaryWithObject:[NSString stringWithFormat:@"Server returned status code %d",statusCode]
									   forKey:NSLocalizedDescriptionKey];
			NSError *statusError = [NSError errorWithDomain:@"HTTP Error" code:statusCode userInfo:errorInfo];
			[self connection:c didFailWithError:statusError];
		}
		
	}
}

- (void) connection:(NSURLConnection*)c didReceiveData:(NSData*)rdata {
	downLength += [rdata length];
	self.downProgress = self.length==NSURLResponseUnknownLength ? 0 : (downLength / self.length) * 100;
	[self notifyProgress];
}

- (void) connection:(NSURLConnection*)c didFailWithError:(NSError*) e {
	self.error = e;
	[self setFinished];
}

- (void) connectionDidFinishLoading:(NSURLConnection*)c {
	[self setFinished];
}

- (NSURLRequest*) connection:(NSURLConnection*)c willSendRequest:(NSURLRequest*) req redirectResponse:(NSURLResponse*) response {
	return req;
}

- (void) connection:(NSURLConnection*) c didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	upLength = totalBytesWritten;
	self.upProgress = (totalBytesWritten/totalBytesExpectedToWrite) * 100;
	[self notifyProgress];
}

- (BOOL) connection:(NSURLConnection*) c canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace*) space {
	return [space.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void) connection:(NSURLConnection*) c didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*) chall {
	if ([chall.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
		if ([self checkTrusted:chall])
			[chall.sender useCredential:[NSURLCredential credentialForTrust:chall.protectionSpace.serverTrust] forAuthenticationChallenge:chall];
		else
			[chall.sender continueWithoutCredentialForAuthenticationChallenge:chall];
	} else if (![self doAuthenticationChallenge:chall])
		[chall.sender continueWithoutCredentialForAuthenticationChallenge:chall];
}


@end

@implementation IkhoyoURLTaskLoad
@synthesize data;

- (void) dealloc {
	[data release];
	[super dealloc];
}

- (id) init:(IkhoyoURLManager*) mgr with:(id) w delegate:(id) d priority:(NSUInteger) p useMainThread:(Boolean) mt {
	if ((self=[super init:mgr with:w delegate:d priority:p useMainThread:mt])) {
	}
	return self;
}

- (void) start {
	data = [[NSMutableData data] retain];
	if (self.request==nil)
		request = [[NSMutableURLRequest alloc] initWithURL:url];
	[super start];
}
			 
- (void) connection:(NSURLConnection*)c didReceiveResponse:(NSURLResponse*) r {
	[data setLength:0];
	[super connection:c didReceiveResponse:r];
}

- (void) connection:(NSURLConnection*)c didReceiveData:(NSData*)rdata {
	[data appendData:rdata];
	[super connection:c didReceiveData:rdata];
}

@end

@implementation IkhoyoURLTaskDownload
@synthesize path;

- (void) dealloc {
	[path release];
	[super dealloc];
}

- (id) init:(IkhoyoURLManager*) mgr with:(id) w delegate:(id) d priority:(NSUInteger) p useMainThread:(Boolean) mt path:(NSString*) pth {
	if ((self=[super init:mgr with:w delegate:d priority:p useMainThread:mt])) {
		path = [pth retain];
	}
	return self;
}

- (void) start {
	if (self.request==nil)
		request = [[NSMutableURLRequest alloc] initWithURL:url];
	[super start];
}

- (void) connection:(NSURLConnection*)c didReceiveResponse:(NSURLResponse*) r {
	if ([self.manager.fileManager fileExistsAtPath:self.path]) {
		NSError* fileError;
		[self.manager.fileManager removeItemAtPath:self.path error:&fileError];
	}
	[super connection:c didReceiveResponse:r];
}

- (void) connection:(NSURLConnection*)c didReceiveData:(NSData*)rdata {
	if ([self.manager.fileManager fileExistsAtPath:self.path]) {
		NSFileHandle* h = [NSFileHandle fileHandleForUpdatingAtPath:self.path];
		[h seekToEndOfFile];
		[h writeData:rdata];
		[h closeFile];
	} else {
		[manager.fileManager createFileAtPath:self.path contents:rdata attributes:nil];
	}
	[super connection:c didReceiveData:rdata];
}

@end

@implementation IkhoyoURLTaskPost
@synthesize form;
@synthesize data;

- (void) dealloc {
	[data release];
	[form release];
	[super dealloc];
}

- (id) init:(IkhoyoURLManager*) mgr with:(id) w delegate:(id) d priority:(NSUInteger) p useMainThread:(Boolean) mt postData:(NSDictionary*) pd {
	if ((self=[super init:mgr with:w delegate:d priority:p useMainThread:mt])) {
		form = [pd retain];
	}
	return self;
}

- (void) start {
	data = [[NSMutableData data] retain];
	if (self.request==nil) {
		NSMutableURLRequest* req = [[NSMutableURLRequest alloc] initWithURL:url];
		[req setHTTPMethod:@"POST"];
		[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; 
		
		NSString* key;
		NSMutableString* fd = [NSMutableString string];
		NSEnumerator* e = [self.form keyEnumerator];
		while ((key=[e nextObject])) {
			[fd appendString:@"&"];
			[fd appendString:key];
			[fd appendString:@"="];
			NSString* value = [self.form objectForKey:key];
			[fd appendString: [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
		NSData* d = [fd dataUsingEncoding:NSUTF8StringEncoding];
		[req setHTTPBody:d];
		[req setValue:[NSString stringWithFormat:@"%d",[d length]] forHTTPHeaderField:@"Content-Length"];
		request = req;
	}
	[super start];
}

- (void) connection:(NSURLConnection*)c didReceiveResponse:(NSURLResponse*) r {
	[data setLength:0];
	[super connection:c didReceiveResponse:r];
}

- (void) connection:(NSURLConnection*)c didReceiveData:(NSData*)rdata {
	[data appendData:rdata];
	[super connection:c didReceiveData:rdata];
}

@end

@implementation IkhoyoURLTaskUpload
@synthesize data;
@synthesize boundary;
@synthesize postData;

- (void) dealloc {
	[data release];
	[boundary release];
	[postData release];
	[super dealloc];
}

- (id) init:(IkhoyoURLManager*) mgr with:(id) w delegate:(id) d priority:(NSUInteger) p useMainThread:(Boolean) mt postData:(IkhoyoURLPostData*) pd boundary:(NSString*) bnd {
	if ((self=[super init:mgr with:w delegate:d priority:p useMainThread:mt])) {
		postData = [pd retain];
		if (bnd==nil)
			boundary = [[NSString alloc] initWithString:@"--!@--&$--%#--"];
		else
			boundary = [bnd retain];
	}
	return self;
}

- (void) start {
	data = [[NSMutableData data] retain];
	if (self.request==nil) {
		NSMutableURLRequest* req = [[NSMutableURLRequest alloc] initWithURL:url];
		request = req;

		// Content type for full request
		[req setHTTPMethod:@"POST"];
		NSString* charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
		[req setValue:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, self.boundary] forHTTPHeaderField:@"Content-Type"];
		
		IkhoyoInputStream* istr = [[[IkhoyoInputStream alloc] init] autorelease];
		// Fields go first in one NSData chunk
		NSMutableData* fields = [NSMutableData dataWithCapacity:4096];
		[fields appendData: [[NSString stringWithFormat:@"--%@",self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		for (NSDictionary* field in self.postData.fields) {
			NSDictionary* dict = [self.postData.fields objectForKey:field];
			[fields appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[fields appendData:
			 [[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", field] dataUsingEncoding:NSUTF8StringEncoding]];
			id value = [dict objectForKey:@"value"];
			if ([value isKindOfClass:[NSString class]])
				[fields appendData:[value dataUsingEncoding:NSUTF8StringEncoding]];
			else
				[fields appendData:value];
			[fields appendData:[[NSString stringWithFormat:@"\r\n--%@",self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		[istr add:fields];
		
		// Files go next, split into multiple NSData chunks
		for (NSDictionary* field in self.postData.files) {
			NSDictionary* dict = [self.postData.files objectForKey:field];
			id fdata = [dict objectForKey:@"data"];
			NSString* filename = [dict objectForKey:@"filename"];
			NSString* contentType = [dict objectForKey:@"contentType"];

			NSMutableData* head = [NSMutableData dataWithCapacity:1024];
			[head appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[head appendData:
			 [[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",field,filename]
			  dataUsingEncoding:NSUTF8StringEncoding]];
			[head appendData:
			 [[NSString stringWithFormat: @"Content-Type: %@\r\n\r\n",contentType]
			  dataUsingEncoding:NSUTF8StringEncoding]];
			
			[istr add:head];
			[istr add:fdata];
			[istr add:[[NSString stringWithFormat:@"\r\n--%@",self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		[istr add:[[NSString stringWithFormat:@"--\r\n",self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		[req setHTTPBodyStream:istr];
		[req setValue:[NSString stringWithFormat:@"%d",[istr length]] forHTTPHeaderField:@"Content-Length"];
	}
	[super start];
}

- (void) connection:(NSURLConnection*)c didReceiveResponse:(NSURLResponse*) r {
	[data setLength:0];
	[super connection:c didReceiveResponse:r];
}

- (void) connection:(NSURLConnection*)c didReceiveData:(NSData*)rdata {
	[data appendData:rdata];
	[super connection:c didReceiveData:rdata];
}

@end

@implementation IkhoyoURLManager
@synthesize tasks;
@synthesize worker;
@synthesize delegate;
@synthesize fileManager;
@synthesize tasksPriority;

- (void) dealloc {
	[tasks release];
	[worker release];
	[fileManager release];
	[tasksPriority release];
	[super dealloc];
}

- (IkhoyoURLManager*) init {
	return [self initWithDelegate:nil];
}

- (IkhoyoURLManager*) initWithDelegate:(id) d {
	NSUInteger maxRunning[] = {5,1};
	return [self init:maxRunning withDelegate:d];
}

- (IkhoyoURLManager*) init:(NSUInteger[])maxRunning withDelegate:(id) d {
	if ((self=[super init])) {
		delegate = [d retain];
		fileManager = [[NSFileManager alloc] init];
		tasks = [[IkhoyoURLQueue alloc] initWithMax:maxRunning[0]];
		tasksPriority = [[IkhoyoURLQueue alloc] initWithMax:maxRunning[1]];
		worker = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
		[worker start];
	}
	return self;
}

- (void) terminate {
	[worker cancel];
}

- (void) run {
	[worker setThreadPriority:0];
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
	while(![worker isCancelled]) {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		[pool drain];
	}
	[pool drain];
}

- (IkhoyoURLQueue*) getQueue:(IkhoyoURLTask*) task {
	return task.priority==0 ? task.manager.tasks : task.manager.tasksPriority;
}

- (void) queue:(IkhoyoURLTask*) task {
	IkhoyoURLQueue* queue = [self getQueue:task];
	[queue addTask:task];
}

- (id) post:(id) urlOrRequest {
	return [self post:urlOrRequest form:nil];
}

- (id) post:(id) urlOrRequest form:(NSDictionary*) d {
	return [self post:urlOrRequest form:d delegate:nil];
}

- (id) post:(id) urlOrRequest form:(NSDictionary*) d delegate:(id) del {
	return [self post:urlOrRequest form:d delegate:del withPriority:0];
}

- (id) post:(id) urlOrRequest form:(NSDictionary*) d delegate:(id) del withPriority:(NSUInteger) priority {
	return [self post:urlOrRequest form:d delegate:del withPriority:priority useMainThread:YES];
}

- (id) post:(id) urlOrRequest form:(NSDictionary*) d delegate:(id) del withPriority:(NSUInteger) priority useMainThread:(Boolean) mt {
	IkhoyoURLTask* task = [[IkhoyoURLTaskPost alloc] init:self with:urlOrRequest delegate:del priority:priority useMainThread:mt postData:d];
	[self performSelector:@selector(queue:) onThread:worker withObject:task waitUntilDone:NO];
	return task;
}

- (id) upload:(id) urlOrRequest {
	return [self upload:urlOrRequest postData:nil];
}

- (id) upload:(id) urlOrRequest postData:(IkhoyoURLPostData*) d {
	return [self upload:urlOrRequest postData:d delegate:nil];
}

- (id) upload:(id) urlOrRequest postData:(IkhoyoURLPostData*) d delegate:(id) del {
	return [self upload:urlOrRequest postData:d delegate:del withPriority:0];
}

- (id) upload:(id) urlOrRequest postData:(IkhoyoURLPostData*) d delegate:(id) del withPriority:(NSUInteger) priority {
	return [self upload:urlOrRequest postData:d delegate:del withPriority:priority useMainThread:YES boundary:nil];
}

- (id) upload:(id) urlOrRequest postData:(IkhoyoURLPostData*) d delegate:(id) del withPriority:(NSUInteger) priority useMainThread:(Boolean) mt boundary:(NSString*) bnd {
	IkhoyoURLTask* task = [[IkhoyoURLTaskUpload alloc] init:self with:urlOrRequest delegate:del priority:priority useMainThread:mt postData:d boundary:bnd];
	[self performSelector:@selector(queue:) onThread:worker withObject:task waitUntilDone:NO];
	return task;
}

- (id) load:(id) urlOrRequest {
	return [self load:urlOrRequest delegate:nil];
}

- (id) load:(id) urlOrRequest delegate:(id) del {
	return [self load:urlOrRequest delegate:del withPriority:0];
}

- (id) load:(id) urlOrRequest delegate:(id) del withPriority:(NSUInteger) priority {
	return [self load:urlOrRequest delegate:del withPriority:priority useMainThread:YES];
}

- (id) load:(id) urlOrRequest delegate:(id) del withPriority:(NSUInteger) priority useMainThread:(Boolean) mt {
	IkhoyoURLTask* task = [[IkhoyoURLTaskLoad alloc] init:self with:urlOrRequest delegate:del priority:priority useMainThread:mt];
	[self performSelector:@selector(queue:) onThread:worker withObject:task waitUntilDone:NO];
	return task;
}

- (id) download:(id) urlOrRequest toFile:(NSString*) p {
	return [self download:urlOrRequest toFile:p delegate:nil];
}

- (id) download:(id) urlOrRequest toFile:(NSString*) p delegate:(id) del {
	return [self download:urlOrRequest toFile:p delegate:del withPriority:0];
}

- (id) download:(id) urlOrRequest toFile:(NSString*) p delegate:(id) del withPriority:(NSUInteger) priority {
	return [self download:urlOrRequest toFile:p delegate:del withPriority:priority useMainThread:YES];
}

- (id) download:(id) urlOrRequest toFile:(NSString*) p delegate:(id) del withPriority:(NSUInteger) priority useMainThread:(Boolean) mt {
	IkhoyoURLTask* task = [[IkhoyoURLTaskDownload alloc] init:self with:urlOrRequest delegate:del priority:priority useMainThread:mt path:p];
	[self performSelector:@selector(queue:) onThread:worker withObject:task waitUntilDone:NO];
	return task;
}

@end

@implementation IkhoyoURLPostData
@synthesize files;
@synthesize fields;

- (void) dealloc {
	[files release];
	[fields release];
	[super dealloc];
}

- (id) init {
	if ((self=[super init])) {
		files = [[NSMutableDictionary alloc] init];
		fields = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void) addField:(NSString*) field withValue:(id) value {
	NSArray* keys = [NSArray arrayWithObjects:@"value",nil];
	NSArray* objects = [NSArray arrayWithObjects:value,nil];
	NSDictionary* parms = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	[self.fields setObject:parms forKey:field];
}

- (void) addFileField:(NSString*) field withData:(id) data {
	[self addFileField:field withData:data withContentType:nil];
}

- (void) addFileField:(NSString*) field withData:(id) data withContentType:(NSString*) contentType {
	[self addFileField:field withData:data withContentType:contentType withFilename:nil];
}

- (void) addFileField:(NSString*) field withData:(id) data withContentType:(NSString*) contentType withFilename:(NSString*) filename {
	NSArray* keys = [NSArray arrayWithObjects:@"data",@"contentType",@"filename",nil];
	if ([data isKindOfClass:[NSString class]]) {
		if (filename==nil)
			filename = [(NSString*) data lastPathComponent];
		if (contentType==nil) {
			CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,(CFStringRef)[filename pathExtension],NULL);
			CFStringRef mime = UTTypeCopyPreferredTagWithClass(uti,kUTTagClassMIMEType);
			CFRelease(uti);
			contentType = mime ? NSMakeCollectable([(NSString*) mime autorelease]) : @"application/octet-stream";
		}
	}
	if (filename==nil||contentType==nil)
		[NSException raise:@"IkhoyoPostData" format:@"contentType and filename are required when adding file fields"];
	NSArray* objects = [NSArray arrayWithObjects:data,contentType,filename,nil];
	NSDictionary* parms = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	[self.files setObject:parms forKey:field];
}

@end
