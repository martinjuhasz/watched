#import "Movie.h"
#import "Trailer.h"
#import "NSDictionary+ObjectForKeyOrNil.h"


@interface Movie()

@end


@implementation Movie

@synthesize backdrop;
@synthesize poster;
@synthesize releaseDateFormatted;



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark General

+ (Movie *)movieWithServerId:(NSInteger)serverId usingManagedObjectContext:(NSManagedObjectContext *)moc {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[Movie entityName]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"movieID = %d", serverId]];
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



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark automated Filling

- (void)updateAttributes:(NSDictionary *)attributes {
    self.adult = [attributes objectForKeyOrNil:@"adult"];
	self.budget = [attributes objectForKeyOrNil:@"budget"];
	self.homepage = [attributes objectForKeyOrNil:@"homepage"];
	self.imdbID = [attributes objectForKeyOrNil:@"imdb_id"];
	self.movieID = [NSNumber numberWithInt:[[attributes objectForKeyOrNil:@"id"] intValue]];
	self.originalTitle = [attributes objectForKeyOrNil:@"original_title"];
	self.overview = [attributes objectForKeyOrNil:@"overview"];
	self.popularity = [NSNumber numberWithInt:[[attributes objectForKeyOrNil:@"popularity"] intValue]];
	self.revenue = [NSNumber numberWithFloat:[[attributes objectForKeyOrNil:@"revenue"] floatValue]];
	self.runtime = [NSNumber numberWithFloat:[[attributes objectForKeyOrNil:@"runtime"] floatValue]];
	self.tagline = [attributes objectForKeyOrNil:@"tagline"];
	self.title = [attributes objectForKeyOrNil:@"title"];
    
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

    NSString *pathString = [self pathForImage:self.posterPath inDirectory:@"posters"];
    UIImage *returnImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:pathString]];
    
    [self didAccessValueForKey:@"poster"];
    return returnImage;
}

-(UIImage*)posterThumbnail
{
    [self willAccessValueForKey:@"posterThumbnail"];
    
    NSString *pathString = [self pathForImage:self.posterPath inDirectory:@"thumbnailPosters"];
    UIImage *returnImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:pathString]];
    
    [self didAccessValueForKey:@"posterThumbnail"];
    return returnImage;
}

-(UIImage*)backdrop
{
    [self willAccessValueForKey:@"backdrop"];
    
    NSString *pathString = [self pathForImage:self.backdropPath inDirectory:@"backdrops"];
    UIImage *returnImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:pathString]];
    
    [self didAccessValueForKey:@"backdrop"];
    return returnImage;
}


- (void)setPoster:(UIImage *)aPoster
{
    [self willChangeValueForKey:@"poster"];
    
    if(self.posterPath) {
        [self saveImage:aPoster inDirectory:@"posters" withName:self.posterPath];
    } else {
        NSString *aPosterPath = [self saveImage:aPoster inDirectory:@"posters" withName:nil];
        self.posterPath = aPosterPath;
    }

    [self didChangeValueForKey:@"poster"];
}

- (void)setPosterThumbnail:(UIImage *)posterThumbnail
{
    [self willChangeValueForKey:@"posterThumbnail"];
    
    if(self.posterPath) {
        [self saveImage:posterThumbnail inDirectory:@"thumbnailPosters" withName:self.posterPath];
    } else {
        NSString *aPosterPath = [self saveImage:posterThumbnail inDirectory:@"thumbnailPosters" withName:nil];
        self.posterPath = aPosterPath;
    }
    
    [self didChangeValueForKey:@"posterThumbnail"];
}

- (void)setBackdrop:(UIImage *)aBackdrop
{
    [self willChangeValueForKey:@"backdrop"];
    
    NSString *aBackdropPath = [self saveImage:aBackdrop inDirectory:@"backdrops" withName:nil];
    self.backdropPath = aBackdropPath;
    
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *releaseDateString = [dateFormatter stringFromDate:self.releaseDate];
    return releaseDateString;
}

- (Trailer*)bestTrailer
{
    // try to get a quicktime one
    NSPredicate *qtPredicate = [NSPredicate predicateWithFormat:@"source == %@", @"quicktime"];
    NSArray *quicktimeTrailers = [[self.trailers allObjects] filteredArrayUsingPredicate:qtPredicate];
    if(quicktimeTrailers.count > 0) {
        return [quicktimeTrailers objectAtIndex:0];
    }
    
    // sort HD before SD
    NSSortDescriptor *ytSortDestcriptor = [NSSortDescriptor sortDescriptorWithKey:@"quality" ascending:YES];
    NSArray *youtubeTrailers = [[self.trailers allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:ytSortDestcriptor]];
    if(youtubeTrailers.count > 0) {
        return [youtubeTrailers objectAtIndex:0];
    }
    return nil;
}

- (NSArray*)sortedCasts
{
    NSSortDescriptor *sortCastDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *sortedCastsArray = [[self.casts allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortCastDescriptor]];
    return sortedCastsArray;
}

- (NSArray*)sortedCrews
{
    NSSortDescriptor *sortCrewDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    NSArray *sortedCrewArray = [[self.crews allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortCrewDescriptor]];
    return sortedCrewArray;
}

@end
