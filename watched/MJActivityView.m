//
//  MJActivityView.m
//  watched
//
//  Created by Martin Juhasz on 26.07.12.
//
//

#import "MJActivityView.h"

@implementation MJActivityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.image = [UIImage imageNamed:@"t1.png"];
        self.animationImages = [NSArray arrayWithObjects:
                                [UIImage imageNamed:@"t1.png"],
                                [UIImage imageNamed:@"t2.png"],
                                [UIImage imageNamed:@"t3.png"],
                                [UIImage imageNamed:@"t4.png"], nil];
        self.animationDuration = 0.8f;
        [self startAnimating];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.image = [UIImage imageNamed:@"t1.png"];
        self.animationImages = [NSArray arrayWithObjects:
                                [UIImage imageNamed:@"t1.png"],
                                [UIImage imageNamed:@"t2.png"],
                                [UIImage imageNamed:@"t3.png"],
                                [UIImage imageNamed:@"t4.png"], nil];
        self.animationDuration = 0.8f;
        [self startAnimating];
    }
    return self;
}

+ (MJActivityView*)loadingView
{
	MJActivityView *ret = [[MJActivityView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 59.0f, 58.0f)];
	return ret;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
