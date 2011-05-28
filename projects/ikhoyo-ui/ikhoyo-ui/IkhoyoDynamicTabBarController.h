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
//  IkhoyoDynamicTabBarController.h
//  ikhoyo-ui
//
//  Created by William Donahue on 5/24/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IkhoyoDynamicTabViewController;
@interface IkhoyoDynamicTabBarController : UITabBarController {
    NSMutableArray* tabs;
}
@property (nonatomic,retain) NSMutableArray* tabs;

- (void) removeTab:(IkhoyoDynamicTabViewController*) ctlr;
- (IkhoyoDynamicTabViewController*) addTab:(NSString*) name withClass:(NSString*) c andImage:(UIImage*) image andParam:(id) param;

@end
