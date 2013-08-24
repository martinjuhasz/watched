//
//  NSManagedObject+Additions.m
//  watched
//
//  Created by Martin Juhasz on 24.08.13.
//
//

#import "NSManagedObject+Additions.h"

@implementation NSManagedObject (Additions)

- (BOOL)isNew {
    NSDictionary *vals = [self committedValuesForKeys:nil];
    return [vals count] == 0;
}

@end
