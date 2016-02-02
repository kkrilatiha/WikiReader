//
//  WebPage+CoreDataProperties.h
//  WikipediaReader
//
//  Created by Ksenija Krilatiha on 31/01/16.
//  Copyright © 2016 Ksenija Krilatiha. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "WebPage.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebPage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSDate *dateAdded;

@end

NS_ASSUME_NONNULL_END
