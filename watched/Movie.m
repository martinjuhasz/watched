#import "Movie.h"
#import "MJUTrailer.h"
#import "NSDictionary+ObjectForKeyOrNil.h"
#import "OnlineMovieDatabase.h"
#import "AFJSONRequestOperation.h"
#import "MJUPerson.h"
#import "SearchResult.h"

#define kBackdropFolder @"backdrops"
#define kPosterFolder @"posters"
#define kPosterThumbnailFolder @"thumbnailPosters"

@interface Movie() {
    BOOL trailersQueried;
    BOOL personsQueried;
}

@end


@implementation Movie

@synthesize backdrop;
@synthesize poster;
@synthesize releaseDateFormatted;
@synthesize runtimeFormatted;
@synthesize trailers;
@synthesize casts;
@synthesize crews;



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark General

+ (Movie *)movieWithMovieID:(NSNumber*)movieID usingManagedObjectContext:(NSManagedObjectContext *)moc {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Movie entityName]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"movieID = %d", [movieID integerValue]]];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"ERROR: %@ %@", [error localizedDescription], [error userInfo]);
        exit(1);
    }
    
    if ([results count] == 0) {
        return nil;
    }
    
    return [results objectAtIndex:0];
}

+ (BOOL)movieWithServerIDExists:(NSInteger)serverID usingManagedObjectContext:(NSManagedObjectContext *)moc {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Movie entityName]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"movieID = %d", serverID]];
    [fetchRequest setFetchLimit:1];
    
    
    NSError *error = nil;
    NSUInteger count = [moc countForFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"ERROR: %@ %@", [error localizedDescription], [error userInfo]);
        exit(1);
    }
    
    if (!error && count > 0){
        return YES;
    }
    else {
        return NO;
    }
}

- (void)prepareForDeletion
{
    [super prepareForDeletion];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    
    NSString *backdropPath = [self pathForImage:self.backdropPath inDirectory:kBackdropFolder];
    NSString *posterPath = [self pathForImage:self.posterPath inDirectory:kPosterFolder];
    NSString *posterThumbnailPath = [self pathForImage:self.posterPath inDirectory:kPosterThumbnailFolder];
    
    NSError *error;
    if (![fileMgr removeItemAtPath:backdropPath error:&error])
        DebugLog("Unable to delete file: %@", [error localizedDescription]);
    if (![fileMgr removeItemAtPath:posterPath error:&error])
        DebugLog("Unable to delete file: %@", [error localizedDescription]);
    if (![fileMgr removeItemAtPath:posterThumbnailPath error:&error])
        DebugLog("Unable to delete file: %@", [error localizedDescription]);
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark automated Filling

- (void)updateAttributes:(NSDictionary *)attributes {
    self.adult = [attributes objectForKeyOrNil:@"adult"];
	self.budget = [attributes objectForKeyOrNil:@"budget"];
	self.imdbID = [attributes objectForKeyOrNil:@"imdb_id"];
	self.movieID = [NSNumber numberWithInt:[[attributes objectForKeyOrNil:@"id"] intValue]];
	self.originalTitle = [attributes objectForKeyOrNil:@"original_title"];
	self.overview = [attributes objectForKeyOrNil:@"overview"];
	self.popularity = [NSNumber numberWithInt:[[attributes objectForKeyOrNil:@"popularity"] intValue]];
	self.revenue = [NSNumber numberWithFloat:[[attributes objectForKeyOrNil:@"revenue"] floatValue]];
	self.runtime = [NSNumber numberWithFloat:[[attributes objectForKeyOrNil:@"runtime"] floatValue]];
	self.tagline = [attributes objectForKeyOrNil:@"tagline"];
	self.title = [attributes objectForKeyOrNil:@"title"];
    
    if([attributes objectForKeyOrNil:@"homepage"] && ![[attributes objectForKeyOrNil:@"homepage"] isEqualToString:@""]) {
        self.homepage = [attributes objectForKeyOrNil:@"homepage"];
    }
    
    // release Date
    if([attributes objectForKeyOrNil:@"release_date"]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-DD"];
        self.releaseDate = [dateFormatter dateFromString:[attributes objectForKey:@"release_date"]];
    }
    
    //self.posterPath = [attributes objectForKeyOrNil:@"poster_path"];
    //self.backdropPath = [attributes objectForKeyOrNil:@"backdrop_path"];
	//self.releaseDate = [attributes objectForKeyOrNil:@"adult"];
    
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Images

-(UIImage*)poster
{
    [self willAccessValueForKey:@"poster"];
    
    NSString *pathString = [self pathForImage:self.posterPath inDirectory:kPosterFolder];
    UIImage *returnImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:pathString]];
    
    [self didAccessValueForKey:@"poster"];
    return returnImage;
}

