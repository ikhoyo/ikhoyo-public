//
//  SocrataTableViewController.m
//  ikhoyo-top
//
//  Created by William Donahue on 6/27/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import "SocrataTableViewController.h"
#import "IkhoyoAppDelegate.h"

@interface Socrata : NSObject {
    NSString* name;
}
@property (nonatomic,retain) NSString* name;
@end

@implementation Socrata
@synthesize name;
@end

@implementation SocrataTableViewController
@synthesize rows;

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
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    self.rows = [[[NSMutableArray alloc] initWithCapacity:16] autorelease];
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) observeReady {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReady:) name:@"IkhoyoSocrataReady" object:nil];
}

- (void) onReady {
    NSString* q = @"SELECT name FROM n5m4_msim";
    IkhoyoAppDelegate* d = (IkhoyoAppDelegate*) self.app;
    [d.db query:q usingClass:@"Socrata" withBlock:^(id obj) {
        NSMutableArray* names = (NSMutableArray*) obj;
        for (int i=0;i<[names count];i++) {
            Socrata* socrata = [names objectAtIndex:i];
            [self.rows addObject:socrata.name];
        }
        [self.tableView reloadData];        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [rows objectAtIndex:indexPath.row];
    
    return cell;
}


@end
