//
//  UIImageView+Additions.m
//  watched
//
//  Created by Martin Juhasz on 21/03/14.
//
//

#import "UIImageView+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImageView (Additions)

- (void)setInnerBorder:(CGFloat)size color:(UIColor*)color
{
    CALayer *borderLayer = [CALayer layer];
    CGRect borderFrame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
    
    [borderLayer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [borderLayer setFrame:borderFrame];
    [borderLayer setBorderWidth:size];
    [borderLayer setBorderColor:[color CGColor]];
    [self.layer addSublayer:borderLayer];
}

@end
