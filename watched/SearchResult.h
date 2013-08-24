//
//  SearchResult.h
//  
//
//  Created by Martin Juhasz on 26.04.12.
//  Copyright (c) 2012. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface SearchResult : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) BOOL adult;
@property (nonatomic, assign) BOOL added;
@property (nonatomic, copy) NSString *backdropPath;
@property (nonatomic, copy) NSNumber *searchResultId;
@property (nonatomic, copy) NSString *originalTitle;
@property (nonatomic, copy) NSNumber *popularity;
@property (nonatomic, copy) NSString *posterPath;
@property (nonatomic, copy) NSDate *releaseDate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSNumber *voteAverage;
@property (nonatomic, copy) NSNumber *voteCount;

+ (id)searchResultFromJSONDictionary:(NSDictionary*)aDictionary;

- (NSString *)releaseYear;

@end
