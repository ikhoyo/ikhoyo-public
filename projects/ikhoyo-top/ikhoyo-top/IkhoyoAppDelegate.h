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
//  IkhoyoAppDelegate.h
//  ikhoyo-top
//
//  Created by William Donahue on 5/24/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IkhoyoDelegate.h"
#import "IkhoyoSocrata.h"
#import "IkhoyoDatabase.h"

@class IkhoyoURLManager;
@class RootViewController;
@class DetailViewController;
@interface IkhoyoAppDelegate : NSObject <UIApplicationDelegate,IkhoyoDelegate> {
    Boolean ready;
    IkhoyoDatabase* db;
    IkhoyoSocrata* socrata;
    IkhoyoURLManager* urlManager;
}

@property (nonatomic) Boolean ready;
@property (nonatomic, retain) IkhoyoDatabase* db;
@property (nonatomic, retain) IkhoyoSocrata* socrata;
@property (nonatomic, retain) IkhoyoURLManager* urlManager;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
