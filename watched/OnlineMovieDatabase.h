//
//  OnlineMovieDatabase.h
//  watched
//
//  Created by Martin Juhasz on 01.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MovieSearchCompletionBlock)(NSDictionary *);
typedef void (^MovieImageComppletionBlock)(UIImage *);

typedef enum {
    imageTypePoster,
    imageTypeBackdrop,
    imageTypeProfile,
    imageTypeLogo
} ImageType;

@interface OnlineMovieDatabase : NSObject

@property(nonatomic, strong) NSString *apiKey;
@property(nonatomic, strong) NSDictionary *configuration;

+ (id)sharedMovieDatabase;
- (void)getMoviesWithSearchString:(NSString*)value atPage:(NSInteger)page completion:(MovieSearchCompletionBlock)callback;
- (NSURL *)getImageURLForImagePath:(NSString *)imagePath imageType:(ImageType)type nearWidth:(CGFloat)width;
- (void)getImageForImagePath:(NSString *)imagePath imageType:(ImageType)type withWidth:(CGFloat)width completion:(MovieImageComppletionBlock)callback;

@end