-(UIImage*)posterThumbnail
{
    [self willAccessValueForKey:@"posterThumbnail"];
    
    NSString *pathString = [self pathForImage:self.posterPath inDirectory:kPosterThumbnailFolder];
    UIImage *returnImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:pathString]];
    
    [self didAccessValueForKey:@"posterThumbnail"];
    return returnImage;
}

-(UIImage*)backdrop
{
    [self willAccessValueForKey:@"backdrop"];
    
    NSString *pathString = [self pathForImage:self.backdropPath inDirectory:kBackdropFolder];
    UIImage *returnImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:pathString]];
    
    [self didAccessValueForKey:@"backdrop"];
    return returnImage;
}


- (void)setPoster:(UIImage *)aPoster
{
    [self willChangeValueForKey:@"poster"];
    
    if(self.posterPath) {
        [self saveImage:aPoster inDirectory:kPosterFolder withName:self.posterPath];
    } else {
        NSString *aPosterPath = [self saveImage:aPoster inDirectory:kPosterFolder withName:nil];
        self.posterPath = aPosterPath;
    }

    [self didChangeValueForKey:@"poster"];
}

- (void)setPosterThumbnail:(UIImage *)posterThumbnail
{
    [self willChangeValueForKey:@"posterThumbnail"];
    
    if(self.posterPath) {
        [self saveImage:posterThumbnail inDirectory:kPosterThumbnailFolder withName:self.posterPath];
    } else {
        NSString *aPosterPath = [self saveImage:posterThumbnail inDirectory:kPosterThumbnailFolder withName:nil];
        self.posterPath = aPosterPath;
    }
    
    [self didChangeValueForKey:@"posterThumbnail"];
}

- (void)setBackdrop:(UIImage *)aBackdrop
{
    [self willChangeValueForKey:@"backdrop"];
    
    if(self.backdropPath) {
        [self saveImage:aBackdrop inDirectory:kBackdropFolder withName:self.backdropPath];
    } else {
        NSString *aBackdropPath = [self saveImage:aBackdrop inDirectory:kBackdropFolder withName:nil];
        self.backdropPath = aBackdropPath;
    }
    
    [self didChangeValueForKey:@"backdrop"];
}

- (NSString*)saveImage:(UIImage*)aImage inDirectory:(NSString*)aDir withName:(NSString*)aName
{
    // Create unique String
    if(!aName) {
        CFUUIDRef uuid = CFUUIDCreate(NULL);
        CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
        CFRelease(uuid);
        aName = [NSString stringWithFormat:@"%@.jpg",(__bridge NSString *)uuidString];
        CFRelease(uuidString);
    }
    
    // Add extention and get full path
    NSString *pathString = [self pathForImage:aName inDirectory:aDir];
    
    // Save Image
    NSData *imageData = UIImageJPEGRepresentation(aImage, 90);
    [imageData writeToFile:pathString atomically:YES];
    return aName;
}

