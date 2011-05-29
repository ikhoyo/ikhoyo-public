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
//  SampleWebAppContext.m
//  ikhoyo-top
//
//  Created by William Donahue on 5/25/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import "SampleWebViewContext.h"

@interface Item : NSObject {
    NSString* name;
}
@property (nonatomic,retain) NSString* name;

- (id) initWithName:(NSString*) name;

@end

@implementation Item
@synthesize name;

- (id) initWithName:(NSString*) n {
    self = [super init];
    if (self) {
        self.name = n;
    }
    return self;
    
}

@end

@implementation SampleWebViewContext
@synthesize listOfItems;

- (id) init {
    self = [super init];
    if (self) {
        listOfItems = [[NSMutableArray alloc] init];
        [listOfItems addObject:[[[Item alloc] initWithName:@"List item 1"] autorelease]];
        [listOfItems addObject:[[[Item alloc] initWithName:@"List item 2"] autorelease]];
        [listOfItems addObject:[[[Item alloc] initWithName:@"List item 3"] autorelease]];
        [listOfItems addObject:[[[Item alloc] initWithName:@"List item 4"] autorelease]];
        [listOfItems addObject:[[[Item alloc] initWithName:@"List item 5"] autorelease]];
    }
    return self;
}

@end
