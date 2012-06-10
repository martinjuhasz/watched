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
    BridgeErrorNoPosterImageFoundForURL
} BridgeError;


@interface OnlineDatabaseBridge : NSObject
- (void)saveSearchResultDictAsMovie:(NSDictionary *)resultDict completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
- (void)saveSearchResultAsMovie:(SearchResult*)result completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;
- (void)setBackdropWithImagePath:(NSString*)imagePath toMovie:(Movie*)aMovie success:(void (^)(void))successBlock failure:(OnlineBridgeFailureBlock)failureBlock;
- (void)setPosterWithImagePath:(NSString*)imagePath toMovie:(Movie*)aMovie success:(void (^)(void))successBlock failure:(OnlineBridgeFailureBlock)aFailureBlock;

@end
