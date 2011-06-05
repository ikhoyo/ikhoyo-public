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
//  IkhoyoViewDatabase.h
//  ikhoyo-ui
//
//  Created by William Donahue on 5/24/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IkhoyoThread.h"

@class IkhoyoDatabase;
@interface IkhoyoStatement : NSObject {
	void* h;
	Class cls;
	NSMutableArray* rows;
	IkhoyoDatabase* database;
}
@property (nonatomic,retain) Class cls;
@property (nonatomic,retain) NSMutableArray* rows;
@property (nonatomic,retain) IkhoyoDatabase* database;

+ (NSDate*) toDate:(double) secs;
+ (double) fromDate:(NSDate*) date;

- (id) count;
- (Boolean) hasRowAtOffset:(NSUInteger) offset;
- (Boolean) hasRowsAtOffset:(NSUInteger) offset andLimit:(NSUInteger) limit;
	
@end

@interface IkhoyoDatabase : NSObject {
	void* h;
	NSString* path;
	IkhoyoThread* worker;
}
@property (nonatomic) void* h;
@property (nonatomic,retain) NSString* path;
@property (nonatomic,retain) IkhoyoThread* worker;

- (id) initWithPath:(NSString*)path;
- (id) initWithPath:(NSString*)path usingThread:(IkhoyoThread*) thread;

- (void) open:(IkhoyoBlock) block;
- (void) close:(IkhoyoBlock) block;
- (IkhoyoError*) sqliteError:(NSString*) msg;
- (void) count:(IkhoyoStatement*) stmt withBlock:(IkhoyoBlock) block;
- (void) exec:(IkhoyoStatement*) select withBlock:(IkhoyoBlock) block;
- (void) count:(NSString*) sql args:(NSArray*) args withBlock:(IkhoyoBlock) block;
- (void) rebind:(IkhoyoStatement*) stmt args:(NSArray*) args withBlock:(IkhoyoBlock) block;
- (void) prepare:(NSString*) sql args:(NSArray*) args usingClass:(NSString*) cls withBlock:(IkhoyoBlock) block;
- (void) select:(IkhoyoStatement*) select offset:(NSUInteger) offset limit:(NSUInteger) limit withBlock:(IkhoyoBlock) block;

@end
