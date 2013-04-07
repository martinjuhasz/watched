//
//  SearchResult.m
//  
//
//  Created by Martin Juhasz on 26.04.12.
//  Copyright (c) 2012. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult

@synthesize adult;
@synthesize backdropPath;
@synthesize searchResultId;
@synthesize originalTitle;
@synthesize popularity;
@synthesize posterPath;
@synthesize releaseDate;
@synthesize title;
@synthesize voteAverage;
@synthesize voteCount;

+ (SearchResult *)instanceFromDictionary:(NSDictionary *)aDictionary
{

    SearchResult *instance = [[SearchResult alloc] init];
    [instance setAttributesFromDictionary:aDictionary];
    return instance;

}

- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary
{

    if (![aDictionary isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    self.added = NO;
    self.failed = NO;
    self.adult = [(NSNumber *)[aDictionary objectForKey:@"adult"] boolValue];
    self.backdropPath = [aDictionary objectForKey:@"backdrop_path"];
    self.searchResultId = [aDictionary objectForKey:@"id"];
    self.originalTitle = [aDictionary objectForKey:@"original_title"];
    self.popularity = [aDictionary objectForKey:@"popularity"];
    self.posterPath = [aDictionary objectForKey:@"poster_path"];
    self.releaseDate = [aDictionary objectForKey:@"release_date"];
    self.title = [aDictionary objectForKey:@"title"];
    self.voteAverage = [aDictionary objectForKey:@"vote_average"];
    self.voteCount = [aDictionary objectForKey:@"vote_count"];

}

- (void)setAdded:(BOOL)newAdded
{
    _added = newAdded;
    if(newAdded == YES) {
        _failed = NO;
    }
}

- (void)setFailed:(BOOL)newFailed
{
    _failed = newFailed;
    if(newFailed == YES) {
        _added = NO;
    }
}

- (void)setReleaseDate:(id)aReleaseDate
{
    if([aReleaseDate isKindOfClass:[NSString class]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-DD"];
        releaseDate = [dateFormatter dateFromString:aReleaseDate];
        return;
    }
    releaseDate = nil;
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
