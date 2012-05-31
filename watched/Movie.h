#import "_Movie.h"

@class Trailer;

@interface Movie : _Movie {}

@property (nonatomic, strong) UIImage *backdrop;
@property (nonatomic, strong) UIImage *poster;
@property (readonly, nonatomic) NSString *releaseDateFormatted;
@property (readonly, nonatomic) Trailer *bestTrailer;

+ (Movie *)movieWithServerId:(NSInteger)serverId usingManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)updateAttributes:(NSDictionary *)attributes;

@end
