//
//  TableViewController.h
//  WikipediaReader
//
//  Created by Ksenija Krilatiha on 31/01/16.
//  Copyright © 2016 Ksenija Krilatiha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebPage.h"

@protocol MasterViewControllerDelegate;

@interface MasterViewController : UITableViewController

@property (nonatomic, weak) id<MasterViewControllerDelegate> delegate;
@end

@protocol MasterViewControllerDelegate <NSObject>
@optional
- (void)masterViewController:(MasterViewController*)viewController
            didDeleteWebPageWithURL:(NSString *)url;

@end
