//
//  MJUStarRatingHeaderView.m
//  watched
//
//  Created by Martin Juhasz on 20/03/14.
//
//

#import "MJUStarRatingHeaderView.h"
#import "UIColor+Additions.h"

static CGFloat HEADER_HEIGHT = 22.5f;

@implementation MJUStarRatingHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

+ (MJUStarRatingHeaderView*)headerViewWithRating:(NSUInteger)rating
{
    MJUStarRatingHeaderView *headerView = [[MJUStarRatingHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, HEADER_HEIGHT)];
    headerView.rating = rating;
    return headerView;
}

+ (CGFloat)headerHeight
{
    return HEADER_HEIGHT;
}

- (void)setRating:(NSUInteger)rating
{
    _rating = rating;
    [self configureRating];
}

- (void)setupSubviews
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0f, 320, HEADER_HEIGHT)];
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -1, 320, HEADER_HEIGHT)];
    backgroundView.backgroundColor = [UIColor colorWithHexString:@"F3F3F3"];
    
    self.starView = [[UIView alloc] initWithFrame:CGRectMake(15.5f, 4.0f, 20.0f, 15.0f)];
    [self.starView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"divider-star"]]];
    self.starView.hidden = YES;
    [backgroundView addSubview:self.starView];
    
    self.unratedLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0f, 1.0f, 320.0f, HEADER_HEIGHT-1)];
    self.unratedLabel.backgroundColor = [UIColor clearColor];
    self.unratedLabel.textColor = [UIColor grayColor];
    self.unratedLabel.font = [UIFont fontWithName:@"AvenirNext-Demibold" size:14.0f];
    self.unratedLabel.text = NSLocalizedString(@"HEADER_TITLE_ZERORATING", nil);
    self.unratedLabel.hidden = YES;
    [backgroundView addSubview:self.unratedLabel];
    
    [headerView addSubview:backgroundView];
    [self addSubview:headerView];
    
    [self configureRating];
}

- (void)configureRating
{
    if(self.rating > 0) {
        self.starView.frame = CGRectMake(self.starView.frame.origin.x, self.starView.frame.origin.y, 20.0f * self.rating, self.starView.frame.size.height);
        self.starView.hidden = NO;
        self.unratedLabel.hidden = YES;
    } else {
        self.starView.hidden = YES;
        self.unratedLabel.hidden = NO;
    }
}



@end
