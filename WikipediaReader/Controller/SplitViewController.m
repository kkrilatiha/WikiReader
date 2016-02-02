//
//  SplitViewController.m
//  WikipediaReader
//
//  Created by Ksenija Krilatiha on 2/1/16.
//  Copyright © 2016 Ksenija Krilatiha. All rights reserved.
//

#import "SplitViewController.h"

@interface SplitViewController ()
@property (nonatomic, strong) UIViewController *pMasterVC;
@property (nonatomic, strong) UIViewController *pDetailVC;
@end

@implementation SplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController *masterNav = [self.viewControllers firstObject];
    self.pMasterVC = [masterNav.viewControllers firstObject];
    UINavigationController *detailNav = [self.viewControllers lastObject];
    self.pDetailVC = [detailNav.viewControllers firstObject];
    
    [self p_updateMaximumPrimaryColumnWidthBasedOnSize:self.view.bounds.size];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self p_updateMaximumPrimaryColumnWidthBasedOnSize:size];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public methods

- (UIViewController *)masterVC {
    return self.pMasterVC;
}

- (UIViewController *)detailVC {
    return self.pDetailVC;
}

#pragma mark - Private methods

- (void)p_updateMaximumPrimaryColumnWidthBasedOnSize:(CGSize)size {
    
    if (size.width < [UIScreen mainScreen].bounds.size.width || size.width < size.height) {
        self.maximumPrimaryColumnWidth = 180.0;
    } else {
        self.maximumPrimaryColumnWidth = UISplitViewControllerAutomaticDimension;
    }
}

@end
