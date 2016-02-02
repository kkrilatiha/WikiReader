//
//  NSDate+Format.m
//  WikipediaReader
//
//  Created by Ksenija Krilatiha on 31/01/16.
//  Copyright © 2016 Ksenija Krilatiha. All rights reserved.
//

#import "NSDate+Format.h"

@implementation NSDate (Format)

- (NSString *)dateStringWithFormat:(NSString *)format {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString * string = [formatter stringFromDate:self];
    return string;
}

@end
