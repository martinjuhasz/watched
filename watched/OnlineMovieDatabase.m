//
//  OnlineMovieDatabase.m
//  watched
//
//  Created by Martin Juhasz on 01.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OnlineMovieDatabase.h"
#import "AFJSONRequestOperation.h"
#import "AFImageRequestOperation.h"


@interface OnlineMovieDatabase () {
    NSString *configurationPath;
}
- (void)loadConfigurationWithFailure:(OnlineMovieDatabaseErrorBlock)failure;
- (NSString *)sizeURLParameterForImageType:(ImageType)aImageType andWidth:(CGFloat)width;
- (void)resizeImage:(UIImage *)image toWidth:(CGFloat)width completion:(MovieImageComppletionBlock)callback;
@end



@implementation OnlineMovieDatabase

static NSString *databaseURL = @"http://api.themoviedb.org/3";

@synthesize apiKey;
@synthesize configuration;



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initializing

- (id)init {
    self = [super init];
    if (self) {
        NSString *documentsDirectory = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        configurationPath = [documentsDirectory stringByAppendingPathComponent:@"configuration.dat"];
    }
    return self;
}

+ (id)sharedMovieDatabase
{
    static OnlineMovieDatabase *__instance = nil;
    if (__instance == nil) {
        __instance = [[OnlineMovieDatabase alloc] init];
    }
    
    return __instance;
}

- (void)setApiKey:(NSString *)aApiKey
{
    apiKey = aApiKey;
    [self loadConfigurationWithFailure:nil];
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Configuration

- (void)loadConfigurationWithFailure:(OnlineMovieDatabaseErrorBlock)failure
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/configuration?api_key=%@",databaseURL, apiKey]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [NSKeyedArchiver archiveRootObject:JSON toFile:configurationPath];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error);
    }];
    
    [operation start];
}

- (NSDictionary *)configuration
{
    if(!configuration) {
        configuration = [NSKeyedUnarchiver unarchiveObjectWithFile:configurationPath];
    }
    return configuration;
}

- (NSString *)sizeURLParameterForImageType:(ImageType)aImageType andWidth:(CGFloat)width
{
    NSArray *widths = nil;
    NSString *returnWidthParam = nil;
    CGFloat nearestSize = 0;
    
    // select the wanted array of image sizes based on imageType
    if(aImageType == ImageTypeBackdrop) {
        widths = [[self.configuration objectForKey:@"images"] objectForKey:@"backdrop_sizes"];
    } else if(aImageType == ImageTypeLogo) {
        widths = [[self.configuration objectForKey:@"images"] objectForKey:@"logo_sizes"];
    } else if(aImageType == ImageTypePoster) {
        widths = [[self.configuration objectForKey:@"images"] objectForKey:@"poster_sizes"];
    } else if(aImageType == ImageTypeProfile) {
        widths = [[self.configuration objectForKey:@"images"] objectForKey:@"profile_sizes"];
    }
    
    // loop through the image sizes and select the best fitting
    for (NSString *sizeString in widths) {
        CGFloat stringWidth = [[sizeString stringByReplacingOccurrencesOfString:@"w" withString:@""] floatValue];
        if(stringWidth > nearestSize && nearestSize < width) {
            returnWidthParam = sizeString;
            nearestSize = stringWidth;
        } else if(nearestSize < width && [sizeString isEqualToString:@"original"]) {
            returnWidthParam = sizeString;
            break;
        } else {
            break;
        }
    }
    
    return returnWidthParam;
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Searching

- (void)getMoviesWithSearchString:(NSString*)value atPage:(NSInteger)page completion:(MovieSearchCompletionBlock)callback failure:(OnlineMovieDatabaseErrorBlock)failure
{
    value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/search/movie?api_key=%@&query=%@&page=%d",databaseURL, apiKey, value, page]];
    XLog(@"Searching at URL: %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        callback(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error);
    }];
    
    [operation start];
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Images

- (NSURL *)getImageURLForImagePath:(NSString *)imagePath imageType:(ImageType)type nearWidth:(CGFloat)width
{
    NSString *sizeParam = [self sizeURLParameterForImageType:type andWidth:width];
    NSString *hostParam = [[self.configuration objectForKey:@"images"] objectForKey:@"base_url"];
    NSURL *returnURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", hostParam, sizeParam, imagePath]];
    return returnURL;
}

- (void)getImageForImagePath:(NSString *)imagePath 
                   imageType:(ImageType)type 
                   withWidth:(CGFloat)width 
                  completion:(MovieImageComppletionBlock)callback  
                     failure:(OnlineMovieDatabaseErrorBlock)failure
{
    NSURL *imageURL = [self getImageURLForImagePath:imagePath imageType:type nearWidth:width];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];

    AFImageRequestOperation *operation;
    operation = [AFImageRequestOperation imageRequestOperationWithRequest:request 
                                                     imageProcessingBlock:nil 
                                                                cacheName:nil 
                                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                      [self resizeImage:image toWidth:width completion:^(UIImage *resizedImage){
                                                                          callback(resizedImage);
                                                                      }];
                                                                  } 
                                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                      failure(error);
                                                                  }];
    [operation start];
}

- (void)resizeImage:(UIImage *)image toWidth:(CGFloat)width completion:(MovieImageComppletionBlock)callback
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^ {
        UIImage *thumbImage = nil;
        CGSize newSize = CGSizeMake(width, (width / image.size.width) * image.size.height);
        
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        thumbImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        callback(thumbImage);
    });
}

- (void)getImagesForMovie:(NSNumber *)movieID completion:(MovieImagesCompletionBlock)callback failure:(OnlineMovieDatabaseErrorBlock)failure
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/movie/%d/images?api_key=%@",databaseURL, [movieID intValue], apiKey]];
    XLog("Getting Movie Images at URL: %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        callback(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error);
    }];
    
    [operation start];
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Movie Details

- (void)getMovieDetailsForMovieID:(NSNumber *)movieID completion:(MovieDetailCompletionBlock)callback failure:(OnlineMovieDatabaseErrorBlock)failure
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/movie/%d?api_key=%@",databaseURL, [movieID intValue], apiKey]];
    XLog("Getting Movie Details at URL: %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        callback(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error);
    }];
    
    [operation start];
}

- (void)getMovieCastsForMovieID:(NSNumber *)movieID completion:(MovieCastsCompletionBlock)callback failure:(OnlineMovieDatabaseErrorBlock)failure
{
    // http://api.themoviedb.org/3/movie/11/casts
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/movie/%d/casts?api_key=%@",databaseURL, [movieID intValue], apiKey]];
    XLog("Getting Movie Casts at URL: %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        callback(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error);
    }];
    
    [operation start];    
}

- (void)getMovieTrailersForMovieID:(NSNumber *)movieID completion:(MovieTrailersCompletionBlock)callback failure:(OnlineMovieDatabaseErrorBlock)failure
{
    // http://api.themoviedb.org/3/movie/11/casts
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/movie/%d/trailers?api_key=%@",databaseURL, [movieID intValue], apiKey]];
    XLog(@"Getting Movie Trailers at URL: %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation;
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        callback(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error);
    }];
    
    [operation start];    
}

@end
