//
//  LastPageManager.m
//  WikipediaReader
//
//  Created by Ksenija Krilatiha on 2/1/16.
//  Copyright © 2016 Ksenija Krilatiha. All rights reserved.
//

#import "WikiPageManager.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface WikiPageManager ()
@end

@implementation WikiPageManager


- (NSURL *)lastLoadedURL {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    // Return last loaded page
    if (_lastLoadedURL.absoluteString.length) {
        return _lastLoadedURL;
    }
    
    // Return last saved favorite page
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: [NSEntityDescription entityForName:NSStringFromClass([WebPage class]) inManagedObjectContext: appDelegate.managedObjectContext]];
    
    NSError *error = nil;
    NSUInteger count = [appDelegate.managedObjectContext countForFetchRequest: request error: &error];
    if (count) {
        [request setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:NO]]];
        [request setFetchLimit:1];
        NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
        if (!error) {
            if ([results count]) {
                WebPage *page = [results firstObject];
                return [NSURL URLWithString:page.url];
            }
        }
    }
    // Default - return random Wiki page
    return [NSURL URLWithString:kRandowWikipageURL];
}

- (WebPage *)findFavoritePageWithURL:(NSURL *)url {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity: [NSEntityDescription entityForName:NSStringFromClass([WebPage class]) inManagedObjectContext: appDelegate.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"url == %@", _lastLoadedURL.absoluteString]];
    request.fetchLimit = 1;
    NSError *error = nil;
    
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    if (!error) {
        if ([results count]) {
            return [results firstObject];
        }
    }
    
    return nil;
}


+ (id)sharedInstance {
    static WikiPageManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}


@end
