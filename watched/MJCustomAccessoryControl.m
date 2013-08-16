//
//  MJCustomAccessoryControl.m
//  watched
//
//  Created by Martin Juhasz on 24.07.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import "MJCustomAccessoryControl.h"

@implementation MJCustomAccessoryControl

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
        _controlImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 9.0f, 14.0f)];
        _controlImageView.image = [UIImage imageNamed:@"table-accessory"];
        highlightedImageSetted = NO;
        [self addSubview:_controlImageView];
    }
    return self;
}

+ (MJCustomAccessoryControl*)accessory
{
	MJCustomAccessoryControl *ret = [[MJCustomAccessoryControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 9.0f, 14.0f)];
	return ret;
}

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
    if(highlighted && !highlightedImageSetted) {
        highlightedImageSetted = YES;
        _controlImageView.image = [UIImage imageNamed:@"table-accessory-highlighted"];
    } else if(!highlighted && highlightedImageSetted) {
        highlightedImageSetted = NO;
        _controlImageView.image = [UIImage imageNamed:@"table-accessory"];
    }
}

@end
