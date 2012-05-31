//
//  MovieDetailView.m
//  watched
//
//  Created by Martin Juhasz on 29.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MovieDetailView.h"
#import "UILabel+Additions.h"
#import "UIView+Additions.h"
#import "UIButton+Additions.h"

@implementation MovieDetailView

@synthesize mainScrollView;
@synthesize backdropImageView;
@synthesize posterImageView;
@synthesize titleLabel;
@synthesize releaseDateLabel;
@synthesize runtimeLabel;
@synthesize actor1ImageView;
@synthesize actor1Label;
@synthesize actor2ImageView;
@synthesize actor2Label;
@synthesize actor3ImageView;
@synthesize actor3Label;
@synthesize overviewLabel;
@synthesize ratingView;
@synthesize trailerButton;
@synthesize websiteButton;



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupContent];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Content Management

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backdropImageView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 115.0f);
    self.posterImageView.frame = CGRectMake(9.0f, 93.0f, 89.0f, 126.0f);
    
    self.titleLabel.frame = CGRectMake(110.0f, 125.0f, 206.0f, 46.0f);
    [self.titleLabel sizeToFitWithMaximumNumberOfLines:3];
    
    self.ratingView.frame = CGRectMake(0.0f, 233.0f, 320.0f, 56.0f);
    
    self.releaseDateLabel.frame = CGRectMake(13.0f, 340.0f, 145.0f, 25.0f);
    self.runtimeLabel.frame = CGRectMake(162.0f, 340.0f, 145.0f, 25.0f);
    
    self.actor1ImageView.frame = CGRectMake(16.0f, 400.0f, 83.0f, 48.0f);
    self.actor2ImageView.frame = CGRectMake(118.0f, 400.0f, 83.0f, 48.0f);
    self.actor3ImageView.frame = CGRectMake(220.0f, 400.0f, 83.0f, 48.0f);
    self.actor1Label.frame = CGRectMake(16.0f, 445.0f, 83.0f, 25.0f);
    self.actor2Label.frame = CGRectMake(118.0f, 445.0f, 83.0f, 25.0f);
    self.actor3Label.frame = CGRectMake(220.0f, 445.0f, 83.0f, 25.0f);
    
    self.overviewLabel.frame = CGRectMake(13.0f, 505.0f, 294.0f, 0.0f);
    [self.overviewLabel sizeToFit];
    
    self.trailerButton.frame = CGRectMake(13.0f, self.overviewLabel.bottom + 30.0f, 294.0f, 25.0f);
    self.websiteButton.frame = CGRectMake(13.0f, self.trailerButton.bottom + 15.0f, 294.0f, 25.0f);
    
    [self.mainScrollView setContentSize:CGSizeMake(320.0f, self.websiteButton.bottom + 20.0f)];
}

- (void)setupContent
{
    self.backgroundColor = HEXColor(0x2f2f2f);
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    [self addSubview:self.mainScrollView];
    
    self.backdropImageView = [[UIImageView alloc] init];
    self.backdropImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backdropImageView.clipsToBounds = YES;
    [self.mainScrollView addSubview:self.backdropImageView];
    
    self.posterImageView = [[UIImageView alloc] init];
    self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.posterImageView.clipsToBounds = YES;
    [self.mainScrollView addSubview:self.posterImageView];
    
    self.titleLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.titleLabel];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.titleLabel.textColor = HEXColor(0xFFFFFF);
//    self.titleLabel.shadowColor = HEXColor(0xFFFFFF);
//    self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [self.mainScrollView addSubview:self.titleLabel];
    
    self.ratingView =[[DLStarRatingControl alloc] initWithFrame:CGRectZero andStars:5 isFractional:NO]; 
    [self.mainScrollView addSubview:self.ratingView];
    
    self.releaseDateLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.releaseDateLabel];
    self.releaseDateLabel.font = [UIFont systemFontOfSize:14.0f];
    self.releaseDateLabel.adjustsFontSizeToFitWidth = NO;
    self.releaseDateLabel.textColor = HEXColor(0xFFFFFF);
    self.releaseDateLabel.textAlignment = UITextAlignmentRight;
    [self.mainScrollView addSubview:self.releaseDateLabel];
    
    self.runtimeLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.runtimeLabel];
    self.runtimeLabel.font = [UIFont systemFontOfSize:14.0f];
    self.runtimeLabel.adjustsFontSizeToFitWidth = NO;
    self.runtimeLabel.textColor = HEXColor(0xFFFFFF);
    self.runtimeLabel.textAlignment = UITextAlignmentRight;
    [self.mainScrollView addSubview:self.runtimeLabel];
    
    
    // Actors
    
    self.actor1ImageView = [[UIImageView alloc] init];
    self.actor1ImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.actor1ImageView.clipsToBounds = YES;
    [self.mainScrollView addSubview:self.actor1ImageView];
    
    self.actor1Label = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.actor1Label];
    self.actor1Label.font = [UIFont systemFontOfSize:12.0f];
    self.actor1Label.adjustsFontSizeToFitWidth = NO;
    self.actor1Label.textColor = HEXColor(0xFFFFFF);
    [self.mainScrollView addSubview:self.actor1Label];
    
    self.actor2ImageView = [[UIImageView alloc] init];
    self.actor2ImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.actor2ImageView.clipsToBounds = YES;
    [self.mainScrollView addSubview:self.actor2ImageView];
    
    self.actor2Label = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.actor2Label];
    self.actor2Label.font = [UIFont systemFontOfSize:12.0f];
    self.actor2Label.adjustsFontSizeToFitWidth = NO;
    self.actor2Label.textColor = HEXColor(0xFFFFFF);
    [self.mainScrollView addSubview:self.actor2Label];
    
    self.actor3ImageView = [[UIImageView alloc] init];
    self.actor3ImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.actor3ImageView.clipsToBounds = YES;
    [self.mainScrollView addSubview:self.actor3ImageView];
    
    self.actor3Label = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.actor3Label];
    self.actor3Label.font = [UIFont systemFontOfSize:12.0f];
    self.actor3Label.adjustsFontSizeToFitWidth = NO;
    self.actor3Label.textColor = HEXColor(0xFFFFFF);
    [self.mainScrollView addSubview:self.actor3Label];
    
    
    UILabel *overviewTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0f, 485.0f, 300.0f, 15.0f)];
    overviewTitleLabel.text = @"Overview";
    [self setDefaultStylesForLabels:overviewTitleLabel];
    overviewTitleLabel.adjustsFontSizeToFitWidth = NO;
    overviewTitleLabel.textColor = HEXColor(0xFFFFFF);
    [self.mainScrollView addSubview:overviewTitleLabel];
    
    self.overviewLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.overviewLabel];
    self.overviewLabel.font = [UIFont systemFontOfSize:14.0f];
    self.overviewLabel.adjustsFontSizeToFitWidth = NO;
    self.overviewLabel.textColor = HEXColor(0xFFFFFF);
    [self.mainScrollView addSubview:self.overviewLabel];
    
    self.trailerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.trailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.trailerButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.trailerButton.titleColor = HEXColor(0xABADAF);
    [self.trailerButton setTitle:@"Watch Trailer"];
    [self.mainScrollView addSubview:self.trailerButton];
    
    self.websiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.websiteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.websiteButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.websiteButton.titleColor = HEXColor(0xABADAF);
    [self.websiteButton setTitle:@"Visit Official Website"];
    [self.mainScrollView addSubview:self.websiteButton];
    
}

- (void)setDefaultStylesForLabels:(UILabel*)label
{
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = UILineBreakModeWordWrap;
}

@end
