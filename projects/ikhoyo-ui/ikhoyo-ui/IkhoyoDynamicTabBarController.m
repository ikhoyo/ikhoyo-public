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
//  IkhoyoDynamicTabBarController.m
//  ikhoyo-ui
//
//  Created by William Donahue on 5/24/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import "IkhoyoDynamicTabBarController.h"
#import "IkhoyoDynamicTabViewController.h"

@implementation IkhoyoDynamicTabBarController
@synthesize tabs;

- (void)dealloc
{
    [tabs release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IkhoyoDynamicTabViewController*) hasTab:(NSString*) name {
    IkhoyoDynamicTabViewController* tab;
    NSEnumerator* e = [self.tabs objectEnumerator];
    while ((tab=[e nextObject])) {
        if ([tab.name isEqualToString:name])
            return tab;
    }
    return nil;
 }
 
- (IkhoyoDynamicTabViewController*) addTab:(NSString*) name withClass:(NSString*) c andImage:(UIImage*) image andParam:(id) param {
     IkhoyoDynamicTabViewController* ctlr = [self hasTab:name];
     if (!ctlr) {
         Class cls = NSClassFromString(c);
         ctlr = [[[cls alloc] initWithNibName:c bundle:nil] autorelease];
         ctlr.name = name;
         [ctlr view]; // Needed to force wiring in some cases
         ctlr.root.tabBarItem.title = name;
         if (image)
             ctlr.root.tabBarItem.image = image;
         NSMutableArray * vcs = [NSMutableArray arrayWithArray:[self viewControllers]];
         [tabs addObject:ctlr];
         [vcs addObject:ctlr.root];
         [self setViewControllers:vcs animated:NO];
     }
     [self setSelectedViewController:ctlr.root];
     [ctlr start:param];
     return ctlr;
 }
 
 - (void) removeTab:(IkhoyoDynamicTabViewController*) ctlr {
     NSMutableArray * vcs = [NSMutableArray arrayWithArray:[self viewControllers]];
     [vcs removeObject:ctlr];
     [self.tabs removeObject:ctlr];
     [self setViewControllers:vcs animated:NO];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabs = [[[NSMutableArray alloc] init] autorelease];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
