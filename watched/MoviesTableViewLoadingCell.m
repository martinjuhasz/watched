//
//  MoviesTableLoadingCell.m
//  watched
//
//  Created by Martin Juhasz on 11.02.13.
//
//

#import "MoviesTableViewLoadingCell.h"

@implementation MoviesTableViewLoadingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      
        // Indicator
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.frame = CGRectMake(148, 3, 24, 24);
        [self addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
        
        // Label
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(46.0f, 10.0f, 244.0f, 21.0f)];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setShadowColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.66f]];
        [_titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_titleLabel];
        
    }
    return self;
}

@end
