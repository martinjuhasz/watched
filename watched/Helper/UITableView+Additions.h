//
//  UITableView+Additions.h
//  Storyboard
//
//  Created by Martin Juhasz on 14/11/13.
//  Copyright (c) 2013 Martin Juhasz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Additions)

- (void)hideEmptyCells;

- (UITableViewCell*)prototypeCellWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
