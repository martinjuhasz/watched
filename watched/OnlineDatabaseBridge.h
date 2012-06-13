//
//  OnlineDatabaseBridge.h
//  watched
//
//  Created by Martin Juhasz on 08.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Movie;
@class SearchResult;

typedef void (^OnlineBridgeCompletionBlock)(Movie *);
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
- (void)saveSearchResultDictAsMovie:(NSDictionary *)resultDict completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
- (void)saveSearchResultAsMovie:(SearchResult*)result completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
- (void)setBackdropWithImagePath:(NSString*)imagePath toMovie:(Movie*)aMovie success:(void (^)(void))successBlock failure:(OnlineBridgeFailureBlock)failureBlock;
- (void)setPosterWithImagePath:(NSString*)imagePath toMovie:(Movie*)aMovie success:(void (^)(void))successBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
- (void)updateMovieMetadata:(Movie*)aMovie inContext:(NSManagedObjectContext*)aContext completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
- (void)updateMovie:(Movie*)movie withSearchResultDict:(NSDictionary*)movieDict completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
- (void)setCastsToMovie:(Movie*)aMovie success:(void (^)(void))successBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
- (void)saveMovieForID:(NSNumber*)movieID completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
@end
