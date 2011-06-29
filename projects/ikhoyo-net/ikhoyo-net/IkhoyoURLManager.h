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
//  IkhoyoURLManager.h
//  ikhoyo-net
//
#import <Foundation/Foundation.h>

@class IkhoyoURLTask;
@class IkhoyoURLQueue;
@class IkhoyoURLPostData;

/*!
 @mainpage Ikhoyo URL Manager
 The IkhoyoURLManager provides a management wrapper around NSURLConnection. IkhoyoURLManager is much easier to use than 
 NSURLConnection, and provides many additional features, including upload and download throttling, priority queueing 
 of requests, and simplified handling of requests requiring security (basic and certificate based).
 
 There are simple requests for most common cases, such as downloading data to a buffer or file, uploading data, and
 submitting forms. The IkhoyoURLManagerDelegate can be specified once on IkhoyoURLManager, or on each individual request, and
 you can be notified of requests status either through the delegate, or by observing state boolean variables that exist in 
 IkhoyoURLTask.
 
 IkhoyoURLManager will work in either UIKit based iPhone/iPad applications, or in Cocoa based applications. It works well
 in multithreaded environments, and requests can be issued from any thread. Delegate callbacks are normally called on the
 main thread (which is typically what you want in a UIKit based application), but this can be overridden.
 
 IkhoyoURLManager supplies two priority queues for request processing.
 
 1. Fast Queue. This queue is usually used for requests returning small amounts of data (less than 1M). This queue will 
 issue a configurable number of parallel requests (default is 5), so that you can achieve good throughput for simultaneous 
 requests. Requests are processed in FIFO order on the fast queue. 
 
 2. The Slow Queue. This queue will also issue a configurable number of parallel requests (default is 1), and is typically 
 used for requests returning large amounts of data. Requests are processed in priority order, where priority is an integer
 passed in when the request is made.
 */

/*!
 IkhoyoURLManager - Instantiate one IkhoyoURLManager per application. See @ref index for more information. 
 */

@interface IkhoyoURLManager : NSObject {
	id delegate;				/**< Delegate used for notifications */
	NSThread* worker;			/**< Worker thread used for internal processing */
	IkhoyoURLQueue* tasks;			/**< Fast queue */
	IkhoyoURLQueue* tasksPriority;	/**< Slow queue */
	NSFileManager* fileManager;	/**< NSFileManager used for internal processing */
}
@property (nonatomic,retain) id delegate;
@property (nonatomic,retain) NSThread* worker;
@property (nonatomic,retain) IkhoyoURLQueue* tasks;
@property (nonatomic,retain) IkhoyoURLQueue* tasksPriority;
@property (nonatomic,retain) NSFileManager* fileManager;

/*!
 Terminate the IkhoyoURLManager. All currently executing requests are cancelled.
 */
- (void) terminate;

//@{
/*!
 Inintialize the IkhoyoURLManager.
 @param init A two element array containing the maximum number of parallel requests to issue for each queue. The default is
 {5,1).
 @param delegate: An object obeying the IkhoyoURLManagerDelegate protocol. The default is nil, in which case delegate must be
 passed in the individual requests.
 */
- (IkhoyoURLManager*) init;
- (IkhoyoURLManager*) initWithDelegate:(id) delegate;
- (IkhoyoURLManager*) init:(NSUInteger[])max withDelegate:(id) delegate;
//@}

//@{
/*!
 Post a form. Data is posted using mime application/x-www-form-urlencoded.
 
 There are several related post functions, each more specialized. Normally, you only need to pass in an NSURL and
 an NSDictionary with the post data, but the other parameters are there for more specialized needs.  
 
 The single parameter function is normally not used, but is there for needs where one of the more specialized
 versions of post are not sufficient. In this case, an NSURLRequest is passed as the only parameter.

 @param urlOrRequest An NSURLRequest or NSURL instance. Normally, an NSURL is passed in.
 @param form An NSDictionary containing the form fields. Each field is urlencoded before adding it to the post data. Only string data is accepted.
 @param delegate The delegate which uses the IkhoyoURLManagerDelegate protocol. nil will use the delegate passed to the
 IkhoyoURLManager. Default is nil.
 @param withPriority The priority of the request. 0 indicates that this will run on the fast queue. Tasks will be run in the FIFO order on the 
 fast queue. >0 indicates the priority to assign the task for the slow queue. Tasks will be run in priority order on the slow queue. The
 default priority is 0.
 @param useMainThread Set to YES if you want the delegate callbacks to run on the main thread. If NO, the callbacks are run on the 
 same thread that invoked the request. The default value is YES.
 */

