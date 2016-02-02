//
//  DetailViewController.m
//  WikipediaReader
//
//  Created by Ksenija Krilatiha on 31/01/16.
//  Copyright © 2016 Ksenija Krilatiha. All rights reserved.
//

#import "DetailViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "WikiPageManager.h"
#import "WebPage.h"

@interface DetailViewController () <UIWebViewDelegate, UIPopoverPresentationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *iboWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *iboFavoriteItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *iboShareItem;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    //Show last loaded URL or last saved favorite
    NSMutableURLRequest *wikiRequest = [NSMutableURLRequest requestWithURL:[[WikiPageManager sharedInstance] lastLoadedURL]];
    [self.iboWebView loadRequest:wikiRequest];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ( [self.iboWebView isLoading] ) {
        [self.iboWebView stopLoading];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)p_reloadPageWithIsFavorite:(BOOL)isFavorite {
    if (isFavorite) {
        [self.iboFavoriteItem setImage:[UIImage imageNamed:@"icn-favorite-a"]];
    } else {
        [self.iboFavoriteItem setImage:[UIImage imageNamed:@"icn-favorite"]];
    }
}

#pragma mark - Action methods

- (IBAction)nextButtonTapped:(id)sender {
    NSMutableURLRequest *wikiRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kRandowWikipageURL]];
    [self.iboWebView loadRequest:wikiRequest];
}

- (IBAction)favoriteButtonTapped:(id)sender {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    WebPage *foundPage = [[WikiPageManager sharedInstance] findFavoritePageWithURL:self.iboWebView.request.URL];
    if (foundPage) {
        //Delete from Favorites
        [self.iboFavoriteItem setImage:[UIImage imageNamed:@"icn-favorite"]];
        [appDelegate.managedObjectContext deleteObject:foundPage];
    } else {
        // Add to Favorites
        [self.iboFavoriteItem setImage:[UIImage imageNamed:@"icn-favorite-a"]];
        WebPage *page = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([WebPage class])
                                                      inManagedObjectContext:appDelegate.managedObjectContext];
        [page setUrl:self.iboWebView.request.URL.absoluteString];
        [page setDateAdded:[NSDate date]];
    }
    
    [appDelegate saveContext];
}

- (IBAction)shareButtonTapped:(id)sender {
    if (self.iboWebView.request.URL.absoluteString.length) {
        NSArray *activityItems = @[@"Wikipedia Page", self.iboWebView.request.URL.absoluteString];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
        activityVC.excludedActivityTypes =  @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeMessage, UIActivityTypeMail];
        
        if ([activityVC respondsToSelector:@selector(popoverPresentationController)]) {
            activityVC.popoverPresentationController.barButtonItem = self.iboShareItem;
        }
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

#pragma mark - MasterViewControllerDelegate methods

- (void)masterViewController:(MasterViewController*)viewController
     didDeleteWebPageWithURL:(NSString *)url {
    if ([url isEqualToString: [[WikiPageManager sharedInstance] lastLoadedURL].absoluteString]) {
        // If current viewed page was deleted
        [self p_reloadPageWithIsFavorite:NO];
    }
}


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.iboFavoriteItem.enabled = NO;
    self.iboShareItem.enabled = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // Save last loaded URL
    [[WikiPageManager sharedInstance] setLastLoadedURL:self.iboWebView.request.URL];
    WebPage *foundPage = [[WikiPageManager sharedInstance] findFavoritePageWithURL:self.iboWebView.request.URL];
    [self p_reloadPageWithIsFavorite:(foundPage) ? YES : NO];
    
    self.title = self.iboWebView.request.URL.absoluteString;
    
    self.iboFavoriteItem.enabled = YES;
    self.iboShareItem.enabled = YES;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == NSURLErrorCancelled) {
        NSLog(@"Canceled request: %@", [webView.request.URL absoluteString]);
    } else {
        NSString* errorString = [NSString stringWithFormat:
                                 @"<html><center><font size=+5 color='red'>  An error occurred:<br>%@</font></center></html>", error.localizedDescription];
        [self.iboWebView loadHTMLString:errorString baseURL:nil];
    }
}

@end