- (NSString*)pathForImage:(NSString*)aImage inDirectory:(NSString*)aDir
{
    // Get documents Dir
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];

    NSString *aDirPath = [documentsDirectory stringByAppendingPathComponent:aDir];
    NSString *pathString = [NSString stringWithFormat:@"%@/%@",aDirPath, aImage];
    
    // check if dir exists, else create
    if(![[NSFileManager defaultManager] fileExistsAtPath:aDirPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:aDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return pathString;
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Ghost Attributes

-(NSString*)releaseDateFormatted
{
    [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSString *releaseString = [NSDateFormatter localizedStringFromDate:self.releaseDate 
                                                             dateStyle:NSDateFormatterMediumStyle 
                                                             timeStyle:NSDateFormatterNoStyle];
    return releaseString;
}

-(NSString*)runtimeFormatted
{
    int hours = (int)floorf([self.runtime floatValue] / 60.0f);
    int minutes = [self.runtime intValue] % 60;
    NSString *returnString = [NSString stringWithFormat:@"0%@",NSLocalizedString(@"MINUTES_MIN", nil)];
    if(hours > 0 && minutes > 0) {
        returnString = [NSString stringWithFormat:@"%d%@ %d%@",hours, NSLocalizedString(@"HOURS_MIN", nil), minutes, NSLocalizedString(@"MINUTES_MIN", nil)];
    } else if(hours > 0 && minutes <= 0) {
        returnString = [NSString stringWithFormat:@"%d%@",hours, NSLocalizedString(@"HOURS_MIN", nil)];
    } else if (hours <= 0 && minutes > 0) {
        returnString = [NSString stringWithFormat:@"%d%@",minutes, NSLocalizedString(@"MINUTES_MIN", nil)];
    }
    return returnString;
}

- (NSArray*)trailers
{
    if(!trailersQueried) {
        [self getTrailersWithCompletion:nil error:nil];
    }
    return trailers;
}

- (void)getTrailersWithCompletion:(MJUTrailersCompletionBlock)completion error:(MJUMovieErrorBlock)error
{
    if(trailersQueried) {
        completion(trailers);
        return;
    }
    trailersQueried = YES;
    
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getMovieTrailersForMovieID:self.movieID completion:^(NSArray *trailerArray) {
        trailers = trailerArray;
        completion(trailers);
    } failure:^(NSError *aError) {
        trailersQueried = NO;
        error(aError);
    }];
    [operation start];
}

- (void)getBestTrailerWithCompletion:(MJUTrailerCompletionBlock)completion error:(MJUMovieErrorBlock)error
{
    [self getTrailersWithCompletion:^(NSArray *trailerArray) {
        MJUTrailer *bestTrailer = nil;
        for (MJUTrailer *aTrailer in trailerArray) {
            if(aTrailer.type == MJUTrailerTypeQuicktime) {
                if(!bestTrailer || (bestTrailer.size == MJUTrailerQualitySD && aTrailer.size == MJUTrailerQualityHD)) {
                    bestTrailer = aTrailer;
                }
            }
        }
        
        if(!bestTrailer) {
            for (MJUTrailer *aTrailer in trailerArray) {
                if(!bestTrailer || (bestTrailer.size == MJUTrailerQualitySD && aTrailer.size == MJUTrailerQualityHD)) {
                    bestTrailer = aTrailer;
                }
            }
        }
        completion(bestTrailer);
    } error:^(NSError *aError) {
        error(aError);
    }];
}


//- (NSArray*)casts
//{
//    if(!personsQueried) {
//        [self getPersonsWithCompletion:nil error:nil];
//    }
//    return casts;
//}
//
//- (NSArray*)crews
//{
//    if(!personsQueried) {
//        [self getPersonsWithCompletion:nil error:nil];
//    }
//    return crews;
//}

-(void)getPersonsWithCompletion:(MJUPersonsCompletionBlock)completion error:(MJUMovieErrorBlock)error
{
    if(personsQueried) {
        completion(casts,crews);
        return;
    }
    personsQueried = YES;
    
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getPersonsForMovieID:self.movieID completion:^(NSArray *castsArray, NSArray *crewsArray) {
        
        NSSortDescriptor *sortCastDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        NSArray *sortedCastsArray = [castsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortCastDescriptor]];
        casts = sortedCastsArray;
        
        NSSortDescriptor *sortCrewDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray *sortedCrewArray = [crewsArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortCrewDescriptor]];
        crews = sortedCrewArray;
        
        // Direcor
        self.director = [self getDirectorFromCrew].name;
        
       
        // Actors
        NSMutableArray *actors = [NSMutableArray array];
        NSUInteger maxSize = 4;
        for (int i = 0; i<[casts count] && i < maxSize; i++) {
            [actors addObject:[casts objectAtIndex:i]];
        }
        self.actors = [NSKeyedArchiver archivedDataWithRootObject:actors];
        
        completion(casts,crews);
        
    } failure:^(NSError *aError) {
        personsQueried = NO;
        error(aError);
    }];
    [operation start];
}


//- (MJUTrailer*)bestTrailer
//{
//    [self getTrailersWithCompletion:^(NSArray *) {
//        
//        
//    } error:^(NSError *error) {
//        return nil;
//    }];
//    
//    
//    // try to get a quicktime one
//    NSPredicate *qtPredicate = [NSPredicate predicateWithFormat:@"source == %@", @"quicktime"];
//    NSArray *quicktimeTrailers = [[self.trailers allObjects] filteredArrayUsingPredicate:qtPredicate];
//    if(quicktimeTrailers.count > 0) {
//        return [quicktimeTrailers objectAtIndex:0];
//    }
//    
//    // sort HD before SD
//    NSSortDescriptor *ytSortDestcriptor = [NSSortDescriptor sortDescriptorWithKey:@"quality" ascending:YES];
//    NSArray *youtubeTrailers = [[self.trailers allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:ytSortDestcriptor]];
//    if(youtubeTrailers.count > 0) {
//        return [youtubeTrailers objectAtIndex:0];
//    }
//    return nil;
//}
//
//- (NSArray*)sortedCasts
//{
//    NSSortDescriptor *sortCastDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
//    NSArray *sortedCastsArray = [[self.casts allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortCastDescriptor]];
//    return sortedCastsArray;
//}
//
//- (NSArray*)sortedCrews
//{
//    NSSortDescriptor *sortCrewDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
//    NSArray *sortedCrewArray = [[self.crews allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortCrewDescriptor]];
//    return sortedCrewArray;
//}
//
- (MJUPerson*)getDirectorFromCrew
{
    // try to get a quicktime one
    NSPredicate *dirPredicate = [NSPredicate predicateWithFormat:@"job ==[c] %@", @"Director"];
    NSArray *directors = [self.crews filteredArrayUsingPredicate:dirPredicate];
    if(directors.count > 0) {
        return [directors objectAtIndex:0];
    }
    return nil;
}


@end
