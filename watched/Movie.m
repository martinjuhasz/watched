#import "Movie.h"
#import "Trailer.h"
#import "NSDictionary+ObjectForKeyOrNil.h"


@interface Movie()
- (NSString*)pathForSavedImage:(UIImage*)aImage inDirectory:(NSString*)aDir;
@end


@implementation Movie

@synthesize backdrop;
@synthesize poster;
@synthesize releaseDateFormatted;

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

-(UIImage*)poster
{
    [self willAccessValueForKey:@"poster"];

    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    NSString *pathString = [documentsDirectory stringByAppendingPathComponent:self.posterPath];
    
    UIImage *returnImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:pathString]];
    
    [self didAccessValueForKey:@"poster"];
    return returnImage;
}

-(UIImage*)backdrop
{
    [self willAccessValueForKey:@"backdrop"];
    
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    NSString *pathString = [documentsDirectory stringByAppendingPathComponent:self.backdropPath];
    
    UIImage *returnImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:pathString]];
    
    [self didAccessValueForKey:@"backdrop"];
    return returnImage;
}


- (void)setPoster:(UIImage *)aPoster
{
    [self willChangeValueForKey:@"poster"];
    
    NSString *aPosterPath = [self pathForSavedImage:aPoster inDirectory:@"posters"];
    self.posterPath = aPosterPath;
    
    [self didChangeValueForKey:@"poster"];
}

- (void)setBackdrop:(UIImage *)aBackdrop
{
    [self willChangeValueForKey:@"backdrop"];
    
    NSString *aBackdropPath = [self pathForSavedImage:aBackdrop inDirectory:@"backdrops"];
    self.backdropPath = aBackdropPath;
    
    [self didChangeValueForKey:@"backdrop"];
}

- (NSString*)pathForSavedImage:(UIImage*)aImage inDirectory:(NSString*)aDir
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    NSString *uniqueString = [NSString stringWithFormat:@"%@",(__bridge NSString *)uuidString];
    CFRelease(uuidString);
    
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    NSString *aDirPath = [documentsDirectory stringByAppendingPathComponent:aDir];
    NSString *aImagePath = [NSString stringWithFormat:@"%@/%@.jpg",aDir, uniqueString];
    NSString *pathString = [NSString stringWithFormat:@"%@/%@.jpg",aDirPath, uniqueString];
    
    // check if dir exists, else create
    if(![[NSFileManager defaultManager] fileExistsAtPath:aDirPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:aDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSData *imageData = UIImageJPEGRepresentation(aImage, 90);
    [imageData writeToFile:pathString atomically:YES];
    return aImagePath;
}

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
    return [youtubeTrailers objectAtIndex:0];
}

@end
