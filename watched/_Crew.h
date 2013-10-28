// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Crew.h instead.

#import <CoreData/CoreData.h>


extern const struct CrewAttributes {
	__unsafe_unretained NSString *crewID;
	__unsafe_unretained NSString *department;
	__unsafe_unretained NSString *job;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *profilePath;
} CrewAttributes;

extern const struct CrewRelationships {
	__unsafe_unretained NSString *movie;
} CrewRelationships;

extern const struct CrewFetchedProperties {
} CrewFetchedProperties;

@class Movie;







@interface CrewID : NSManagedObjectID {}
@end

@interface _Crew : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CrewID*)objectID;




@property (nonatomic, strong) NSNumber* crewID;


@property int32_t crewIDValue;
- (int32_t)crewIDValue;
- (void)setCrewIDValue:(int32_t)value_;

//- (BOOL)validateCrewID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* department;


//- (BOOL)validateDepartment:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* job;


//- (BOOL)validateJob:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* profilePath;


//- (BOOL)validateProfilePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Movie* movie;

//- (BOOL)validateMovie:(id*)value_ error:(NSError**)error_;





@end

@interface _Crew (CoreDataGeneratedAccessors)

@end

@interface _Crew (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCrewID;
- (void)setPrimitiveCrewID:(NSNumber*)value;

- (int32_t)primitiveCrewIDValue;
- (void)setPrimitiveCrewIDValue:(int32_t)value_;




- (NSString*)primitiveDepartment;
- (void)setPrimitiveDepartment:(NSString*)value;




- (NSString*)primitiveJob;
- (void)setPrimitiveJob:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveProfilePath;
- (void)setPrimitiveProfilePath:(NSString*)value;





- (Movie*)primitiveMovie;
- (void)setPrimitiveMovie:(Movie*)value;


@end
