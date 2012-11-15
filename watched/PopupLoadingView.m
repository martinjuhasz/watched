//
//  PopupLoadingView.m
//  watched
//
//  Created by Martin Juhasz on 22.10.12.
//
//

#import "PopupLoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation PopupLoadingView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOpaque:NO];
        UIImageView *loadingView = (UIImageView*)[self viewWithTag:75433];
        loadingView.animationImages = [NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"sv_spinner1.png"],
                                       [UIImage imageNamed:@"sv_spinner2.png"],
                                       [UIImage imageNamed:@"sv_spinner3.png"],
                                       [UIImage imageNamed:@"sv_spinner4.png"],
                                       [UIImage imageNamed:@"sv_spinner5.png"],
                                       [UIImage imageNamed:@"sv_spinner6.png"],
                                       [UIImage imageNamed:@"sv_spinner7.png"],
                                       [UIImage imageNamed:@"sv_spinner8.png"],
                                       [UIImage imageNamed:@"sv_spinner9.png"],
                                       nil];
        loadingView.animationDuration = 0.8;
        [loadingView startAnimating];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.layer.masksToBounds = YES;
}


@end
