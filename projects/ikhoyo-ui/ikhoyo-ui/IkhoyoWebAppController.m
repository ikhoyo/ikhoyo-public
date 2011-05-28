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
//  IkhoyoWebAppController.m
//  ikhoyo-ui
//
//  Created by William Donahue on 5/25/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import "IkhoyoWebAppController.h"
#import "GRMustache.h"

@implementation IkhoyoWebAppController
@synthesize url;
@synthesize baseUrl;
@synthesize webView;
@synthesize context;
@synthesize baseDir;

- (id)initWithNibName:(NSString*) nibNameOrNil bundle:(NSBundle*) nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.context = [[[IkhoyoWebAppContext alloc] init] autorelease];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (NSString*) executeTemplate:(NSString*) path {
	NSError* error;
	NSStringEncoding enc;
	NSString* template = [NSString stringWithContentsOfFile:path usedEncoding:&enc error:&error];
    NSString* result = [GRMustacheTemplate renderObject:self.context fromString:template error:&error];
    return result;
}

- (NSString*) convert:(NSString*) p useBaseDirectory:(Boolean) useBase {
	NSString* file = useBase ? [self.baseDir stringByAppendingPathComponent:p] : p;
	return [self executeTemplate:file];
}

- (void) handle:(NSString*) path withMimeType:(NSString*) mime useBaseDirectory:(Boolean) usebase {
    NSString* ml = [self convert:path useBaseDirectory:usebase];
    NSData* data = [ml dataUsingEncoding:NSUTF8StringEncoding];
    [self.webView loadData:data MIMEType:mime textEncodingName:@"utf-8" baseURL:self.baseUrl];
}

- (void) start:(NSString*) dir{
    self.baseDir = dir;
    self.baseUrl = [NSURL fileURLWithPath:self.baseDir];
    [self handle:@"index.xml" withMimeType:@"text/xml" useBaseDirectory:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {    
}

- (BOOL) webView:(UIWebView*) wv shouldStartLoadWithRequest:(NSURLRequest*) request navigationType:(UIWebViewNavigationType)navigationType {
	self.url = [request URL];
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        if ([url isFileURL]) {
            NSString* path = [url path];
            NSString* selStr = [[@"handle_" stringByAppendingString: [path pathExtension]] stringByAppendingString:@":"];
            SEL selector = NSSelectorFromString(selStr);
            [self performSelector:selector withObject:path];
            return NO;
        }
        [[UIApplication sharedApplication] openURL:[request URL]];        
    } else if ([url isFileURL])
        return YES;
    return NO;
}

- (void) handle_xml:(NSString*) path {
    [self handle:path withMimeType:@"text/xml" useBaseDirectory:NO];
}

- (void) handle_html:(NSString*) path {
    [self handle:path withMimeType:@"text/html" useBaseDirectory:NO];
}

@end
