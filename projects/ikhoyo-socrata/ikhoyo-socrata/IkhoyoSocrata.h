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
//  IkhoyoSocrata.h
//  ikhoyo-socrata
//
//  Created by William Donahue on 6/24/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IkhoyoURLManager.h"
#import "IkhoyoThread.h"

@interface IkhoyoSocrata : NSObject <IkhoyoURLManagerDelegate> {
    NSString* baseURL;
    NSString* viewURL;
    NSString* dataType;
    NSString* appTokenQS;
    NSMutableArray* tasks;
    IkhoyoURLManager* urlManager;
}
@property (nonatomic,retain) NSString* baseURL;
@property (nonatomic,retain) NSString* viewURL;
@property (nonatomic,retain) NSString* dataType;
@property (nonatomic,retain) NSString* appTokenQS;
@property (nonatomic,retain) NSMutableArray* tasks;
@property (nonatomic,retain) IkhoyoURLManager* urlManager;

- (id) initWithURLManager:(IkhoyoURLManager*) urlManager;
- (id) initWithURLManager:(IkhoyoURLManager*) urlManager andApiKey:(NSString*) apiKey;
- (id) initWithURLManager:(id) um andApiKey:(NSString*) apiKey andDataType:(NSString*) dt;

- (void) get:(NSString*) ds withBlock:(IkhoyoBlock) block;
- (void) getMeta:(NSString*) ds withBlock:(IkhoyoBlock) block;
- (void) get:(NSString*) ds maxRows:(int)max withBlock:(IkhoyoBlock) block;

@end
