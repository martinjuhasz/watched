//
//  UILabel+Additions.m
//  LabelTest
//
//  Created by Martin Juhasz on 20.11.11.
//  Copyright (c) 2011 watched. All rights reserved.
//

#import "UILabel+Additions.h"

@implementation UILabel(Additions)

- (void)sizeToFitWithMaximumNumberOfLines:(int)lines
{
    self.numberOfLines = lines;
    CGSize maxSize = CGSizeMake(self.frame.size.width, lines * self.font.lineHeight);
    CGSize size = [self.text sizeWithFont:self.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByTruncatingTail];
    self.lineBreakMode = NSLineBreakByTruncatingTail;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

- (void)sizeToFitWithWith:(CGFloat)width andMaximumNumberOfLines:(int)lines {
    CGRect currentFrame = self.frame;
    currentFrame.size.width = width;
    self.frame = currentFrame;
    [self sizeToFitWithMaximumNumberOfLines:lines];
}

@end
