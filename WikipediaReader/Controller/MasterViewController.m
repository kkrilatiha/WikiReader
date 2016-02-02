//
//  TableViewController.m
//  WikipediaReader
//
//  Created by Ksenija Krilatiha on 31/01/16.
//  Copyright © 2016 Ksenija Krilatiha. All rights reserved.
//

#import "MasterViewController.h"
#import "WebPage.h"
#import "NSDate+Format.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "SplitViewController.h"
#import "WikiPageManager.h"

@interface MasterViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *pFetchedResultsController;
@end

static NSString *CellIdentifier = @"FavouriteCell";
//Segue
static NSString *SelectPageSegueId = @"SelectPageSegue";

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    
    self.delegate = ((SplitViewController *)self.splitViewController).detailVC;
    
    // Fetch all favorite pages, sorted ASC
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([WebPage class])];
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:NO]]];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.pFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    [self.pFetchedResultsController setDelegate:self];
    NSError *error = nil;
    [self.pFetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Hide "Reader" button if detail view is shown
    [self p_hideReaderButton:!self.splitViewController.isCollapsed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)p_hideReaderButton:(BOOL)hide {
    self.navigationItem.rightBarButtonItem = (hide) ? nil :[[UIBarButtonItem alloc] initWithTitle:@"Reader"
                                                                                            style:UIBarButtonItemStylePlain
                                                                                           target:self
                                                                                           action:@selector(wikireaderButtonTappaed:)];
}


- (IBAction)wikireaderButtonTappaed:(id)sender {
    [self performSegueWithIdentifier:SelectPageSegueId sender:sender];
}

#pragma mark - Public methods


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.pFetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.pFetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    if ([sectionInfo numberOfObjects] == 0) {
        UILabel *noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
                                                                         self.tableView.bounds.size.width,
                                                                         self.tableView.bounds.size.height)];
        noDataLabel.text = @"No Favorite Pages";
        noDataLabel.textAlignment = NSTextAlignmentCenter;
        noDataLabel.textColor = [UIColor darkGrayColor];
        [noDataLabel sizeToFit];
        
        tableView.backgroundView = noDataLabel;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    } else {
        tableView.backgroundView = [[UIView alloc] initWithFrame:tableView.frame];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    WebPage *page = [self.pFetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:page.url];
    [cell.detailTextLabel setText:[page.dateAdded dateStringWithFormat:kDateLongFormat]];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WebPage *page =  [self.pFetchedResultsController objectAtIndexPath:indexPath];
        NSString *url = page.url;
        
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate.managedObjectContext deleteObject:page];
        [appDelegate saveContext];
        
        if ([self.delegate respondsToSelector:@selector(masterViewController:didDeleteWebPageWithURL:)]) {
            [self.delegate masterViewController:self didDeleteWebPageWithURL:url];
        }
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate:
        case NSFetchedResultsChangeMove:
            break;
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SelectPageSegueId]) {
        WebPage *selectedPage = [self.pFetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
        if (selectedPage) {
            UINavigationController *naVC = segue.destinationViewController;;
            self.delegate = (DetailViewController *)naVC.topViewController;
            [[WikiPageManager sharedInstance] setLastLoadedURL:[NSURL URLWithString:selectedPage.url]];
        }
    }
}


@end
