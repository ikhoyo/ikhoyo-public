//
//  IkhoyoAddItemViewController.m
//  ikhoyo-ui
//
//  Created by William Donahue on 6/10/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import "IkhoyoAddItemViewController.h"


@implementation IkhoyoAddItemViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self applyBackgroundGradient];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) textFieldDidEndOnExit:(id) sender {
}


@end
