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
//  IkhoyoDatabase.m
//  ikhoyo-sqlite
//
//  Created by William Donahue on 5/24/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import "IkhoyoDatabase.h"
#import "sqlite3.h"

@implementation IkhoyoStatement
@synthesize cls;
@synthesize rows;
@synthesize database;

- (sqlite3_stmt*) statement {
	return (sqlite3_stmt*) h;
}

- (void) dealloc {
	[rows release];
	[database release];
	sqlite3_finalize([self statement]);
	rows = nil;
	database = nil;
	h = 0;
	
    [super dealloc];
}

- (id) initWithStatement:(sqlite3_stmt*)stmt usingClass:(NSString*)lCls andDatabase:(IkhoyoDatabase*) db {
    self = [super init];
    if (self) {
		h = stmt;
		database = db;
		cls = lCls ? NSClassFromString(lCls) : nil;
		rows = [[NSMutableArray alloc] initWithCapacity:128];
    }
	return self;
}

- (void) reset {
	sqlite3_reset([self statement]);
	self.rows = [[NSMutableArray alloc] initWithCapacity:128];
}

- (id) bind:(id) obj toColumn:(NSUInteger) i {
	int rc = 0;
	sqlite3_stmt* statement = [self statement];
    if (!obj)
        rc = sqlite3_bind_null(statement,i);
    else if ([obj isKindOfClass:[NSData class]])
        rc = sqlite3_bind_blob(statement,i,[obj bytes],[obj length],SQLITE_STATIC);
    else if ([obj isKindOfClass:[NSNumber class]]) {
        if (strcmp([obj objCType],@encode(long long))== 0)
            rc = sqlite3_bind_int64(statement,i,[obj longLongValue]);
        else if (strcmp([obj objCType], @encode(double))==0)
            rc = sqlite3_bind_double(statement,i,[obj doubleValue]);
        else
            rc = sqlite3_bind_text(statement,i,[[obj description] UTF8String],-1,SQLITE_STATIC);
    }
    else
        rc = sqlite3_bind_text(statement,i,[[obj description] UTF8String],-1,SQLITE_STATIC);
	return rc==SQLITE_OK ? nil : [database sqliteError:@"sqlite bind failed"];
}

- (id) valueFromColumn:(NSUInteger) idx {
	id value = nil;
	sqlite3_stmt* statement = [self statement];
	switch (sqlite3_column_type([self statement],idx)) {
		case SQLITE_INTEGER: {
			value = [[NSNumber alloc] initWithLongLong:sqlite3_column_int64(statement,idx)];
			break;
		}
		case SQLITE_FLOAT: {
			value = [[NSNumber alloc] initWithDouble:sqlite3_column_double(statement,idx)];
			break;
		}
		case SQLITE_TEXT: {
			const char *txt = (const char*) sqlite3_column_text(statement,idx);
			if (!txt)	txt = "";
			value = [[NSString alloc] initWithUTF8String:txt];
			break;
		}
		case SQLITE_BLOB: {
			int size = sqlite3_column_bytes(statement,idx);
			NSMutableData *data = [[NSMutableData alloc] initWithLength:size];
			memcpy([data mutableBytes],sqlite3_column_blob(statement,idx),size);
			value = data;
			break;
		}
		case SQLITE_NULL: {
			value = nil;
		}
	}
	return value;
}

- (id) bind:(NSArray*) args reset:(Boolean) reset {
	if (reset) [self reset];
	
	id arg = nil;
	int count = sqlite3_bind_parameter_count([self statement]);
	if (count!=[args count])
		arg = [[[IkhoyoError alloc] initWithFormat:@"Wrong number of arguments, expected: %d, passed: %d",count,[args count]] autorelease];
	else {
		for (int i=0;i<count;i++) {
			id err = [self bind:[args objectAtIndex:i] toColumn:i];
			if (arg) arg = err;
		}
	}
	return arg;
}

- (id) bind:(NSArray*) args {
	return [self bind:args reset:YES];
}

- (Boolean) hasRowAtOffset:(NSUInteger) offset {
	return ([rows count]>offset) ? YES : NO;
}

- (Boolean) hasRowsAtOffset:(NSUInteger) offset andLimit:(NSUInteger) limit {
	return ([rows count]>offset+limit) ? YES : NO;
}

- (id) count {
	id ret = nil;
	sqlite3_stmt* statement = [self statement];
	int rc = sqlite3_step(statement);
	if (rc==SQLITE_ROW) {
		int count = sqlite3_column_int(statement,0);
		ret = [NSNumber numberWithInt:count];
	} else
		ret = [database sqliteError:@"Exec error"];
	return ret;
}

