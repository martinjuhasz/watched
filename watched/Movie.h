#import "_Movie.h"

@interface Movie : _Movie {}

+ (Movie *)movieWithServerId:(NSInteger)serverId usingManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)updateAttributes:(NSDictionary *)attributes;

@end
