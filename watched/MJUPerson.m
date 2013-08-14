//
//  MJUPerson.m
//  watched
//
//  Created by Martin Juhasz on 12.08.13.
//
//

#import "MJUPerson.h"
#import "MTLJSONAdapter.h"

@implementation MJUPerson



///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initializer

+ (id)personFromJSONDictionary:(NSDictionary*)aDictionary
{
    NSError *error = nil;
    MTLJSONAdapter *modelAdapter = [[MTLJSONAdapter alloc] initWithJSONDictionary:aDictionary modelClass:[self class] error:&error];
    if(!error && [modelAdapter.model isKindOfClass:[self class]]) {
        return(MJUPerson*)modelAdapter.model;
    }
    return nil;
}



///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Property Changes

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"personID" : @"id",
             @"profilePath" : @"profile_path"
    };
}




@end
