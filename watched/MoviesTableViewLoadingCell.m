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
        
        // Background
        UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 42.0f)];
        [backgroundImage setImage:[UIImage imageNamed:@"sv_bg_meta.png"]];
        [self addSubview:backgroundImage];
        
        // Loader
        _loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0f, 11.0f, 18.0f, 21.0f)];
        _loadingView.animationImages = [NSArray arrayWithObjects:
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
        _loadingView.animationDuration = 0.8;
        [_loadingView startAnimating];
        [self addSubview:_loadingView];
        
        // Label
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(46.0f, 10.0f, 244.0f, 21.0f)];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setShadowColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.66f]];
        [_titleLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        _titleLabel.text = NSLocalizedString(@"SETTINGS_META_LOADING", nil);
        [self addSubview:_titleLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
