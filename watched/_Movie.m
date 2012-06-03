// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Movie.m instead.

#import "_Movie.h"

const struct MovieAttributes MovieAttributes = {
	.adult = @"adult",
	.backdropPath = @"backdropPath",
	.backdropURL = @"backdropURL",
	.budget = @"budget",
	.homepage = @"homepage",
	.imdbID = @"imdbID",
	.movieID = @"movieID",
	.note = @"note",
	.originalTitle = @"originalTitle",
	.overview = @"overview",
	.popularity = @"popularity",
	.posterPath = @"posterPath",
	.posterURL = @"posterURL",
	.rating = @"rating",
	.releaseDate = @"releaseDate",
	.revenue = @"revenue",
	.runtime = @"runtime",
	.tagline = @"tagline",
	.title = @"title",
	.watchedOn = @"watchedOn",
};

const struct MovieRelationships MovieRelationships = {
	.casts = @"casts",
	.crews = @"crews",
	.trailers = @"trailers",
};

const struct MovieFetchedProperties MovieFetchedProperties = {
};

@implementation MovieID
@end

@implementation _Movie

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Movie";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:moc_];
}

- (MovieID*)objectID {
	return (MovieID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"adultValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"adult"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"budgetValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"budget"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"movieIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"movieID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"popularityValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"popularity"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"ratingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rating"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"revenueValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"revenue"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"runtimeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"runtime"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic adult;



- (BOOL)adultValue {
	NSNumber *result = [self adult];
	return [result boolValue];
}

- (void)setAdultValue:(BOOL)value_ {
	[self setAdult:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveAdultValue {
	NSNumber *result = [self primitiveAdult];
	return [result boolValue];
}

- (void)setPrimitiveAdultValue:(BOOL)value_ {
	[self setPrimitiveAdult:[NSNumber numberWithBool:value_]];
}





@dynamic backdropPath;






@dynamic backdropURL;






@dynamic budget;



- (float)budgetValue {
	NSNumber *result = [self budget];
	return [result floatValue];
}

- (void)setBudgetValue:(float)value_ {
	[self setBudget:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveBudgetValue {
	NSNumber *result = [self primitiveBudget];
	return [result floatValue];
}

- (void)setPrimitiveBudgetValue:(float)value_ {
	[self setPrimitiveBudget:[NSNumber numberWithFloat:value_]];
}





@dynamic homepage;






@dynamic imdbID;






@dynamic movieID;



- (int32_t)movieIDValue {
	NSNumber *result = [self movieID];
	return [result intValue];
}

- (void)setMovieIDValue:(int32_t)value_ {
	[self setMovieID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveMovieIDValue {
	NSNumber *result = [self primitiveMovieID];
	return [result intValue];
}

- (void)setPrimitiveMovieIDValue:(int32_t)value_ {
	[self setPrimitiveMovieID:[NSNumber numberWithInt:value_]];
}





@dynamic note;






@dynamic originalTitle;






@dynamic overview;






@dynamic popularity;



- (int64_t)popularityValue {
	NSNumber *result = [self popularity];
	return [result longLongValue];
}

- (void)setPopularityValue:(int64_t)value_ {
	[self setPopularity:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitivePopularityValue {
	NSNumber *result = [self primitivePopularity];
	return [result longLongValue];
}

- (void)setPrimitivePopularityValue:(int64_t)value_ {
	[self setPrimitivePopularity:[NSNumber numberWithLongLong:value_]];
}





@dynamic posterPath;






@dynamic posterURL;






@dynamic rating;



- (int16_t)ratingValue {
	NSNumber *result = [self rating];
	return [result shortValue];
}

- (void)setRatingValue:(int16_t)value_ {
	[self setRating:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveRatingValue {
	NSNumber *result = [self primitiveRating];
	return [result shortValue];
}

- (void)setPrimitiveRatingValue:(int16_t)value_ {
	[self setPrimitiveRating:[NSNumber numberWithShort:value_]];
}





@dynamic releaseDate;






@dynamic revenue;



- (float)revenueValue {
	NSNumber *result = [self revenue];
	return [result floatValue];
}

- (void)setRevenueValue:(float)value_ {
	[self setRevenue:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveRevenueValue {
	NSNumber *result = [self primitiveRevenue];
	return [result floatValue];
}

- (void)setPrimitiveRevenueValue:(float)value_ {
	[self setPrimitiveRevenue:[NSNumber numberWithFloat:value_]];
}





@dynamic runtime;



- (float)runtimeValue {
	NSNumber *result = [self runtime];
	return [result floatValue];
}

- (void)setRuntimeValue:(float)value_ {
	[self setRuntime:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveRuntimeValue {
	NSNumber *result = [self primitiveRuntime];
	return [result floatValue];
}

- (void)setPrimitiveRuntimeValue:(float)value_ {
	[self setPrimitiveRuntime:[NSNumber numberWithFloat:value_]];
}





@dynamic tagline;






@dynamic title;






@dynamic watchedOn;






@dynamic casts;

	
- (NSMutableSet*)castsSet {
	[self willAccessValueForKey:@"casts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"casts"];
  
	[self didAccessValueForKey:@"casts"];
	return result;
}
	

@dynamic crews;

	
- (NSMutableSet*)crewsSet {
	[self willAccessValueForKey:@"crews"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"crews"];
  
	[self didAccessValueForKey:@"crews"];
	return result;
}
	

@dynamic trailers;

	
- (NSMutableSet*)trailersSet {
	[self willAccessValueForKey:@"trailers"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"trailers"];
  
	[self didAccessValueForKey:@"trailers"];
	return result;
}
	






@end
