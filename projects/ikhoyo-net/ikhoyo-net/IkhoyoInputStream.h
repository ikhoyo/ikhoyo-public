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
//  IkhoyoInputStream.h
//  ikhoyo-net
//
#import <Foundation/Foundation.h>

#undef IKHOYO_NSSTREAM_DELEGATE
#if (TARGET_OS_MAC && !TARGET_OS_IPHONE && (MAC_OS_X_VERSION_MAX_ALLOWED >= 1060)) || \
(TARGET_OS_IPHONE && (__IPHONE_OS_VERSION_MAX_ALLOWED >= 40000))
	#define IKHOYO_NSSTREAM_DELEGATE <NSStreamDelegate>
#else
	#define IKHOYO_NSSTREAM_DELEGATE
#endif

/*!
 ICSInputStream - Implements an array of NSInputStreams that look like a single input stream. Allows for
 very efficient streaming of data from multiple sources without having to copy the data to one NSData instance, 
 or to a temporary file. Used by the IkhoyoURLManager in the upload implementation.
 */
@interface IkhoyoInputStream : NSInputStream IKHOYO_NSSTREAM_DELEGATE {
	NSMutableArray* inputs;		/**< The NSInputStream array. */
	NSUInteger currentInput;	/**< The current NSInputStream index. */
	unsigned long long length;	/**< The total length of the input stream. Calculated as streams area added. */

	id delegate;				/**< Placeholder for the delegate used by NSInputStream subclasses. */
	NSInputStream* lastStream;	/**< The last input stream. Used by overridden NSInputStream methods. */
}
@property (nonatomic) unsigned long long length;
@property (nonatomic,retain) NSMutableArray* inputs;
@property (nonatomic,retain) NSInputStream* lastStream;

/*!
 Initialize the IkhoyoInputStream
 */
- (id) init;

/*!
 Add data to the input stream. Can either be an NSData instance, or an NSString that is the name of a file.
 */
- (void) add:(id) data;

@end
