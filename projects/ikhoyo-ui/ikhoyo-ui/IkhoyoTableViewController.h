//
//  IkhoyoTableViewController.h
//  ikhoyo-ui
//
//  Created by William Donahue on 6/9/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IkhoyoViewController.h"
#import "IkhoyoAddItemViewController.h"

@interface IkhoyoTableViewController : IkhoyoViewController<UITableViewDataSource,UITableViewDelegate> {
    IBOutlet UITableView* tableView;
    IBOutlet IkhoyoAddItemViewController* addItemViewController;
}
@property (nonatomic,retain) UITableView* tableView;
@property (nonatomic, retain) IkhoyoAddItemViewController* addItemViewController;

- (IBAction) addAction:(id) sender;
- (IBAction) editAction:(id) sender;
- (IBAction) addItemDone:(id) sender;
- (IBAction) addItemCancel:(id) sender;

- (void) addItem:(IkhoyoAddItemViewController*) ctlr;

@end
