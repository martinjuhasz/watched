//
//  MJPopupBackgroundView.m
//  watched
//
//  Created by Martin Juhasz on 18.06.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import "MJPopupBackgroundView.h"

@implementation MJPopupBackgroundView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    size_t locationsCount = 2;
    CGFloat locations[2] = {0.0f, 1.0f};
    CGFloat colors[] = {
         0.0, 0.0, 0.0, 0.55,
         0.0, 0.0, 0.0, 0.9};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    float radius = MIN(self.bounds.size.width , self.bounds.size.height) ;
    CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}


@end
