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
//  IkhoyoThread.h
//  ikhoyo-sqlite
//
//  Created by William Donahue on 5/24/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IkhoyoError : NSObject {
	NSString* msg;
}
@property (nonatomic,retain) NSString* msg;

- (id) initWithFormat:(NSString*) fmt, ...;

@end


typedef void (^IkhoyoBlock)(id obj);

@interface IkhoyoTask : NSObject {
	id obj;
	Boolean main;
	IkhoyoBlock task;
}
@property (nonatomic) Boolean main;
@property (nonatomic,retain) id obj;
@property (nonatomic,copy) IkhoyoBlock task;
@end

@interface IkhoyoThread : NSObject {
	NSThread* worker;
}
@property (nonatomic,retain) NSThread* worker;


- (void) start;
- (void) performBlock:(IkhoyoBlock)task;
- (void) performBlockOnMainThread:(IkhoyoBlock)task;
- (void) performBlock:(IkhoyoBlock)task withObject:(id)obj;
- (void) performBlockOnMainThread:(IkhoyoBlock)task withObject:(id)obj;

@end
