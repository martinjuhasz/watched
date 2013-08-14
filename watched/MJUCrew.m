//
//  MJUCrew.m
//  watched
//
//  Created by Martin Juhasz on 12.08.13.
//
//

#import "MJUCrew.h"

@implementation MJUCrew

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if([key isEqualToString:@"department"]) {
        return;
    }
    [super setValue:value forUndefinedKey:key];
}


@end
