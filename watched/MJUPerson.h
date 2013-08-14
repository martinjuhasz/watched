//
//  MJUPerson.h
//  watched
//
//  Created by Martin Juhasz on 12.08.13.
//
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"


@interface MJUPerson : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *personID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *job;
@property (nonatomic, copy) NSString *profilePath;

+ (id)personFromJSONDictionary:(NSDictionary*)aDictionary;

@end
