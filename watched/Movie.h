#import "_Movie.h"

@interface Movie : _Movie {}

@property(nonatomic, strong) UIImage *backdrop;
@property(nonatomic, strong) UIImage *poster;

+ (Movie *)movieWithServerId:(NSInteger)serverId usingManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)updateAttributes:(NSDictionary *)attributes;

@end
