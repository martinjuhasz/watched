//
//  SearchResult.m
//  
//
//  Created by Martin Juhasz on 26.04.12.
//  Copyright (c) 2012. All rights reserved.
//

#import "SearchResult.h"
#import "MTLValueTransformer.h"

@implementation SearchResult

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"backdropPath" : @"backdrop_path",
             @"searchResultId" : @"id" ,
             @"originalTitle" : @"original_title",
             @"posterPath" : @"poster_path",
             @"releaseDate" : @"release_date",
             @"voteAverage" : @"vote_average",
             @"voteCount" : @"vote_count"
             };
}

+ (id)searchResultFromJSONDictionary:(NSDictionary*)aDictionary
{
    NSError *error = nil;
    MTLJSONAdapter *modelAdapter = [[MTLJSONAdapter alloc] initWithJSONDictionary:aDictionary modelClass:[SearchResult class] error:&error];
    if(!error && [modelAdapter.model isKindOfClass:[SearchResult class]]) {
        return(SearchResult*)modelAdapter.model;
    }
    return nil;
}

+ (NSValueTransformer *)releaseDateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-DD"];
        return [dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *aDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-DD"];
        return [dateFormatter stringFromDate:aDate];
    }];
}

- (NSString *)releaseYear
{
    if(![self.releaseDate isKindOfClass:[NSDate class]]) {
        return nil;
    }
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.releaseDate];
    return [NSString stringWithFormat:@"%i",[components year]];
}

@end