- (id) exec {
	sqlite3_stmt* statement = [self statement];
	int rc = sqlite3_step(statement);
	return (rc==SQLITE_DONE) ? nil : [database sqliteError:@"Exec error"];
}

- (id) offset:(NSUInteger) offset limit:(NSUInteger) limit {
	if ([self hasRowsAtOffset:offset andLimit:limit]) return nil;

	int end = offset + limit;
	sqlite3_stmt* statement = [self statement];
	for (int i=[self.rows count];i<=end;i++) {
		
		int rc = sqlite3_step(statement);
		if (rc==SQLITE_DONE) return nil;
		if (rc!=SQLITE_ROW) return [database sqliteError:@"Row fetch error"];

		id row = [[self.cls alloc] init];
		int count = sqlite3_column_count(statement);
		for (int idx=0;idx<count;idx++) {
            NSString* col = [NSString stringWithUTF8String:sqlite3_column_name(statement,idx)];
			id value = [self valueFromColumn:idx];
			[row setValue:value forKey:col];
			[value release];
		}
		[self.rows insertObject:row atIndex:i];
		[row release];
	}
	return nil;
}

+ (NSDate*) toDate:(double) secs {
	return [[NSDate alloc] initWithTimeIntervalSince1970:secs];
}

+ (double) fromDate:(NSDate*) date {
	return [date timeIntervalSince1970];
}

@end


@implementation IkhoyoDatabase
@synthesize h;
@synthesize path;
@synthesize worker;

- (sqlite3*) db {
	return (sqlite3*) self.h;
}

- (IkhoyoError*) sqliteError:(NSString*) msg {
	sqlite3* db = [self db];
	return [[[IkhoyoError alloc] initWithFormat:@"%@, code:%d, sqlite:%s",msg,sqlite3_errcode(db),sqlite3_errmsg(db)] autorelease];
}

- (id) closeInternal {
	int ret = sqlite3_close([self db]);
	return ret==SQLITE_OK ? nil : [self sqliteError:@"Error closing sqlite3 db"];
}

- (void) dealloc {
	[self closeInternal];
	
	[path release];
	[worker release];
	path = nil;
	worker = nil;
	
    [super dealloc];
}

- (id) initWithPath:(NSString*)lPath {
	return [self initWithPath:lPath usingThread:nil];
}

- (id) initWithPath:(NSString*)lPath usingThread:(IkhoyoThread*) thread {
    self = [super init];
    if (self) {
		h = 0;
		path = [lPath retain];
		worker = thread ? [thread retain] : [[IkhoyoThread alloc] init];
		if (!thread) [worker start];
    }
	return self;
}

- (void) open:(IkhoyoBlock) block {
	__block IkhoyoDatabase* me = self;
	[self.worker performBlock:^(id parm){
		sqlite3* db = 0;
		int ret = sqlite3_open([self.path fileSystemRepresentation],&db);
		id arg = ret==SQLITE_OK ? (id) me : (id) [self sqliteError:@"Error opening sqlite3 db"];
		h = db;
		[me.worker performBlockOnMainThread:block withObject:arg];
	}];
}

- (void) rebind:(IkhoyoStatement*) stmt args:(NSArray*) args withBlock:(IkhoyoBlock) block {
	__block IkhoyoDatabase* me = self;
	__block IkhoyoStatement* statement = stmt;
	[self.worker performBlock:^(id parm){
		id arg = [statement bind:args];
		[me.worker performBlockOnMainThread:block withObject:arg];
	}];
}

- (id) prepare:(NSString*) sql args:(NSArray*) args usingClass:(NSString*) cls {
	id arg = nil;
	sqlite3_stmt* statement = 0;
	int ret = sqlite3_prepare_v2([self db],[sql UTF8String],-1,&statement,0);
	if (ret==SQLITE_OK) {
		IkhoyoStatement* stmt = [[[IkhoyoStatement alloc] initWithStatement:statement usingClass:cls andDatabase:self] autorelease];
		arg = [stmt bind:args reset:NO];
		if (arg) [stmt release];
		else arg = stmt;
	} else
		arg = [self sqliteError:@"Error preparing statement"];
	return arg;
}

