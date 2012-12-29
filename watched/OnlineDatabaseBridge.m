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
#import "AFJSONRequestOperation.h"


@interface OnlineDatabaseBridge()
@end

@implementation OnlineDatabaseBridge



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initial Creation


- (void)saveSearchResultDictAsMovie:(NSDictionary *)movieDict completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock
{
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
            dispatch_group_enter(group);
            [self setBackdropWithImagePath:backdropString toMovie:movie success:^{
                dispatch_group_leave(group);
            } failure:^(NSError *aError) {
                dispatch_group_leave(group);
            }];
            
            // Poster
            NSString *posterString = [movieDict objectForKey:@"poster_path"];
            dispatch_group_enter(group);
            [self setPosterWithImagePath:posterString toMovie:movie success:^{
                dispatch_group_leave(group);
            } failure:^(NSError *aError) {
                dispatch_group_leave(group);
            }];
            
            // Casts
            dispatch_group_enter(group);
            [self setCastsToMovie:movie success:^{
                dispatch_group_leave(group);
            } failure:^(NSError *aError) {
                runtimeError = aError;
                dispatch_group_leave(group);
            }];
            
            // Trailers
            dispatch_group_enter(group);
            [self setTrailersToMovie:movie success:^{
                dispatch_group_leave(group);
            } failure:^(NSError *aError) {
                runtimeError = aError;
                dispatch_group_leave(group);
            }];
            
            
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            
            if(!runtimeError) {
                [context save:nil];
                aCompletionBlock(movie);
            } else {
                aFailureBlock(runtimeError);
            }    
            
        } else {
            NSError *existsError = [[NSError alloc] initWithDomain:kBridgeErrorDomain code:BridgeErrorMovieExists userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Movie with this ID already exists", NSLocalizedDescriptionKey, nil]];
            aFailureBlock(existsError);
        }
        
    });
}

- (AFJSONRequestOperation*)saveSearchResultAsMovie:(SearchResult*)result completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock
{
    AFJSONRequestOperation *operation = nil;
    operation = [self saveMovieForID:result.searchResultId completion:^(Movie *aMovie) {
        aCompletionBlock(aMovie);
    } failure:^(NSError *anError) {
        aFailureBlock(anError);
    }];
    return operation;
    
//    [[OnlineMovieDatabase sharedMovieDatabase] getMovieDetailsForMovieID:result.searchResultId completion:^(NSDictionary *movieDict) {
//        [self saveSearchResultDictAsMovie:movieDict completion:^(Movie *aMovie) {
//            aCompletionBlock(aMovie);
//        } failure:^(NSError *aError) {
//            aFailureBlock(aFailureBlock);
//        }];
//    } failure:^(NSError *aError) {
//        aFailureBlock(aError);
//    }];
}

- (AFJSONRequestOperation*)saveMovieForID:(NSNumber*)movieID completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock
{
    AFJSONRequestOperation *operation = nil;
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:[[MoviesDataModel sharedDataModel] persistentStoreCoordinator]];
    Movie *movie = [Movie movieWithServerId:[movieID intValue] usingManagedObjectContext:context];
    if (!movie) {
        operation = [[OnlineMovieDatabase sharedMovieDatabase] getMovieDetailsForMovieID:movieID completion:^(NSDictionary *movieDict) {
            [self saveSearchResultDictAsMovie:movieDict completion:^(Movie *aMovie) {
                aCompletionBlock(aMovie);
            } failure:^(NSError *aError) {
                aFailureBlock(aFailureBlock);
            }];
        } failure:^(NSError *aError) {
            aFailureBlock(aError);
        }];
    } else {
        NSError *existsError = [[NSError alloc] initWithDomain:kBridgeErrorDomain code:BridgeErrorMovieExists userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Movie with this ID already exists", NSLocalizedDescriptionKey, nil]];
        aFailureBlock(existsError);
//            aFailureBlock(nil);
    }
    return operation;
}




////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Updating Data

