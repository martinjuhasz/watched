//
//  MovieShareButtonView.m
//  watched
//
//  Created by Martin Juhasz on 30.03.13.
//
//

#import "MovieShareButtonView.h"

@implementation MovieShareButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor redColor];
        DebugLog("");
    }
    return self;
}

+ (MovieShareButtonView*)shareButtonView
{
    return [[MovieShareButtonView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
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
