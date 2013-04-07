//
//  UIButton+Additions.h
//  MovieRater
//
//  Created by Martin Juhasz on 07.08.11.
//  Copyright 2011 watched. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIButton(Additions)

- (void)setTitle:(NSString *)title;
- (void)setForegroundImage:(UIImage *)image;
- (void)setBackgroundImage:(UIImage *)image;
- (void)setTitleShadowColor:(UIColor *)color;
- (void)setTitleColor:(UIColor *)color;

@end