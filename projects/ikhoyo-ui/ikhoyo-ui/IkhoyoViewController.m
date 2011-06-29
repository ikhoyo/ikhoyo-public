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
//  IkhoyoViewController.m
//  ikhoyo-ui
//
//  Created by William Donahue on 5/24/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import "IkhoyoViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation IkhoyoViewController
@synthesize app;
@synthesize ready;
@synthesize backgroundGradientColor;

- (void) applyBackgroundGradient {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[self.backgroundGradientColor CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) observeReady {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReady:) name:@"IkhoyoReady" object:nil];
}

- (void) onReady {
}

- (void) doOnReady {
    if (self.ready) return;
    self.ready = YES;
    [self onReady];
}

- (void) notificationReady: (NSNotification*) not {
    self.app = [not object];
    [self doOnReady];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.app)
        self.app = (id<IkhoyoDelegate>)[UIApplication sharedApplication].delegate;
    [self observeReady];
    if ([self.app isIkhoyoReady])
        [self doOnReady];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