- (id) post:(id) urlOrRequest;
- (id) post:(id) urlOrRequest form:(NSDictionary*) form;
- (id) post:(id) urlOrRequest form:(NSDictionary*) form delegate:(id) delegate;
- (id) post:(id) urlOrRequest form:(NSDictionary*) form delegate:(id) delegate withPriority:(NSUInteger) withPriority;
- (id) post:(id) urlOrRequest form:(NSDictionary*) form delegate:(id) delegate withPriority:(NSUInteger) withPriority useMainThread:(Boolean) useMainThread;
//@}

//@{
/*!
 Upload data. Data is uploaded using multipart/form-data. You need to populate an IkhoyoPostData class with the 
 data to pass to these requests.
 
 There are several related upload functions, each more specialized. Normally, you only need to pass in 
 an IkhoyoURLPostData, but the other parameters are there for more specialized needs.  
 
 The single parameter function is normally not used, but is there for needs where one of the more specialized
 versions of upload are not sufficient. In this case, an NSURLRequest is passed as the only parameter.
 
 @param urlOrRequest An NSURLRequest or NSURL instance. Normally, an NSURL is passed in.
 @param postData An instance of IkhoyoURLPostData.
 @param delegate The delegate which uses the IkhoyoURLManagerDelegate protocol. nil will use the delegate passed to the
 IkhoyoURLManager. Default is nil.
 @param withPriority The priority of the request. 0 indicates that this will run on the fast queue. Tasks will be run in the FIFO order on the 
 fast queue. >0 indicates the priority to assign the task for the slow queue. Tasks will be run in priority order on the slow queue. The
 default priority is 0.
 @param useMainThread Set to YES if you want the delegate callbacks to run on the main thread. If NO, the callbacks are run on the 
 same thread that invoked the request. The default value is YES.
 @param boundary The boundary string for multi-part form data requests. The default is usually sufficient, but this may be needed in rare
 cases if the data contains the default boundary string.
 */
- (id) upload:(id) urlOrRequest;
- (id) upload:(id) urlOrRequest postData:(IkhoyoURLPostData*) postData;
- (id) upload:(id) urlOrRequest postData:(IkhoyoURLPostData*) postData delegate:(id) delegate;
- (id) upload:(id) urlOrRequest postData:(IkhoyoURLPostData*) postData delegate:(id) delegate withPriority:(NSUInteger) withPriority;
- (id) upload:(id) urlOrRequest postData:(IkhoyoURLPostData*) postData delegate:(id) delegate withPriority:(NSUInteger) withPriority  useMainThread:(Boolean) useMainThread boundary:(NSString*) boundary;
//@}

//@{
/*!
 Load data. There are several related load functions, each more specialized. Normally, you only need to pass in an NSURL, 
 but the other parameters are there for more specialized needs.  
 
 The single parameter function is normally not used, but is there for needs where one of the more specialized
 versions of load are not sufficient. In this case, an NSURLRequest is passed as the only parameter.
 
 @param urlOrRequest An NSURLRequest or NSURL instance. Normally, an NSURL is passed in.
 @param delegate The delegate which uses the IkhoyoURLManagerDelegate protocol. nil will use the delegate passed to the
 IkhoyoURLManager. Default is nil.
 @param withPriority The priority of the request. 0 indicates that this will run on the fast queue. Tasks will be run in the FIFO order on the 
 fast queue. >0 indicates the priority to assign the task for the slow queue. Tasks will be run in priority order on the slow queue. The
 default priority is 0.
 @param useMainThread Set to YES if you want the delegate callbacks to run on the main thread. If NO, the callbacks are run on the 
 same thread that invoked the request. The default value is YES.
 */
- (id) load:(id) urlOrRequest;
- (id) load:(id) urlOrRequest delegate:(id) delegate;
- (id) load:(id) urlOrRequest delegate:(id) delegate withPriority:(NSUInteger) withPriority;
- (id) load:(id) urlOrRequest delegate:(id) delegate withPriority:(NSUInteger) withPriority useMainThread:(Boolean) useMainThread;
//@}

//@{
/*!
 Download data to a file. There are several related download functions, each more specialized. Normally, you only need to pass in an NSURL 
 and a file name, but the other parameters are there for more specialized needs.  
 
 The single parameter function is normally not used, but is there for needs where one of the more specialized
 versions of load are not sufficient. In this case, an NSURLRequest is passed as the only parameter.
 
 @param urlOrRequest An NSURLRequest or NSURL instance. Normally, an NSURL is passed in.
 @param toFile A file name.
 @param delegate The delegate which uses the IkhoyoURLManagerDelegate protocol. nil will use the delegate passed to the
 IkhoyoURLManager. Default is nil.
 @param withPriority The priority of the request. 0 indicates that this will run on the fast queue. Tasks will be run in the FIFO order on the 
 fast queue. >0 indicates the priority to assign the task for the slow queue. Tasks will be run in priority order on the slow queue. The
 default priority is 0.
 @param useMainThread Set to YES if you want the delegate callbacks to run on the main thread. If NO, the callbacks are run on the 
 same thread that invoked the request. The default value is YES.
 */
