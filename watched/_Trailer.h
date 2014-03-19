// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Trailer.h instead.

#import <CoreData/CoreData.h>


extern const struct TrailerAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *quality;
	__unsafe_unretained NSString *source;
	__unsafe_unretained NSString *url;
} TrailerAttributes;

extern const struct TrailerRelationships {
	__unsafe_unretained NSString *movie;
} TrailerRelationships;

extern const struct TrailerFetchedProperties {
} TrailerFetchedProperties;

@class Movie;






@interface TrailerID : NSManagedObjectID {}
@end

@interface _Trailer : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TrailerID*)objectID;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* quality;


//- (BOOL)validateQuality:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* source;


//- (BOOL)validateSource:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* url;


//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Movie* movie;

//- (BOOL)validateMovie:(id*)value_ error:(NSError**)error_;





@end

@interface _Trailer (CoreDataGeneratedAccessors)

@end

@interface _Trailer (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveQuality;
- (void)setPrimitiveQuality:(NSString*)value;




- (NSString*)primitiveSource;
- (void)setPrimitiveSource:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (Movie*)primitiveMovie;
- (void)setPrimitiveMovie:(Movie*)value;


@end
