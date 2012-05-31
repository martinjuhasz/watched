//
//  UIButton+Additions.m
//  MovieRater
//
//  Created by Martin Juhasz on 07.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIButton+Additions.h"

@implementation UIButton (Additions)

- (void)setTitle:(NSString *)title
{
    [self setTitle:title forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateHighlighted];
    [self setTitle:title forState:UIControlStateDisabled];
    [self setTitle:title forState:UIControlStateSelected];
}

- (void)setForegroundImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateHighlighted];
    [self setImage:image forState:UIControlStateDisabled];
    [self setImage:image forState:UIControlStateSelected];
}

- (void)setBackgroundImage:(UIImage *)image
{
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self setBackgroundImage:image forState:UIControlStateHighlighted];
    [self setBackgroundImage:image forState:UIControlStateDisabled];
    [self setBackgroundImage:image forState:UIControlStateSelected];
}

- (void)setTitleColor:(UIColor *)color
{
    [self setTitleColor:color forState:UIControlStateNormal];
    [self setTitleColor:color forState:UIControlStateHighlighted];
    [self setTitleColor:color forState:UIControlStateDisabled];
    [self setTitleColor:color forState:UIControlStateSelected];
}

- (void)setTitleShadowColor:(UIColor *)color
{
    [self setTitleShadowColor:color forState:UIControlStateNormal];
    [self setTitleShadowColor:color forState:UIControlStateHighlighted];
    [self setTitleShadowColor:color forState:UIControlStateDisabled];
    [self setTitleShadowColor:color forState:UIControlStateSelected];
}

@end
