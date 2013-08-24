//
//  MoviesTableViewCell.m
//  watched
//
//  Created by Martin Juhasz on 10.02.13.
//
//

#import "MoviesTableViewCell.h"
#import "MJCustomAccessoryControl.h"
#import "UILabel+Additions.h"
#import "UIView+Additions.h"
#import "UIColor+Additions.h"

@implementation MoviesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        // appearance
//        UIView *tableCellBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 78.0f)];
//        tableCellBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"g_bg-table.png"]];
//        UIView *tableCellBackgroundViewSelected = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 78.0f)];
//        tableCellBackgroundViewSelected.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"g_bg-table_active.png"]];
//        MJCustomAccessoryControl *accessoryView = [MJCustomAccessoryControl accessory];
//        
//        [self setBackgroundView:tableCellBackgroundView];
//        [self setSelectedBackgroundView:tableCellBackgroundViewSelected];
//        [self setAccessoryView:accessoryView];
        
        // content
        [self setupContent];
    }
    return self;
}

- (void)setupContent
{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0f, 17.0f, 200.0f, 39.0f)];
    [_titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:17.0f]];
    [_titleLabel setTextColor:[UIColor blackColor]];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_titleLabel];
    
    _yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0f, 58.0f, 153.0f, 21.0f)];
    [_yearLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0f]];
    [_yearLabel setTextColor:[UIColor colorWithHexString:@"C8C8C8"]];
    [_yearLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_yearLabel];
    
    
    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 16.0f, 43.0f, 60.0f)];
    [_coverImageView setContentMode:UIViewContentModeScaleToFill];
    [self addSubview:_coverImageView];
    
    UIImageView *coverArtView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 16.0f, 43.0f, 60.0f)];
    [coverArtView setImage:[UIImage imageNamed:@"cover-overlay"]];
    [self addSubview:coverArtView];

    
}

- (void)setYear:(NSDate*)aDate
{
    if(aDate && [aDate isKindOfClass:[NSDate class]]) {
        NSUInteger componentFlags = NSYearCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:componentFlags fromDate:aDate];
        NSInteger year = [components year];
        CGRect yearLabelRect = self.yearLabel.frame;
        yearLabelRect.origin.y = self.titleLabel.bottom;
        self.yearLabel.frame = yearLabelRect;
        self.yearLabel.text = [NSString stringWithFormat:@"%d", year];
    } else {
        self.yearLabel.text = @"";
    }
}

- (void)setDetailText:(NSString*)aText
{
    CGRect yearLabelRect = self.yearLabel.frame;
    yearLabelRect.origin.y = self.titleLabel.bottom;
    self.yearLabel.frame = yearLabelRect;
    self.yearLabel.text = aText;
}

- (void)setCoverImage:(UIImage*)aImage
{
    if(aImage) {
        self.coverImageView.image = aImage;
    } else {
        self.coverImageView.image = [UIImage imageNamed:@"g_placeholder-cover.png"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
