//
//  MJUTrailer.m
//  watched
//
//  Created by Martin Juhasz on 09.08.13.
//
//

#import "MJUTrailer.h"
#import "MTLValueTransformer.h"

@implementation MJUTrailer


///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initializer

+ (id)trailerFromJSONDictionary:(NSDictionary*)aDictionary
{
    NSError *error = nil;
    MTLJSONAdapter *modelAdapter = [[MTLJSONAdapter alloc] initWithJSONDictionary:aDictionary modelClass:[MJUTrailer class] error:&error];
    if(!error && [modelAdapter.model isKindOfClass:[MJUTrailer class]]) {
        return(MJUTrailer*)modelAdapter.model;
    }
    return nil;
}



///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Property Changes

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"source" : @"source",
             @"source" : @"sources.source",
             @"size" : @"size",
             @"size" : @"sources.size",
             [NSNull null] : @"sources"
    };
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if([key isEqualToString:@"sources"]) {
        NSString *source = nil;
        NSString *sizeString = nil;
        int size = 0;
        for (NSDictionary *trailerDict in (NSArray*)value) {
            int newSize = [[[trailerDict objectForKey:@"size"] stringByReplacingOccurrencesOfString:@"p" withString:@""] intValue];
            if(!size || size < newSize) {
                source = [trailerDict objectForKey:@"source"];
                if(size > 480) {
                    sizeString = @"HD";
                } else {
                    sizeString = @"SD";
                }
            }
        }
        [self setValue:source forKey:@"source"];
        [self setValue:sizeString forKey:@"size"];
        return;
    }
    
    
    [super setValue:value forUndefinedKey:key];
}

-(NSString*)source
{
    if(self.type == MJUTrailerTypeYoutube) {
        return [NSString stringWithFormat:@"http://m.youtube.com/watch?v=%@",_source];
    }
    return _source;
}


///////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Custom Transformers

+ (NSValueTransformer *)sizeJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        if([str isEqualToString:@"HD"]) {
            return @(MJUTrailerQualityHD);
        }
        return @(MJUTrailerQualitySD);

    } reverseBlock:^(NSNumber *quality) {
        if([quality intValue] == MJUTrailerQualityHD) {
            return @"HD";
        }
        return @"SD";
    }];
}

@end
