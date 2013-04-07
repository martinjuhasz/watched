//
//  UILabel+Additions.h
//  LabelTest
//
//  Created by Martin Juhasz on 20.11.11.
//  Copyright (c) 2011 watched. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UILabel(Additions)

- (void)sizeToFitWithMaximumNumberOfLines:(int)lines;
- (void)sizeToFitWithWith:(CGFloat)width andMaximumNumberOfLines:(int)lines;

@end
