// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Movie.h instead.

#import <CoreData/CoreData.h>


extern const struct MovieAttributes {
	__unsafe_unretained NSString *adult;
	__unsafe_unretained NSString *backdropPath;
	__unsafe_unretained NSString *budget;
	__unsafe_unretained NSString *homepage;
	__unsafe_unretained NSString *imdbID;
	__unsafe_unretained NSString *movieID;
	__unsafe_unretained NSString *originalTitle;
	__unsafe_unretained NSString *overview;
	__unsafe_unretained NSString *popularity;
	__unsafe_unretained NSString *posterPath;
	__unsafe_unretained NSString *releaseDate;
	__unsafe_unretained NSString *revenue;
	__unsafe_unretained NSString *runtime;
	__unsafe_unretained NSString *tagline;
	__unsafe_unretained NSString *title;
} MovieAttributes;

extern const struct MovieRelationships {
} MovieRelationships;

extern const struct MovieFetchedProperties {
} MovieFetchedProperties;


















@interface MovieID : NSManagedObjectID {}
@end

@interface _Movie : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MovieID*)objectID;




@property (nonatomic, strong) NSNumber* adult;


@property BOOL adultValue;
- (BOOL)adultValue;
- (void)setAdultValue:(BOOL)value_;

//- (BOOL)validateAdult:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* backdropPath;


//- (BOOL)validateBackdropPath:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* budget;


@property float budgetValue;
- (float)budgetValue;
- (void)setBudgetValue:(float)value_;

//- (BOOL)validateBudget:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* homepage;


//- (BOOL)validateHomepage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* imdbID;


//- (BOOL)validateImdbID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* movieID;


@property int32_t movieIDValue;
- (int32_t)movieIDValue;
- (void)setMovieIDValue:(int32_t)value_;

//- (BOOL)validateMovieID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* originalTitle;


//- (BOOL)validateOriginalTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* overview;


//- (BOOL)validateOverview:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* popularity;


@property int64_t popularityValue;
- (int64_t)popularityValue;
- (void)setPopularityValue:(int64_t)value_;

//- (BOOL)validatePopularity:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* posterPath;


//- (BOOL)validatePosterPath:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* releaseDate;


//- (BOOL)validateReleaseDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* revenue;


@property float revenueValue;
- (float)revenueValue;
- (void)setRevenueValue:(float)value_;

//- (BOOL)validateRevenue:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* runtime;


@property float runtimeValue;
- (float)runtimeValue;
- (void)setRuntimeValue:(float)value_;

//- (BOOL)validateRuntime:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* tagline;


//- (BOOL)validateTagline:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* title;


//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;






@end

@interface _Movie (CoreDataGeneratedAccessors)

@end

@interface _Movie (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAdult;
- (void)setPrimitiveAdult:(NSNumber*)value;

- (BOOL)primitiveAdultValue;
- (void)setPrimitiveAdultValue:(BOOL)value_;




- (NSString*)primitiveBackdropPath;
- (void)setPrimitiveBackdropPath:(NSString*)value;




- (NSNumber*)primitiveBudget;
- (void)setPrimitiveBudget:(NSNumber*)value;

- (float)primitiveBudgetValue;
- (void)setPrimitiveBudgetValue:(float)value_;




- (NSString*)primitiveHomepage;
- (void)setPrimitiveHomepage:(NSString*)value;




- (NSString*)primitiveImdbID;
- (void)setPrimitiveImdbID:(NSString*)value;




- (NSNumber*)primitiveMovieID;
- (void)setPrimitiveMovieID:(NSNumber*)value;

- (int32_t)primitiveMovieIDValue;
- (void)setPrimitiveMovieIDValue:(int32_t)value_;




- (NSString*)primitiveOriginalTitle;
- (void)setPrimitiveOriginalTitle:(NSString*)value;




- (NSString*)primitiveOverview;
- (void)setPrimitiveOverview:(NSString*)value;




- (NSNumber*)primitivePopularity;
- (void)setPrimitivePopularity:(NSNumber*)value;

- (int64_t)primitivePopularityValue;
- (void)setPrimitivePopularityValue:(int64_t)value_;




- (NSString*)primitivePosterPath;
- (void)setPrimitivePosterPath:(NSString*)value;




- (NSDate*)primitiveReleaseDate;
- (void)setPrimitiveReleaseDate:(NSDate*)value;




- (NSNumber*)primitiveRevenue;
- (void)setPrimitiveRevenue:(NSNumber*)value;

- (float)primitiveRevenueValue;
- (void)setPrimitiveRevenueValue:(float)value_;




- (NSNumber*)primitiveRuntime;
- (void)setPrimitiveRuntime:(NSNumber*)value;

- (float)primitiveRuntimeValue;
- (void)setPrimitiveRuntimeValue:(float)value_;




- (NSString*)primitiveTagline;
- (void)setPrimitiveTagline:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




@end
