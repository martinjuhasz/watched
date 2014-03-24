//
//  NSString+Additions.m
//  watched
//
//  Created by Martin Juhasz on 24/03/14.
//
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (BOOL)isEmpty
{
    if([self length] == 0) {
        return YES;
    }
    
    if(![[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
        return YES;
    }
    
    return NO;
}

@end
