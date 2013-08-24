#import "_Movie.h"

@class MJUTrailer;
@class SearchResult;

typedef void (^MJUTrailersCompletionBlock)(NSArray *);
typedef void (^MJUTrailerCompletionBlock)(MJUTrailer *);
typedef void (^MJUPersonsCompletionBlock)(NSArray *casts, NSArray *crews);
typedef void (^MJUMovieErrorBlock)(NSError *);

@interface Movie : _Movie {}

@property (nonatomic, strong) UIImage *backdrop;
@property (nonatomic, strong) UIImage *poster;
@property (nonatomic, strong) UIImage *posterThumbnail;
@property (readonly, nonatomic) NSString *releaseDateFormatted;
@property (readonly, nonatomic) NSString *runtimeFormatted;
@property (nonatomic, strong)  NSArray *trailers;
@property (nonatomic, strong)  NSArray *casts;
@property (nonatomic, strong)  NSArray *crews;

+ (Movie *)movieWithMovieID:(NSNumber*)movieID usingManagedObjectContext:(NSManagedObjectContext *)moc;
+ (BOOL)movieWithServerIDExists:(NSInteger)serverID usingManagedObjectContext:(NSManagedObjectContext *)moc;
- (void)updateAttributes:(NSDictionary *)attributes;
- (void)getTrailersWithCompletion:(MJUTrailersCompletionBlock)completion error:(MJUMovieErrorBlock)error;
- (void)getBestTrailerWithCompletion:(MJUTrailerCompletionBlock)completion error:(MJUMovieErrorBlock)error;
-(void)getPersonsWithCompletion:(MJUPersonsCompletionBlock)completion error:(MJUMovieErrorBlock)error;

@end
