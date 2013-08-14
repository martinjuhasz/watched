//
//  MJUCast.m
//  watched
//
//  Created by Martin Juhasz on 12.08.13.
//
//

#import "MJUCast.h"

@implementation MJUCast

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *returnDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [returnDict setObject:@"cast_id" forKey:@"castID"];
    [returnDict setObject:@"character" forKey:@"job"];
    return returnDict;
}

@end
