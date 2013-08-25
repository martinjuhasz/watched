//
//  OnlineDatabaseBridge.h
//  watched
//
//  Created by Martin Juhasz on 08.06.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Movie;
@class SearchResult;
@class AFJSONRequestOperation;

typedef void (^OnlineBridgeCompletionBlock)(Movie *aMovie);
typedef void (^OnlineBridgeFailureBlock)(NSError *);

// Error Handling
#define kBridgeErrorDomain @"de.martinjuhasz.bridgeerror"
typedef enum {
    BridgeErrorMovieExists,
    BridgeErrorNoBackdropImageFoundForURL,
    BridgeErrorNoPosterImageFoundForURL,
    BridgeErrorMovieDoesntExist
} BridgeError;


@interface OnlineDatabaseBridge : NSObject

//- (void)saveSearchResultDictAsMovie:(NSDictionary *)resultDict completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
//
//- (AFJSONRequestOperation*)saveSearchResultAsMovie:(SearchResult*)result completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
- (void)saveMovie:(Movie*)movie completion:(OnlineBridgeCompletionBlock)completionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
- (void)getMovieFromMovieID:(NSNumber*)movieID completion:(OnlineBridgeCompletionBlock)completionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;

- (void)setBackdropWithImagePath:(NSString*)imagePath toMovie:(Movie*)aMovie success:(void (^)(void))successBlock failure:(OnlineBridgeFailureBlock)failureBlock;

- (void)setPosterWithImagePath:(NSString*)imagePath toMovie:(Movie*)aMovie success:(void (^)(void))successBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;

- (AFJSONRequestOperation*)updateMovieMetadata:(Movie*)aMovie inContext:(NSManagedObjectContext*)aContext completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;

- (void)updateMovie:(Movie*)movie withSearchResultDict:(NSDictionary*)movieDict completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;

//- (AFJSONRequestOperation*)saveMovieForID:(NSNumber*)movieID completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
@end
