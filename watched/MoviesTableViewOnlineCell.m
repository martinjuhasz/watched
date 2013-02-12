//
//  MoviesTableViewOnlineCell.m
//  watched
//
//  Created by Martin Juhasz on 12.02.13.
//
//

#import "MoviesTableViewOnlineCell.h"
#import "MJCustomAccessoryControl.h"
#import "UILabel+Additions.h"
#import "UIView+Additions.h"

@implementation MoviesTableViewOnlineCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // appearance
        UIView *tableCellBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 79.0f)];
        tableCellBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"g_bg-table.png"]];
        UIView *tableCellBackgroundViewSelected = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 79.0f)];
        tableCellBackgroundViewSelected.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"g_bg-table_active.png"]];
        MJCustomAccessoryControl *accessoryView = [MJCustomAccessoryControl accessory];
        
        [self setBackgroundView:tableCellBackgroundView];
        [self setSelectedBackgroundView:tableCellBackgroundViewSelected];
        [self setAccessoryView:accessoryView];
        
        // Loader
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0f, 11.0f, 18.0f, 21.0f)];
        [self addSubview:_coverImageView];
        
        // Label
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(46.0f, 10.0f, 244.0f, 21.0f)];
        [_titleLabel setNumberOfLines:1];
        [_titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setShadowColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.33f]];
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
