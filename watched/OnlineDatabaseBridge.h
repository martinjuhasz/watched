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
    BridgeErrorMovieExists
} BridgeError;


@interface OnlineDatabaseBridge : NSObject

@property (strong, nonatomic) OnlineBridgeCompletionBlock completionBlock;
@property (strong, nonatomic) OnlineBridgeFailureBlock failureBlock;

- (void)saveSearchResultAsMovie:(SearchResult*)result;

@end
