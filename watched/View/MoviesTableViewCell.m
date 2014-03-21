//
//  MoviesTableViewCell.m
//  watched
//
//  Created by Martin Juhasz on 10.02.13.
//
//

#import "MoviesTableViewCell.h"
#import "UIView+Additions.h"
#import "UIColor+Additions.h"
#import "UIImageView+Additions.h"

@implementation MoviesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupContent];
    }
    return self;
}

- (void)setupContent
{
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(73.0f, 15.0f, 200.0f, 39.0f)];
    [_titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:17.0f]];
    [_titleLabel setTextColor:[UIColor blackColor]];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_titleLabel];
    
    _yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(73.0f, 55.0f, 153.0f, 21.0f)];
    [_yearLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0f]];
    [_yearLabel setTextColor:[UIColor colorWithHexString:@"C8C8C8"]];
    [_yearLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_yearLabel];
    
    
    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 16.0f, 43.0f, 60.0f)];
    [_coverImageView setContentMode:UIViewContentModeScaleToFill];
    [_coverImageView setInnerBorder:0.5f color:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f]];
    [self addSubview:_coverImageView];
}

- (void)setYear:(NSDate*)aDate
{
    if(aDate && [aDate isKindOfClass:[NSDate class]]) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:aDate];
        NSInteger year = [components year];
        CGRect yearLabelRect = self.yearLabel.frame;
        yearLabelRect.origin.y = self.titleLabel.bottom;
        self.yearLabel.frame = yearLabelRect;
        self.yearLabel.text = [NSString stringWithFormat:@"%d", year];
    } else {
        self.yearLabel.text = @"";
    }
}

- (void)setCoverImage:(UIImage*)aImage
{
    if(aImage) {
        self.coverImageView.image = aImage;
    } else {
        self.coverImageView.image = [UIImage imageNamed:@"cover-placeholder.png"];
    }
}

@end
