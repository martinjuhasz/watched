//
//  UITableView+Additions.m
//  Storyboard
//
//  Created by Martin Juhasz on 14/11/13.
//  Copyright (c) 2013 Martin Juhasz. All rights reserved.
//

#import "UITableView+Additions.h"
#import <objc/runtime.h>

static char const * const key = "prototypeCells";

@implementation UITableView (Additions)

- (void)hideEmptyCells
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:v];
}

#pragma mark -
#pragma mark Cell Prototypes

- (void)setPrototypeCells:(NSMutableDictionary *)prototypeCells
{
    objc_setAssociatedObject(self, key, prototypeCells, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)prototypeCells
{
    return objc_getAssociatedObject(self, key);
}

- (UITableViewCell*)prototypeCellWithReuseIdentifier:(NSString*)reuseIdentifier
{
    if (self.prototypeCells == nil) {
        self.prototypeCells = [[NSMutableDictionary alloc] init];
    }
    
    UITableViewCell* cell = self.prototypeCells[reuseIdentifier];
    if (cell == nil) {
        cell = [self dequeueReusableCellWithIdentifier:reuseIdentifier];
        self.prototypeCells[reuseIdentifier] = cell;
    }
    return cell;
}


@end