- (AFJSONRequestOperation*)updateMovieMetadata:(Movie*)aMovie inContext:(NSManagedObjectContext*)aContext completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock
{
    NSSet *oldCasts = aMovie.casts;
    NSSet *oldCrew = aMovie.crews;
    NSSet *oldTrailers = aMovie.trailers;
    
    AFJSONRequestOperation *operation = nil;
//    
//    for (Cast *aCast in oldCasts) {
//        [aMovie.managedObjectContext deleteObject:aCast];
//    }
//    
//    for (Crew *aCrew in oldCrew) {
//        [aMovie.managedObjectContext deleteObject:aCrew];
//    }
//    
//    for (Trailer *aTrailer in oldTrailers) {
//        [aMovie.managedObjectContext deleteObject:aTrailer];
//    }
//    aCompletionBlock(aMovie);
    
    operation = [[OnlineMovieDatabase sharedMovieDatabase] getMovieDetailsForMovieID:aMovie.movieID completion:^(NSDictionary *movieDict) {
        [self updateMovie:aMovie withSearchResultDict:movieDict completion:^(Movie *returnedMovie) {
            for (Cast *aCast in oldCasts) {
                [aContext deleteObject:aCast];
            }
            
            for (Crew *aCrew in oldCrew) {
                [aContext deleteObject:aCrew];
            }
            
            for (Trailer *aTrailer in oldTrailers) {
                [aContext deleteObject:aTrailer];
            }
            aCompletionBlock(returnedMovie);
        } failure:^(NSError *anError) {
            aFailureBlock(anError);
        }];
    } failure:^(NSError *aError) {
        aFailureBlock(aError);
    }];
    
    return operation;
}

- (void)updateMovie:(Movie*)movie withSearchResultDict:(NSDictionary*)movieDict completion:(OnlineBridgeCompletionBlock)aCompletionBlock failure:(OnlineBridgeFailureBlock)aFailureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // Setup Core Data with extra Context for Background Process
        __block NSError *runtimeError = nil;
        
        if(movie != nil) {
            
            // dispatch it
            dispatch_group_t group = dispatch_group_create();
            
            // Movie
            [movie updateAttributes:movieDict];
            
            // Casts
            dispatch_group_enter(group);
            [self setCastsToMovie:movie success:^{
                dispatch_group_leave(group);
            } failure:^(NSError *aError) {
                runtimeError = aError;
                dispatch_group_leave(group);
            }];
            
            // Trailers
            dispatch_group_enter(group);
            [self setTrailersToMovie:movie success:^{
                dispatch_group_leave(group);
            } failure:^(NSError *aError) {
                runtimeError = aError;
                dispatch_group_leave(group);
            }];
            
            // wait until everything is finished
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            
            if(!runtimeError) {
                aCompletionBlock(movie);
            } else {
                aFailureBlock(runtimeError);
            }    
            
        } else {
            NSError *existsError = [[NSError alloc] initWithDomain:kBridgeErrorDomain code:BridgeErrorMovieDoesntExist userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Movie does not exists", NSLocalizedDescriptionKey, nil]];
            aFailureBlock(existsError);
        }
    });
}




////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Single Attributes


- (void)setBackdropWithImagePath:(NSString*)imagePath toMovie:(Movie*)aMovie success:(void (^)(void))successBlock failure:(OnlineBridgeFailureBlock)aFailureBlock
{
    NSURL *backdropURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:imagePath imageType:ImageTypeBackdrop nearWidth:800.0f];
    if(!backdropURL) {
        NSError *aFailureError = [[NSError alloc] initWithDomain:kBridgeErrorDomain code:BridgeErrorNoBackdropImageFoundForURL userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"No Backdrop image found for BackdropURL", NSLocalizedDescriptionKey, nil]];
        aFailureBlock(aFailureError);
        return;
    }

    NSURLRequest *backdropRequest = [NSURLRequest requestWithURL:backdropURL];
    AFHTTPRequestOperation *backdropOperation = [[AFHTTPRequestOperation alloc] initWithRequest:backdropRequest];
    [backdropOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject isKindOfClass:[NSData class]]) {
            aMovie.backdrop = [UIImage imageWithData:responseObject];
            aMovie.backdropURL = imagePath;
            successBlock();
        } else {
            NSError *aFailureError = [[NSError alloc] initWithDomain:kBridgeErrorDomain code:BridgeErrorNoBackdropImageFoundForURL userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"No Backdrop image found for BackdropURL", NSLocalizedDescriptionKey, nil]];
            aFailureBlock(aFailureError);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        aFailureBlock(error);
    }];
    [backdropOperation start];
}

