//
//  SocrataTableViewController.h
//  ikhoyo-top
//
//  Created by William Donahue on 6/27/11.
//  Copyright 2011 Ikhoyo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IkhoyoTableViewController.h"

@interface SocrataTableViewController : IkhoyoTableViewController {
    NSMutableArray* rows;
}
@property (nonatomic,retain) NSMutableArray* rows;

@end
