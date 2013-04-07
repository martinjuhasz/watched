//
//  MJReloadAccessoryControl.m
//  watched
//
//  Created by Martin Juhasz on 30.03.13.
//
//

#import "MJReloadAccessoryControl.h"

@implementation MJReloadAccessoryControl

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
        _controlImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 14.0f, 18.0f)];
        _controlImageView.image = [UIImage imageNamed:@"g_table-accessory-retry.png"];
        highlightedImageSetted = NO;
        [self addSubview:_controlImageView];
    }
    return self;
}

+ (MJReloadAccessoryControl*)accessory
{
	MJReloadAccessoryControl *ret = [[MJReloadAccessoryControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 14.0f, 18.0f)];
	return ret;
}

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
    if(highlighted && !highlightedImageSetted) {
        highlightedImageSetted = YES;
        _controlImageView.image = [UIImage imageNamed:@"g_table-accessory-retry-active.png"];
    } else if(!highlighted && highlightedImageSetted) {
        highlightedImageSetted = NO;
        _controlImageView.image = [UIImage imageNamed:@"g_table-accessory-retry"];
    }
}

@end
