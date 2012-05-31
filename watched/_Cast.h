// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Cast.h instead.

#import <CoreData/CoreData.h>


extern const struct CastAttributes {
	__unsafe_unretained NSString *castID;
	__unsafe_unretained NSString *character;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *order;
	__unsafe_unretained NSString *profilePath;
} CastAttributes;

extern const struct CastRelationships {
	__unsafe_unretained NSString *movie;
} CastRelationships;

extern const struct CastFetchedProperties {
} CastFetchedProperties;

@class Movie;







@interface CastID : NSManagedObjectID {}
@end

@interface _Cast : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CastID*)objectID;




@property (nonatomic, strong) NSNumber* castID;


@property int32_t castIDValue;
- (int32_t)castIDValue;
- (void)setCastIDValue:(int32_t)value_;

//- (BOOL)validateCastID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* character;


//- (BOOL)validateCharacter:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* order;


@property int32_t orderValue;
- (int32_t)orderValue;
- (void)setOrderValue:(int32_t)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* profilePath;


//- (BOOL)validateProfilePath:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Movie* movie;

//- (BOOL)validateMovie:(id*)value_ error:(NSError**)error_;





@end

@interface _Cast (CoreDataGeneratedAccessors)

@end

@interface _Cast (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCastID;
- (void)setPrimitiveCastID:(NSNumber*)value;

- (int32_t)primitiveCastIDValue;
- (void)setPrimitiveCastIDValue:(int32_t)value_;




- (NSString*)primitiveCharacter;
- (void)setPrimitiveCharacter:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int32_t)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int32_t)value_;




- (NSString*)primitiveProfilePath;
- (void)setPrimitiveProfilePath:(NSString*)value;





- (Movie*)primitiveMovie;
- (void)setPrimitiveMovie:(Movie*)value;


@end
