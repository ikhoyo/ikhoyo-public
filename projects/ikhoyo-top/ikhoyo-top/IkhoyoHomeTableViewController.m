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
//  IkhoyoHomeTableViewController.m
//  ikhoyo-top
//
//  Created by William Donahue on 5/25/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import "IkhoyoHomeTableViewController.h"
#import "IkhoyoWebViewController.h"

@implementation IkhoyoHomeTableViewController
@synthesize rows;
@synthesize webAppController;
@synthesize webAppDictionaries;
@synthesize detailViewController;

- (void)dealloc
{
    [rows release];
    [webAppDictionaries release];
    [detailViewController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rows = [[[NSMutableArray alloc] init] autorelease];
    self.webAppDictionaries = [[[NSMutableArray alloc] init] autorelease];
    
    [self.rows addObject:@"Sample Web View"];
    UIImage* image = [UIImage imageNamed:@"www.png"];
    NSString* dir = [[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"xcode-resources"] stringByAppendingPathComponent:@"webviews"] stringByAppendingPathComponent:@"sample-web-view"];
    [self.webAppDictionaries addObject:[NSDictionary dictionaryWithObjectsAndKeys:dir,@"dir",image,@"image", nil]];
}

- (void) onReady {
    NSString* dir = [[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"xcode-resources"] stringByAppendingPathComponent:@"webviews"] stringByAppendingPathComponent:@"home"];
    [self.webAppController start:dir];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.rows count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Local Web Apps";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    cell.textLabel.text = [self.rows objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* params = [self.webAppDictionaries objectAtIndex:indexPath.row];
    [self.detailViewController addTab:@"SampleWebView" withClass:@"SampleWebView" andImage:[params valueForKey:@"image"] andParam:[params valueForKey:@"dir"]];
}

@end
