//
//  MJLoadingAccessoryControl.m
//  watched
//
//  Created by Martin Juhasz on 19.02.13.
//
//

#import "MJLoadingAccessoryControl.h"

@implementation MJLoadingAccessoryControl

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.frame = CGRectMake(0, 0, 24, 24);
        [_spinner startAnimating];
        [self addSubview:_spinner];
    }
    return self;
}

+ (MJLoadingAccessoryControl*)accessory
{
	MJLoadingAccessoryControl *ret = [[MJLoadingAccessoryControl alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24.0f, 24.0f)];
	return ret;
}

@end
