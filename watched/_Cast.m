// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Cast.m instead.

#import "_Cast.h"

const struct CastAttributes CastAttributes = {
	.castID = @"castID",
	.character = @"character",
	.name = @"name",
	.order = @"order",
	.profilePath = @"profilePath",
};

const struct CastRelationships CastRelationships = {
	.movie = @"movie",
};

const struct CastFetchedProperties CastFetchedProperties = {
};

@implementation CastID
@end

@implementation _Cast

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Cast" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Cast";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Cast" inManagedObjectContext:moc_];
}

- (CastID*)objectID {
	return (CastID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"castIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"castID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic castID;



- (int32_t)castIDValue {
	NSNumber *result = [self castID];
	return [result intValue];
}

- (void)setCastIDValue:(int32_t)value_ {
	[self setCastID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveCastIDValue {
	NSNumber *result = [self primitiveCastID];
	return [result intValue];
}

- (void)setPrimitiveCastIDValue:(int32_t)value_ {
	[self setPrimitiveCastID:[NSNumber numberWithInt:value_]];
}





@dynamic character;






@dynamic name;






@dynamic order;



- (int32_t)orderValue {
	NSNumber *result = [self order];
	return [result intValue];
}

- (void)setOrderValue:(int32_t)value_ {
	[self setOrder:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveOrderValue {
	NSNumber *result = [self primitiveOrder];
	return [result intValue];
}

- (void)setPrimitiveOrderValue:(int32_t)value_ {
	[self setPrimitiveOrder:[NSNumber numberWithInt:value_]];
}





@dynamic profilePath;






@dynamic movie;

	






@end
