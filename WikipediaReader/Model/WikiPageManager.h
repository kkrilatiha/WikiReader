//
//  LastPageManager.h
//  WikipediaReader
//
//  Created by Ksenija Krilatiha on 2/1/16.
//  Copyright © 2016 Ksenija Krilatiha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebPage.h"

@interface WikiPageManager : NSObject

+ (id)sharedInstance;
@property (nonatomic, strong) NSURL *lastLoadedURL;

- (WebPage *)findFavoritePageWithURL:(NSURL *)url;

@end
