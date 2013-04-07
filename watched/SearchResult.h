//
//  SearchResult.h
//  
//
//  Created by Martin Juhasz on 26.04.12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResult : NSObject

@property (nonatomic, assign) BOOL adult;
@property (nonatomic, assign) BOOL added;
@property (nonatomic, assign) BOOL failed;
@property (nonatomic, strong) NSString *backdropPath;
@property (nonatomic, strong) NSNumber *searchResultId;
@property (nonatomic, strong) NSString *originalTitle;
@property (nonatomic, strong) NSNumber *popularity;
@property (nonatomic, strong) NSString *posterPath;
@property (nonatomic, strong) NSDate *releaseDate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *voteAverage;
@property (nonatomic, strong) NSNumber *voteCount;

+ (SearchResult *)instanceFromDictionary:(NSDictionary *)aDictionary;
- (void)setAttributesFromDictionary:(NSDictionary *)aDictionary;
- (NSString *)releaseYear;

@end