- (void)setPosterWithImagePath:(NSString*)imagePath toMovie:(Movie*)aMovie success:(void (^)(void))successBlock failure:(OnlineBridgeFailureBlock)aFailureBlock
{
    NSURL *posterURL = [[OnlineMovieDatabase sharedMovieDatabase] getImageURLForImagePath:imagePath imageType:ImageTypePoster nearWidth:260.0f];
    if(!posterURL) {
        NSError *aFailureError = [[NSError alloc] initWithDomain:kBridgeErrorDomain code:BridgeErrorNoPosterImageFoundForURL userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"No Poster image found for PosterURL", NSLocalizedDescriptionKey, nil]];
        aFailureBlock(aFailureError);
        return;
    }
    
    NSURLRequest *posterRequest = [NSURLRequest requestWithURL:posterURL];
    AFHTTPRequestOperation *backdropOperation = [[AFHTTPRequestOperation alloc] initWithRequest:posterRequest];
    [backdropOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([responseObject isKindOfClass:[NSData class]]) {

            
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
            
            aMovie.poster = poster;
            aMovie.posterURL = imagePath;
            aMovie.posterThumbnail = thumbPoster;
            
            successBlock();

        } else {
            NSError *aFailureError = [[NSError alloc] initWithDomain:kBridgeErrorDomain code:BridgeErrorNoBackdropImageFoundForURL userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"No Poster image found for PosterURL", NSLocalizedDescriptionKey, nil]];
            aFailureBlock(aFailureError);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        aFailureBlock(error);
    }];
    [backdropOperation start];
}

- (void)setCastsToMovie:(Movie*)aMovie success:(void (^)(void))successBlock failure:(OnlineBridgeFailureBlock)aFailureBlock
{
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getMovieCastsForMovieID:aMovie.movieID completion:^(NSDictionary *returnArray) {
        
        NSArray *casts = [returnArray objectForKeyOrNil:@"cast"];
        NSArray *crew = [returnArray objectForKeyOrNil:@"crew"];
        NSMutableSet *castsSet = [NSMutableSet set];
        NSMutableSet *crewSet = [NSMutableSet set];
        
        for (NSDictionary *castDict in casts) {
            Cast *newCast = [Cast insertInManagedObjectContext:aMovie.managedObjectContext];
            newCast.character = [castDict objectForKeyOrNil:@"character"];
            newCast.castID = [NSNumber numberWithInt:[[castDict objectForKeyOrNil:@"id"] intValue]];
            newCast.name = [castDict objectForKeyOrNil:@"name"];
            newCast.order = [NSNumber numberWithInt:[[castDict objectForKeyOrNil:@"order"] intValue]];
            newCast.profilePath = [castDict objectForKeyOrNil:@"profile_path"];
            [castsSet addObject:newCast];
        }
        
        for (NSDictionary *crewDict in crew) {
            Crew *newCrew = [Crew insertInManagedObjectContext:aMovie.managedObjectContext];
            newCrew.crewID = [NSNumber numberWithInt:[[crewDict objectForKeyOrNil:@"id"] intValue]];
            newCrew.name = [crewDict objectForKeyOrNil:@"name"];
            newCrew.department = [crewDict objectForKeyOrNil:@"department"];
            newCrew.job = [crewDict objectForKeyOrNil:@"job"];
            newCrew.profilePath = [crewDict objectForKeyOrNil:@"profile_path"];
            [crewSet addObject:newCrew];
        }
        
        aMovie.casts = castsSet;
        aMovie.crews = crewSet;
        successBlock();
    } failure:^(NSError *aError) {
        aFailureBlock(aError);
    }];
    [operation start];
}

- (void)setTrailersToMovie:(Movie*)aMovie success:(void (^)(void))successBlock failure:(OnlineBridgeFailureBlock)aFailureBlock
{
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getMovieTrailersForMovieID:aMovie.movieID completion:^(NSDictionary *returnArray) {
        
        NSArray *quicktime = [returnArray objectForKeyOrNil:@"quicktime"];
        NSArray *youtube = [returnArray objectForKeyOrNil:@"youtube"];
        NSMutableSet *trailerSet = [NSMutableSet set];
        
        for (NSDictionary *qtTrailer in quicktime) {
            Trailer *newTrailer = [Trailer insertInManagedObjectContext:aMovie.managedObjectContext];
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
            Trailer *newTrailer = [Trailer insertInManagedObjectContext:aMovie.managedObjectContext];
            newTrailer.name = [ytTrailer objectForKeyOrNil:@"name"];
            newTrailer.source = @"youtube";
            newTrailer.quality = [ytTrailer objectForKeyOrNil:@"size"];
            newTrailer.url = [ytTrailer objectForKeyOrNil:@"source"];
            [trailerSet addObject:newTrailer];
        }
        
        aMovie.trailers = trailerSet;
        successBlock();
    } failure:^(NSError *aError) {
        aFailureBlock(aError);
    }];
    [operation start];
}


@end
