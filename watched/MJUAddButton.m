//
//  MJUAddButton.m
//  watched
//
//  Created by Martin Juhasz on 25.08.13.
//
//

#import "MJUAddButton.h"
#import "UIColor+Additions.h"


@implementation MJUAddButton

@synthesize state = _state;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        _state = MJUAddButtonStateNormal;
        [self drawBorderLayer];
        [self drawRotatingLayer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _state = MJUAddButtonStateNormal;
        [self drawBorderLayer];
        [self drawRotatingLayer];
    }
    return self;
}

//- (void)drawButton
//{
//    // Get the root layer (any UIView subclass comes with one)
//    CALayer *layer = self.layer;
//    
//    
//}

- (void)drawBorderLayer
{
    // Check if the property has been set already
    if (!_borderLayer)
    {
        // Instantiate the gradient layer
        _borderLayer = [CALayer layer];
        _borderLayer.frame = self.layer.frame;
        
        // Set the colors
        _borderLayer.cornerRadius = 13.0f;
        _borderLayer.borderWidth = 1.0f;
        _borderLayer.borderColor = [UIColor colorWithHexString:@"F42832"].CGColor;
        
        // Add the gradient to the layer hierarchy
        [self.layer addSublayer:_borderLayer];
    }
}

- (void)drawRotatingLayer
{
    // Check if the property has been set already
    if (!_rotatingLayer)
    {
        // Instantiate the gradient layer
        _rotatingLayer = [CALayer layer];
        _rotatingLayer.frame = CGRectMake(0.0f, 0.0f, 26.0f, 26.0f);
        _rotatingLayer.backgroundColor = [UIColor clearColor].CGColor;
        
        CALayer *pointLayer = [CALayer layer];
        pointLayer.frame = CGRectMake(10.5f, -2.0f, 5.0f, 15.0f);
        pointLayer.backgroundColor = [UIColor whiteColor].CGColor;
        [_rotatingLayer addSublayer:pointLayer];
        
        // Set the colors
        
        
        // Add the gradient to the layer hierarchy
        _rotatingLayer.hidden = YES;
        [self.layer insertSublayer:_rotatingLayer atIndex:[self.layer.sublayers count]];
    }
}

- (void)setState:(MJUAddButtonState)newState
{
    if(newState == _state) return;
    _state = newState;
    
    if(_state == MJUAddButtonStateLoading) {
        [self animateToLoadingState];
    }
}

- (void)animateToLoadingState
{
    CGRect newRect = self.borderLayer.frame;
    newRect.size.width = 26.0f;
    
    [UIView animateWithDuration:0.1f animations:^{
        self.titleLabel.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^{
            self.borderLayer.frame = newRect;
        } completion:^(BOOL finished) {
            [self animateLoading];
        }];
    }];
}


- (void)animateLoading
{
    _rotatingLayer.hidden = NO;
    CABasicAnimation *fullRotation;
    fullRotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    fullRotation.fromValue = [NSNumber numberWithFloat:0];
    fullRotation.toValue = [NSNumber numberWithFloat:((360*M_PI)/180)];
    fullRotation.duration = 1.25f;
    fullRotation.repeatCount = FLT_MAX;
    [self.rotatingLayer addAnimation:fullRotation forKey:@"transform.rotation"];
    
}

//- (void)layoutSubviews
//{
//
//    [super layoutSubviews];
//}

@end
