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
#import "UIColor+Additions.h"

@implementation MoviesTableViewOnlineCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // Cover
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0f, 9.0f, 28.0f, 39.0f)];
        [self addSubview:_coverImageView];
        
        // Cover Overlay
        UIImageView *coverOverlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0f, 7.0f, 31.0f, 42.0f)];
        coverOverlayImageView.image = [UIImage imageNamed:@"sv_cover-search-results"];
        [self addSubview:coverOverlayImageView];
        
        
        // Label
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0f, 9.0f, 244.0f, 21.0f)];
        [_titleLabel setNumberOfLines:1];
        [_titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [_titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:15.0f]];
        [_titleLabel setTextColor:[UIColor blackColor]];
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        _titleLabel.text = NSLocalizedString(@"SETTINGS_META_LOADING", nil);
        [self addSubview:_titleLabel];
        
        // Detail Label
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0f, 50.0f, 296.0f, 21.0f)];
        [_detailLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:12.0f]];
        [_detailLabel setTextColor:[UIColor colorWithHexString:@"C8C8C8"]];
        [_detailLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_detailLabel];
        
    }
    return self;
}

- (void)setYear:(NSDate*)aDate
{
    if(aDate && [aDate isKindOfClass:[NSDate class]]) {
        NSUInteger componentFlags = NSYearCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:aDate];
        NSInteger year = [components year];
        CGRect yearLabelRect = self.detailLabel.frame;
        yearLabelRect.origin.y = self.titleLabel.bottom - 3.0f;
        self.detailLabel.frame = yearLabelRect;
        self.detailLabel.text = [NSString stringWithFormat:@"%d", year];
    } else {
        self.detailLabel.text = @"";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
