//
//  OnlineDatabaseBridge.m
//  watched
//
//  Created by Martin Juhasz on 08.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OnlineDatabaseBridge.h"
#import "OnlineMovieDatabase.h"
#import "MoviesDataModel.h"
#import <CoreData/CoreData.h>
#import "AFHTTPRequestOperation.h"
#import "NSDictionary+ObjectForKeyOrNil.h"
#import "SearchResult.h"
#import "Movie.h"
#import "Cast.h"
#import "Crew.h"
#import "Trailer.h"


@interface OnlineDatabaseBridge()
@end

@implementation OnlineDatabaseBridge

@synthesize completionBlock;
@synthesize failureBlock;

- (void)saveSearchResultAsMovie:(SearchResult*)result
{
    [[OnlineMovieDatabase sharedMovieDatabase] getMovieDetailsForMovieID:result.searchResultId completion:^(NSDictionary *movieDict) {
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            // Setup Core Data with extra Context for Background Process
            __block NSError *runtimeError = nil;
            NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
            [context setPersistentStoreCoordinator:[[MoviesDataModel sharedDataModel] persistentStoreCoordinator]];
            
            NSInteger serverId = [[movieDict objectForKey:@"id"] intValue];
            Movie *movie = [Movie movieWithServerId:serverId usingManagedObjectContext:context];
            
            if(movie == nil) {
                
                // dispatch it
                dispatch_group_t group = dispatch_group_create();
                
                // Movie
                movie = [Movie insertInManagedObjectContext:context];
                [movie updateAttributes:movieDict];
                
                // Backdrop
                NSString *backdropString = [movieDict objectForKey:@"backdrop_path"];
                NSURL *backdropURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:backdropString imageType:ImageTypeBackdrop nearWidth:800.0f];
                if(backdropURL) {
                    dispatch_group_enter(group);
                    NSURLRequest *backdropRequest = [NSURLRequest requestWithURL:backdropURL];
                    AFHTTPRequestOperation *backdropOperation = [[AFHTTPRequestOperation alloc] initWithRequest:backdropRequest];
                    [backdropOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        if([responseObject isKindOfClass:[NSData class]]) {
                            movie.backdrop = [UIImage imageWithData:responseObject];
                            movie.backdropURL = backdropString;
                            dispatch_group_leave(group);
                        }
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        runtimeError = error;
                        dispatch_group_leave(group);
                    }];
                    [backdropOperation start];
                }
                
                
                // Poster
                NSString *posterString = [movieDict objectForKey:@"poster_path"];
                NSURL *posterURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:posterString imageType:ImageTypeBackdrop nearWidth:260.0f];
                if(posterURL) {
                    dispatch_group_enter(group);
                    NSURLRequest *posterRequest = [NSURLRequest requestWithURL:posterURL];
                    AFHTTPRequestOperation *posterOperation = [[AFHTTPRequestOperation alloc] initWithRequest:posterRequest];
                    [posterOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        CGFloat posterWitdh = 260.0f;
                        CGFloat thumbnailPosterWith = 122.0f;
                        UIImage *image = [UIImage imageWithData:responseObject];
                        
                        // Image
                        UIImage *poster = nil;
                        CGSize newPosterSize = CGSizeMake(posterWitdh, (posterWitdh / image.size.width) * image.size.height);
                        UIGraphicsBeginImageContext(newPosterSize);
                        [image drawInRect:CGRectMake(0, 0, newPosterSize.width, newPosterSize.height)];
                        poster = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        // Thumb Image
                        UIImage *thumbPoster = nil;
                        CGSize newThumbnailPosterSize = CGSizeMake(thumbnailPosterWith, (thumbnailPosterWith / image.size.width) * image.size.height);
                        UIGraphicsBeginImageContext(newThumbnailPosterSize);
                        [image drawInRect:CGRectMake(0, 0, newThumbnailPosterSize.width, newThumbnailPosterSize.height)];
                        thumbPoster = UIGraphicsGetImageFromCurrentImageContext();
                        UIGraphicsEndImageContext();
                        
                        movie.poster = poster;
                        movie.posterURL = posterString;
                        movie.posterThumbnail = thumbPoster;
                        
                        dispatch_group_leave(group);
                        
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        runtimeError = error;
                        dispatch_group_leave(group);
                    }];
                    [posterOperation start];
                }
                
                
                // Casts
                dispatch_group_enter(group);
                [[OnlineMovieDatabase sharedMovieDatabase] getMovieCastsForMovieID:[NSNumber numberWithInt:serverId] completion:^(NSDictionary *returnArray) {
                    
                    NSArray *casts = [returnArray objectForKeyOrNil:@"cast"];
                    NSArray *crew = [returnArray objectForKeyOrNil:@"crew"];
                    NSMutableSet *castsSet = [NSMutableSet set];
                    NSMutableSet *crewSet = [NSMutableSet set];
                    
                    for (NSDictionary *castDict in casts) {
                        Cast *newCast = [Cast insertInManagedObjectContext:context];
                        newCast.character = [castDict objectForKeyOrNil:@"character"];
                        newCast.castID = [NSNumber numberWithInt:[[castDict objectForKeyOrNil:@"id"] intValue]];
                        newCast.name = [castDict objectForKeyOrNil:@"name"];
                        newCast.order = [NSNumber numberWithInt:[[castDict objectForKeyOrNil:@"order"] intValue]];
                        newCast.profilePath = [castDict objectForKeyOrNil:@"profile_path"];
                        [castsSet addObject:newCast];
                    }
                    
                    for (NSDictionary *crewDict in crew) {
                        Crew *newCrew = [Crew insertInManagedObjectContext:context];
                        newCrew.crewID = [NSNumber numberWithInt:[[crewDict objectForKeyOrNil:@"id"] intValue]];
                        newCrew.name = [crewDict objectForKeyOrNil:@"name"];
                        newCrew.department = [crewDict objectForKeyOrNil:@"department"];
                        newCrew.job = [crewDict objectForKeyOrNil:@"job"];
                        newCrew.profilePath = [crewDict objectForKeyOrNil:@"profile_path"];
                        [crewSet addObject:newCrew];
                    }
                    
                    movie.casts = castsSet;
                    movie.crews = crewSet;
                    dispatch_group_leave(group);
                } failure:^(NSError *aError) {
                    runtimeError = aError;
                    dispatch_group_leave(group);
                }];
                
                // Trailers
                dispatch_group_enter(group);
                [[OnlineMovieDatabase sharedMovieDatabase] getMovieTrailersForMovieID:[NSNumber numberWithInt:serverId] completion:^(NSDictionary *returnArray) {
                    
                    NSArray *quicktime = [returnArray objectForKeyOrNil:@"quicktime"];
                    NSArray *youtube = [returnArray objectForKeyOrNil:@"youtube"];
                    NSMutableSet *trailerSet = [NSMutableSet set];
                    
                    for (NSDictionary *qtTrailer in quicktime) {
                        Trailer *newTrailer = [Trailer insertInManagedObjectContext:context];
                        newTrailer.name = [qtTrailer objectForKeyOrNil:@"name"];
                        newTrailer.source = @"quicktime";
                        NSString *storedSize = nil;
                        for (NSDictionary *newTrailerSource in [qtTrailer objectForKeyOrNil:@"sources"]) {
                            
                            if(!storedSize || ([storedSize isEqualToString:@"480p"] && [[newTrailerSource objectForKeyOrNil:@"size"] isEqualToString:@"720p"])) {
                                newTrailer.url = [newTrailerSource objectForKeyOrNil:@"source"];
                                newTrailer.quality = [newTrailerSource objectForKeyOrNil:@"size"];
                            } else {
                                break;
                            }
                            storedSize = [newTrailerSource objectForKeyOrNil:@"size"];
                        }
                        [trailerSet addObject:newTrailer];
                    }
                    
                    for (NSDictionary *ytTrailer in youtube) {
                        Trailer *newTrailer = [Trailer insertInManagedObjectContext:context];
                        newTrailer.name = [ytTrailer objectForKeyOrNil:@"name"];
                        newTrailer.source = @"youtube";
                        newTrailer.quality = [ytTrailer objectForKeyOrNil:@"size"];
                        newTrailer.url = [ytTrailer objectForKeyOrNil:@"source"];
                        [trailerSet addObject:newTrailer];
                    }
                    
                    movie.trailers = trailerSet;
                    dispatch_group_leave(group);
                } failure:^(NSError *aError) {
                    runtimeError = aError;
                    dispatch_group_leave(group);
                }];
                
                
                
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                dispatch_release(group);
                
                if(!runtimeError) {
                    [context save:nil];
                    completionBlock(movie);
                } else {
                    failureBlock(runtimeError);
                }    
                
            } else {
                NSError *existsError = [[NSError alloc] initWithDomain:kBridgeErrorDomain code:BridgeErrorMovieExists userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Movie with this ID already exists", NSLocalizedDescriptionKey, nil]];
                failureBlock(existsError);
            }
            
        });
    } failure:^(NSError *aError) {
        failureBlock(aError);
    }];
}

@end
