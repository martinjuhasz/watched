#import "_Movie.h"

@class Trailer;
@class Crew;

@interface Movie : _Movie {}

@property (nonatomic, strong) UIImage *backdrop;
@property (nonatomic, strong) UIImage *poster;
@property (nonatomic, strong) UIImage *posterThumbnail;
@property (readonly, nonatomic) NSString *releaseDateFormatted;
@property (readonly, nonatomic) NSString *runtimeFormatted;
@property (readonly, nonatomic) Trailer *bestTrailer;
@property (readonly, nonatomic) NSArray *sortedCasts;
@property (readonly, nonatomic) NSArray *sortedCrews;
@property (readonly, nonatomic) Crew *director;

+ (Movie *)movieWithServerId:(NSInteger)serverId usingManagedObjectContext:(NSManagedObjectContext *)moc;
+ (BOOL)movieWithServerIDExists:(NSInteger)serverID usingManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)updateAttributes:(NSDictionary *)attributes;

@end
