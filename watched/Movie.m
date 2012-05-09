#import "Movie.h"
#import "NSDictionary+ObjectForKeyOrNil.h"

@implementation Movie

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
    self.backdropPath = [attributes objectForKeyOrNil:@"backdrop_path"];
	self.budget = [attributes objectForKeyOrNil:@"budget"];
	self.homepage = [attributes objectForKeyOrNil:@"homepage"];
	self.imdbID = [attributes objectForKeyOrNil:@"imdb_id"];
	self.movieID = [NSNumber numberWithInt:[[attributes objectForKeyOrNil:@"id"] intValue]];
	self.originalTitle = [attributes objectForKeyOrNil:@"original_title"];
	self.overview = [attributes objectForKeyOrNil:@"overview"];
	self.popularity = [NSNumber numberWithInt:[[attributes objectForKeyOrNil:@"popularity"] intValue]];
	self.posterPath = [attributes objectForKeyOrNil:@"poster_path"];
	//self.releaseDate = [attributes objectForKeyOrNil:@"adult"];
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
    
}


@end