- (id) download:(id) urlOrRequest toFile:(NSString*) toFile;
- (id) download:(id) urlOrRequest toFile:(NSString*) toFile delegate:(id) delegate;
- (id) download:(id) urlOrRequest toFile:(NSString*) toFile delegate:(id) delegate withPriority:(NSUInteger) withPriority;
- (id) download:(id) urlOrRequest toFile:(NSString*) toFile delegate:(id) delegate withPriority:(NSUInteger) withPriority useMainThread:(Boolean) useMainThread;
//@}

// Private
/*!
 @internal
 */
- (IkhoyoURLQueue*) getQueue:(IkhoyoURLTask*) task;

@end

/*!
 The ISCURLManagerDelegate is the protocol used to get information about running and completed tasks. 
 */
@protocol IkhoyoURLManagerDelegate
@required

/*!
 Called if the task failed. The error field in the IkhoyoURLTask contains the error information.
 @param task - The task data.
 */
-(void) urlTaskFailed:(IkhoyoURLTask*) task;

/*!
 Called if the task succeded.
 @param task - The task data.
 */
-(void) urlTaskSuccessful:(IkhoyoURLTask*) task;

@optional
/*!
 Called as data is received for load and download requests.
 @param task - The task data.
 */
-(void) urlTaskProgress:(IkhoyoURLTask*) task;

/*!
 Called when the connection:didReceiveAuthenticationChallenge: NSURLConnection delegate method is called for
 server trust authentication types. The challenge is in the challenge property. You must set task.trusted to 
 YES if you trust the host in the challenge and want to proceed with the request.
 @param task - The task data.
 */
-(void) isTrusted:(IkhoyoURLTask*) task;

/*!
 Called when the connection:didReceiveAuthenticationChallenge: NSURLConnection delegate method is called. The challenge 
 is in the challenge property. You must inform challenge.sender what to do with the authentication request. See 
 NSURLConnection for more information.
 @param task - The task data.
 */
-(void) authenticationChallenge:(IkhoyoURLTask*) task;
@end

/*!
 The IkhoyoURLTask interface contains the information on IkhoyoURLManager tasks. IkhoyoURLTask instances are passed on IkhoyoURLManagerDelegate
 protocol callbacks. There are several subclasses of IkhoyoURLTask, one for each request type (load, download, upload, and post).
 */
@interface IkhoyoURLTask : NSObject {
	NSURL* url;						/**< The url used for this request. */
	id delegate;					/**< The delegate used for this task. nil if the IkhoyoURLManager is used. */
	NSError* error;					/**< An NSError if the request failed. */
	NSURLRequest* request;			/**< The NSURLRequest used for this task. */
	IkhoyoURLManager* manager;			/**< The IkhoyoURLManager associated with this task. */
	NSURLResponse* response;		/**< The NSURLResponse returned by this task. */
	NSURLConnection* connection;	/**< Tne NSURLConnection used for this request. */
	NSURLAuthenticationChallenge* challenge; /**< Challenge for authentication delegate methods */
	
	int length;						/**< The length of the response for load and download requests. Can be NSURLResponseUnknownLength. */
	int upLength;					/**< The number of bytes currently sent. */
	int downLength;					/**< The number of bytes currently received. */
	Boolean trusted;				/**< Used as a return value from authentication delegate methods */
	Boolean useMain;				/**< The useMain value for this task. */
	Boolean started;				/**< Indicates if the request has started. Can be observed. */
	Boolean canceled;				/**< Indicates if the request was canceled. */
	Boolean finished;				/**< Indicates if the request finished. Set to YES when the task completes. Can be observed. */
	int upProgress;					/**< A percentage indicating the progress of an upload. */
	int downProgress;				/**< A percentage indicating the progress of a load or download request. Can be 0 if this cannot be determined. */
	NSUInteger priority;			/**< The priority for this task. */
}

@property (nonatomic) int length;
@property (nonatomic) int upLength;
@property (nonatomic) int downLength;
@property (nonatomic) Boolean useMain;
@property (nonatomic) int upProgress;
@property (nonatomic) Boolean trusted;
@property (nonatomic) int downProgress;
@property (nonatomic) NSUInteger priority;
@property (nonatomic,getter=isStarted) Boolean started;
@property (nonatomic,getter=isCanceled) Boolean canceled;
@property (nonatomic,getter=isFinished) Boolean finished;

