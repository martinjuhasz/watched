//
//  MJGradientView.m
//  watched
//
//  Created by Martin Juhasz on 25.07.12.
//
//

#import "MJGradientView.h"
#import "UIColor+Additions.h"

@implementation MJGradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _startColor = [UIColor blackColor];
        _stopColor = [UIColor whiteColor];
        _topColor = nil;
        _bottomColor = nil;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {_startColor.red, _startColor.green, _startColor.blue, _startColor.alpha,  // Start color
            _stopColor.red, _stopColor.green, _stopColor.blue, _stopColor.alpha}; // End color
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
//    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    CGPoint maxCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, maxCenter, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    
    
    //draw line
    if(_topColor) {
        CGContextSetRGBStrokeColor(currentContext, _topColor.red, _topColor.green, _topColor.blue, _topColor.alpha);
        CGContextSetLineWidth(currentContext, 2);
        CGContextMoveToPoint(currentContext, 0, 0);
        CGContextAddLineToPoint(currentContext, rect.size.width, 0);
        CGContextStrokePath(currentContext);
    }
    
    if(_bottomColor) {
        CGContextSetRGBStrokeColor(currentContext, _bottomColor.red, _bottomColor.green, _bottomColor.blue, _bottomColor.alpha);
        CGContextSetLineWidth(currentContext, 2);
        CGContextMoveToPoint(currentContext, 0, rect.size.height);
        CGContextAddLineToPoint( currentContext, rect.size.width, rect.size.height);
        CGContextStrokePath(currentContext);
    }
}

@end
