// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Crew.m instead.

#import "_Crew.h"

const struct CrewAttributes CrewAttributes = {
	.crewID = @"crewID",
	.department = @"department",
	.job = @"job",
	.name = @"name",
	.profilePath = @"profilePath",
};

const struct CrewRelationships CrewRelationships = {
	.movie = @"movie",
};

const struct CrewFetchedProperties CrewFetchedProperties = {
};

@implementation CrewID
@end

@implementation _Crew

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Crew" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Crew";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Crew" inManagedObjectContext:moc_];
}

- (CrewID*)objectID {
	return (CrewID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"crewIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"crewID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic crewID;



- (int32_t)crewIDValue {
	NSNumber *result = [self crewID];
	return [result intValue];
}

- (void)setCrewIDValue:(int32_t)value_ {
	[self setCrewID:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveCrewIDValue {
	NSNumber *result = [self primitiveCrewID];
	return [result intValue];
}

- (void)setPrimitiveCrewIDValue:(int32_t)value_ {
	[self setPrimitiveCrewID:[NSNumber numberWithInt:value_]];
}





@dynamic department;






@dynamic job;






@dynamic name;






@dynamic profilePath;






@dynamic movie;

	






@end
