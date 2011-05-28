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
//  IkhoyoWebViewController.h
//  ikhoyo-ui
//
//  Created by William Donahue on 5/25/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IkhoyoWebViewContext.h"

@interface IkhoyoWebViewController : UIViewController <UIWebViewDelegate> {
    NSURL* url;
    NSURL* baseUrl;
    NSString* baseDir;
    IBOutlet UIWebView* webView;
    IBOutlet IkhoyoWebViewContext* context;    
}
@property (nonatomic,retain) NSURL* url;
@property (nonatomic,retain) NSURL* baseUrl;
@property (nonatomic,retain) NSString* baseDir;
@property (nonatomic,retain) UIWebView* webView;
@property (nonatomic,retain) IkhoyoWebViewContext* context;

- (void) start:(NSString*) dir;

@end
