//
//  Util.m
//  nox
//
//  Created by Justine DiPrete on 8/22/13.
//  Copyright (c) 2013 Justine DiPrete. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSString *)stringFromDate:(NSDate *)a_date
{
    int second = 1;
    int minute = 60 * second;
    int hour = 60 * minute;
    int day = 24 * hour;
    int year = 365 * day;
    
    NSTimeInterval timePassed = -[a_date timeIntervalSinceNow];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setAMSymbol:@"am"];
    [formatter setPMSymbol:@"pm"];
    
    if(timePassed < 0)
    {
        [formatter setDateFormat:@"MMMM dd' at 'h:mma"];
        NSString * dateString = [formatter stringFromDate:a_date];
        return dateString;
    }
    
    if(timePassed < 1 * minute)
    {
        return timePassed == 1 ? @"a second ago" : [NSString stringWithFormat:@"%d seconds ago", (int)timePassed];
    }
    
    if(timePassed < 60 * minute)
    {
        int minutes = timePassed/minute;
        return minutes == 1 ? @"a minute ago" : [NSString stringWithFormat:@"%d minutes ago", minutes];
    }

    if(timePassed < 24 * hour)
    {
        int hours = timePassed/hour;
        return hours == 1 ? @"an hour ago" : [NSString stringWithFormat:@"%d hours ago", hours];
    }
    
    if(timePassed < day * 7)
    {
        [formatter setDateFormat:@"cccc' at 'h:mma"];
        NSString * dateString = [formatter stringFromDate:a_date];
        return dateString;
    }
    
    if(timePassed > (24 * hour) && timePassed < year)
    {
        [formatter setDateFormat:@"MMMM dd' at 'h:mma"];
        NSString * dateString = [formatter stringFromDate:a_date];
        return dateString;
    }
    else
    {
        [formatter setDateFormat:@"MMMM dd', 'YYYY' at 'h:mma"];
        NSString * dateString = [formatter stringFromDate:a_date];
        return dateString;
    }

}

@end
