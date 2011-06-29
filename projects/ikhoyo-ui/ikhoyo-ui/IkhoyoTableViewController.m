//
//  IkhoyoTableViewController.m
//  ikhoyo-ui
//
//  Created by William Donahue on 6/9/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import "IkhoyoTableViewController.h"

@implementation IkhoyoTableViewController
@synthesize tableView;
@synthesize addItemViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [tableView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundView.alpha = 0; // Fixes a bug on the iPad
    self.tableView.backgroundColor = [UIColor clearColor]; // Fixes a bug on the iPhone
    [self applyBackgroundGradient];
}

- (void) addItem:(IkhoyoAddItemViewController*) ctlr {
    
}

- (IBAction) addAction:(id) sender {
    if (self.addItemViewController)
        [self.navigationController pushViewController:self.addItemViewController animated:YES];
}

- (IBAction) addItemDone:(id) sender {
    [self addItem:self.addItemViewController];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) addItemCancel:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) editAction:(id) sender {
    self.editing = !self.editing;
    [self setEditing:self.editing animated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    return cell;
}


@end
