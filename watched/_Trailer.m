// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Trailer.m instead.

#import "_Trailer.h"

const struct TrailerAttributes TrailerAttributes = {
	.name = @"name",
	.quality = @"quality",
	.source = @"source",
	.url = @"url",
};

const struct TrailerRelationships TrailerRelationships = {
	.movie = @"movie",
};

const struct TrailerFetchedProperties TrailerFetchedProperties = {
};

@implementation TrailerID
@end

@implementation _Trailer

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Trailer" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Trailer";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Trailer" inManagedObjectContext:moc_];
}

- (TrailerID*)objectID {
	return (TrailerID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic quality;






@dynamic source;






@dynamic url;






@dynamic movie;

	






@end