@property (nonatomic,retain) NSURL* url;
@property (nonatomic,retain) NSError* error;
@property (nonatomic,retain) NSURLRequest* request;
@property (nonatomic,retain) IkhoyoURLManager* manager;
@property (nonatomic,retain) NSURLResponse* response;
@property (nonatomic,retain) NSURLConnection* connection;
@property (nonatomic,retain) id<IkhoyoURLManagerDelegate> delegate;
@property (nonatomic,retain) NSURLAuthenticationChallenge* challenge;
/*!
 @internal
 Start processing.
 */
- (void) start;

@end

/*!
 The IkhoyoURLTask subclass for load tasks.
 */
@interface IkhoyoURLTaskLoad : IkhoyoURLTask {
	NSMutableData* data;			/**< The data for load requests. */
}

@property (nonatomic,retain) NSMutableData* data;

/*!
 @internal
 */
- (id) init:(IkhoyoURLManager*) mgr with:(id) w delegate:(id) d priority:(NSUInteger) p useMainThread:(Boolean) useMainThread;

/*!
 @internal
 Start processing.
 */
- (void) start;

@end

/*!
 The IkhoyoURLTask subclass for download tasks.
 */
@interface IkhoyoURLTaskDownload : IkhoyoURLTask {
	NSString* path;					/**< The file name for download requests. */
}

@property (nonatomic,retain) NSString* path;

/*!
 @internal
 */
- (id) init:(IkhoyoURLManager*) mgr with:(id) w delegate:(id) d priority:(NSUInteger) p useMainThread:(Boolean) mt path:(NSString*) pth;

/*!
 @internal
 */
- (void) start;

@end

/*!
 The IkhoyoURLTask subclass for upload tasks.
 */
@interface IkhoyoURLTaskUpload : IkhoyoURLTask {
	NSString* boundary;			/**< Boundary string for multipart upload request. */
	NSMutableData* data;		/**< The data for load requests. */
	IkhoyoURLPostData* postData;	/**< The post data. */
}

@property (nonatomic,retain) NSString* boundary;
@property (nonatomic,retain) NSMutableData* data;
@property (nonatomic,retain) IkhoyoURLPostData* postData;

/*!
 @internal
 Start processing.
 */
- (id) init:(IkhoyoURLManager*) mgr with:(id) w delegate:(id) d priority:(NSUInteger) p useMainThread:(Boolean) mt postData:(IkhoyoURLPostData*) postData boundary:(NSString*) bnd;

/*!
 @internal
 Start processing.
 */
- (void) start;

@end

/*!
 The IkhoyoURLTask subclass for post tasks.
 */
@interface IkhoyoURLTaskPost : IkhoyoURLTask {
	NSDictionary* form;				/**< The form data for post requests. */
	NSMutableData* data;			/**< The data for load requests. */
}

@property (nonatomic,retain) NSDictionary* form;
@property (nonatomic,retain) NSMutableData* data;

/*!
 @internal
 */
- (id) init:(IkhoyoURLManager*) mgr with:(id) w delegate:(id) d priority:(NSUInteger) p useMainThread:(Boolean) mt postData:(NSDictionary*) pd;

/*!
 @internal
 */
- (void) start;

@end

/*!
 The ISCURLPostData is used to collect data for upload requests. An instance of this class is passed to the upload request after
 being populated by the end user.
 */
@interface IkhoyoURLPostData : NSObject {
	NSMutableDictionary* files;		/**< File field parameters */
	NSMutableDictionary* fields;	/**< Value field parameters */
}
@property (nonatomic,retain) NSMutableDictionary* files;
@property (nonatomic,retain) NSMutableDictionary* fields;

/*!
 Add a value field to the instance. Value fields can be NSString or NSData instances. 
 */
- (void) addField:(NSString*) field withValue:(id) value;

//@{
/*!
 Add a file field to the data. File fields must have data, a content type, and a file name. The data can be either an NSData instance,
 or an NSString, in which case it is interpreted as a file path. If you pass a file path, then we can deduce the filename and
 contentType from the file path, so the extra parameters are not required. If you pass an NSData instance, then you must also
 pass a contentType and filename.

 @param data - NSData or NSString. See above for an explanation.
 @param contentType - The mime content type for the data.
 @param filename - The filename passed to the upload request.
 */
- (void) addFileField:(NSString*) field withData:(id) data;
- (void) addFileField:(NSString*) field withData:(id) data withContentType:(NSString*) contentType;
- (void) addFileField:(NSString*) field withData:(id) data withContentType:(NSString*) contentType withFilename:(NSString*) filename;
//@{

@end
