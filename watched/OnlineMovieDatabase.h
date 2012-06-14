//
//  OnlineMovieDatabase.h
//  watched
//
//  Created by Martin Juhasz on 01.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Movie;

typedef void (^MovieSearchCompletionBlock)(NSDictionary *);
typedef void (^MovieImageComppletionBlock)(UIImage *);
typedef void (^MovieDetailCompletionBlock)(NSDictionary *);
typedef void (^MovieCastsCompletionBlock)(NSDictionary *);
typedef void (^MovieTrailersCompletionBlock)(NSDictionary *);
typedef void (^MovieImagesCompletionBlock)(NSDictionary *);
typedef void (^OnlineMovieDatabaseErrorBlock)(NSError *);

typedef enum {
    ImageTypePoster,
    ImageTypeBackdrop,
    ImageTypeProfile,
    ImageTypeLogo
} ImageType;

@interface OnlineMovieDatabase : NSObject

@property(nonatomic, strong) NSString *apiKey;
@property(nonatomic, strong) NSDictionary *configuration;
@property(nonatomic, strong) NSString *preferredLanguage;

+ (id)sharedMovieDatabase;
- (void)getMoviesWithSearchString:(NSString*)value atPage:(NSInteger)page completion:(MovieSearchCompletionBlock)callback failure:(OnlineMovieDatabaseErrorBlock)failure;
- (NSURL *)getImageURLForImagePath:(NSString *)imagePath imageType:(ImageType)type nearWidth:(CGFloat)width;
- (void)getImageForImagePath:(NSString *)imagePath imageType:(ImageType)type withWidth:(CGFloat)width completion:(MovieImageComppletionBlock)callback failure:(OnlineMovieDatabaseErrorBlock)failure;
- (void)getMovieDetailsForMovieID:(NSNumber *)movieID completion:(MovieDetailCompletionBlock)callback failure:(OnlineMovieDatabaseErrorBlock)failure;
- (void)getMovieCastsForMovieID:(NSNumber *)movieID completion:(MovieCastsCompletionBlock)callback failure:(OnlineMovieDatabaseErrorBlock)failure;
- (void)getMovieTrailersForMovieID:(NSNumber *)movieID completion:(MovieTrailersCompletionBlock)callback failure:(OnlineMovieDatabaseErrorBlock)failure;
- (void)getImagesForMovie:(NSNumber *)movieID completion:(MovieImagesCompletionBlock)callback failure:(OnlineMovieDatabaseErrorBlock)failure;
- (void)getSimilarMoviesWithMovieID:(NSNumber*)anID atPage:(NSInteger)page completion:(MovieSearchCompletionBlock)callback failure:(OnlineMovieDatabaseErrorBlock)failure;

@end