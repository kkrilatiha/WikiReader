//
//  SplitViewController.h
//  WikipediaReader
//
//  Created by Ksenija Krilatiha on 2/1/16.
//  Copyright © 2016 Ksenija Krilatiha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "MasterViewController.h"

@interface SplitViewController : UISplitViewController
@property (nonatomic, readonly) MasterViewController *masterVC;
@property (nonatomic, readonly) DetailViewController *detailVC;
@end