- (id) count:(NSString*) sql args:(NSArray*) args {
	id arg = nil;
	sqlite3_stmt* statement = 0;
	int ret = sqlite3_prepare_v2([self db],[sql UTF8String],-1,&statement,0);
	if (ret==SQLITE_OK) {
		IkhoyoStatement* stmt = [[[IkhoyoStatement alloc] initWithStatement:statement usingClass:nil andDatabase:self] autorelease];
		arg = [stmt bind:args reset:NO];
		if (!arg)
			arg = stmt;
	} else
		arg = [self sqliteError:@"Error preparing statement"];
	return arg;
}

- (void) prepare:(NSString*) sql args:(NSArray*) args usingClass:(NSString*) cls withBlock:(IkhoyoBlock) block {
	__block IkhoyoDatabase* me = self;
	[self.worker performBlock:^(id obj){
		id arg = [me prepare:sql args:args usingClass:cls];
		[me.worker performBlockOnMainThread:block withObject:arg];
	}];
}

- (void) prepare:(NSString*) sql args:(NSArray*) args withBlock:(IkhoyoBlock) block {
	__block IkhoyoDatabase* me = self;
	[self.worker performBlock:^(id obj){
		id arg = [me prepare:sql args:args usingClass:nil];
		[me.worker performBlockOnMainThread:block withObject:arg];
	}];
}

- (void) count:(NSString*) sql args:(NSArray*) args withBlock:(IkhoyoBlock) block {
	__block IkhoyoDatabase* me = self;
	[self.worker performBlock:^(id obj){
		id arg = [me count:sql args:args];
		[me.worker performBlockOnMainThread:block withObject:arg];
	}];
}

- (void) count:(IkhoyoStatement*) stmt withBlock:(IkhoyoBlock) block {
	__block IkhoyoDatabase* me = self;
	[self.worker performBlock:^(id obj){
		id arg = [stmt count];
		[me.worker performBlockOnMainThread:block withObject:arg];
	}];
}

- (void) select:(IkhoyoStatement*) select offset:(NSUInteger) offset limit:(NSUInteger) limit withBlock:(IkhoyoBlock) block {
	if ([select hasRowsAtOffset:offset andLimit:limit])
		[self.worker performBlockOnMainThread:block withObject:select];
	else {
		__block IkhoyoDatabase* me = self;
		[self.worker performBlock:^(id obj){
			[select offset:offset limit:limit];
			[me.worker performBlockOnMainThread:block withObject:select];
		}];
	}

}

- (void) insertOrUpdate:(NSString*) st withArgs:(NSArray*) args withBlock:(IkhoyoBlock) block {
	__block IkhoyoDatabase* me = self;
	[self prepare:st args:args withBlock:^(id arg) {
        __block IkhoyoStatement* insert = arg;
 		[self.worker performBlock:^(id obj){
			id ret = [insert exec];
			[me.worker performBlockOnMainThread:block withObject:ret];
		}];
	}];
}

- (void) execOnDatabaseThread:(IkhoyoBlock) block {
    [self.worker performBlock:^(id obj){
        block(nil);
    }];    
}

- (void) execOnMainThread:(IkhoyoBlock) block {
    [self.worker performBlockOnMainThread:block withObject:nil];
}

- (void) insertOrUpdate:(NSString*) st withBlock:(IkhoyoBlock) block {
    NSMutableArray* args = [[[NSMutableArray alloc] init] autorelease];
    [self insertOrUpdate:st withArgs:args withBlock:block];
}

- (void) query:(NSString*) query usingClass:(NSString*) cls withBlock:(IkhoyoBlock) block {
	__block IkhoyoDatabase* me = self;
    NSMutableArray* args = [[[NSMutableArray alloc] init] autorelease];
	[self prepare:query args:args usingClass:cls withBlock:^(id arg) {
        [me select:(IkhoyoStatement*) arg offset:0 limit:500 withBlock:^(id stmt) {
            IkhoyoStatement* s = stmt;
            block(s.rows);
        }];
	}];
}

- (void) exec:(IkhoyoStatement*) exec withBlock:(IkhoyoBlock) block {
	__block IkhoyoDatabase* me = self;
	__block IkhoyoStatement* stmt = exec;
	[self.worker performBlock:^(id obj) {
		[me.worker performBlockOnMainThread:block withObject:[stmt exec]];
	}];
}

- (void) close:(IkhoyoBlock) block {
	__block IkhoyoDatabase* me = self;
	[self.worker performBlock:^(id parm) {
		id arg = [me closeInternal];
		[me.worker performBlockOnMainThread:block withObject:arg];
	}];
}

@end
