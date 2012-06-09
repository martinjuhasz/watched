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
@synthesize imageLoadingView;
@synthesize backdropImageView;
@synthesize backdropBottomShadow;
@synthesize posterImageView;
@synthesize backdropButton;
@synthesize posterButton;
@synthesize titleLabel;
@synthesize watchedSwitch;
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
@synthesize noteButton;
@synthesize trailerButton;
@synthesize castsButton;
@synthesize websiteButton;
@synthesize deleteButton;

#define kMBackdropHeight 160.0f
#define kMBackdropScrollStop 50.0f

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

// TODO: only layout needed
- (void)layoutSubviews
{
    [super layoutSubviews];

    self.backdropImageView.frame = CGRectMake(-30.0f, 0.0f, 380.0f, kMBackdropHeight);
    self.backdropBottomShadow.frame = CGRectMake(0.0f, 0.0f, 320.0f, kMBackdropHeight);
    self.posterImageView.frame = CGRectMake(9.0f, 93.0f, 89.0f, 126.0f);
    self.backdropButton.frame = CGRectMake(0.0f, 0.0f, 320.0f, kMBackdropHeight);
    self.posterButton.frame = CGRectMake(9.0f, 93.0f, 89.0f, 126.0f);
    
    self.titleLabel.frame = CGRectMake(110.0f, 170.0f, 206.0f, 46.0f);
    [self.titleLabel sizeToFitWithMaximumNumberOfLines:3];
    
    CGRect switchFrame = CGRectZero;
    switchFrame.origin.x = 110.0f;
    switchFrame.origin.y = 235.0f;
    self.watchedSwitch.frame = switchFrame;
    
    self.ratingView.frame = CGRectMake(0.0f, 278.0f, 320.0f, 56.0f);
    
    self.releaseDateLabel.frame = CGRectMake(13.0f, 385.0f, 145.0f, 25.0f);
    self.runtimeLabel.frame = CGRectMake(162.0f, 385.0f, 145.0f, 25.0f);
    
    // until here
    self.actor1ImageView.frame = CGRectMake(16.0f, 445.0f, 83.0f, 48.0f);
    self.actor2ImageView.frame = CGRectMake(118.0f, 445.0f, 83.0f, 48.0f);
    self.actor3ImageView.frame = CGRectMake(220.0f, 445.0f, 83.0f, 48.0f);
    self.actor1Label.frame = CGRectMake(16.0f, 490, 83.0f, 25.0f);
    self.actor2Label.frame = CGRectMake(118.0f, 490, 83.0f, 25.0f);
    self.actor3Label.frame = CGRectMake(220.0f, 490, 83.0f, 25.0f);
    
    self.overviewLabel.frame = CGRectMake(13.0f, 550.0f, 294.0f, 0.0f);
    [self.overviewLabel sizeToFit];
    
    self.noteButton.frame = CGRectMake(13.0f, self.overviewLabel.bottom + 30.0f, 294.0f, 25.0f);
    self.trailerButton.frame = CGRectMake(13.0f, self.noteButton.bottom + 30.0f, 294.0f, 25.0f);
    self.castsButton.frame = CGRectMake(13.0f, self.trailerButton.bottom + 15.0f, 294.0f, 25.0f);
    self.websiteButton.frame = CGRectMake(13.0f, self.castsButton.bottom + 15.0f, 294.0f, 25.0f);
    self.deleteButton.frame = CGRectMake(13.0f, self.websiteButton.bottom + 30.0f, 294.0f, 25.0f);
    
    [self.mainScrollView setContentSize:CGSizeMake(320.0f, self.deleteButton.bottom + 20.0f)];
}

- (void)setupContent
{
    self.backgroundColor = HEXColor(0x2f2f2f);
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.mainScrollView.delegate = self;
    [self addSubview:self.mainScrollView];
    
    self.backdropImageView = [[UIImageView alloc] init];
    self.backdropImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backdropImageView.clipsToBounds = YES;
    [self.mainScrollView addSubview:self.backdropImageView];
    
    self.backdropBottomShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dv_mask.png"]];
    self.backdropBottomShadow.contentMode = UIViewContentModeTop;
    self.backdropBottomShadow.clipsToBounds = YES;
    [self.mainScrollView addSubview:self.backdropBottomShadow];
    
    self.posterImageView = [[UIImageView alloc] init];
    self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.posterImageView.clipsToBounds = YES;
    [self.mainScrollView addSubview:self.posterImageView];
    
    self.backdropButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.mainScrollView addSubview:self.backdropButton];
    
    self.posterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.mainScrollView addSubview:self.posterButton];

    self.imageLoadingView = [[UIView alloc] initWithFrame:CGRectZero];
    self.imageLoadingView.backgroundColor = [UIColor blackColor];
    self.imageLoadingView.alpha = 0.0f;
    self.imageLoadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    activityIndicator.center = self.imageLoadingView.center;
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [activityIndicator startAnimating];
    [self.imageLoadingView addSubview:activityIndicator];
    
    self.titleLabel = [[UILabel alloc] init];
    [self setDefaultStylesForLabels:self.titleLabel];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    self.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.titleLabel.textColor = HEXColor(0xFFFFFF);
    [self.mainScrollView addSubview:self.titleLabel];
    
    self.watchedSwitch = [[UISwitch alloc] init];
    [self.mainScrollView addSubview:self.watchedSwitch];
    
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
    
    
    UILabel *overviewTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0f, 530.0f, 300.0f, 15.0f)];
    overviewTitleLabel.text = NSLocalizedString(@"DETAIL_DESCRIPTION_TITLE", nil);
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
    
    self.noteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.noteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.noteButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.noteButton.titleColor = HEXColor(0xABADAF);
    [self.noteButton setTitle:NSLocalizedString(@"BUTTON_ADD_NOTE", nil)];
    [self.mainScrollView addSubview:self.noteButton];
    
    self.trailerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.trailerButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.trailerButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.trailerButton.titleColor = HEXColor(0xABADAF);
    [self.trailerButton setTitle:NSLocalizedString(@"BUTTON_WATCH_TRAILER", nil)];
    [self.mainScrollView addSubview:self.trailerButton];
    
    self.castsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.castsButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.castsButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.castsButton.titleColor = HEXColor(0xABADAF);
    [self.castsButton setTitle:NSLocalizedString(@"BUTTON_SHOW_CAST", nil)];
    [self.mainScrollView addSubview:self.castsButton];
    
    self.websiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.websiteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.websiteButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.websiteButton.titleColor = HEXColor(0xABADAF);
    [self.websiteButton setTitle:NSLocalizedString(@"BUTTON_VISIT_HOMEPAGE", nil)];
    [self.mainScrollView addSubview:self.websiteButton];
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.deleteButton.titleLabel.adjustsFontSizeToFitWidth = NO;
    self.deleteButton.titleColor = HEXColor(0xABADAF);
    [self.deleteButton setTitle:NSLocalizedString(@"BUTTON_DELETE_MOVIE", nil)];
    [self.mainScrollView addSubview:self.deleteButton];
    
}

- (void)setDefaultStylesForLabels:(UILabel*)label
{
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.lineBreakMode = UILineBreakModeWordWrap;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    CGFloat scrollViewOffset = aScrollView.contentOffset.y;

    if(scrollViewOffset < 0.0f) {
        
        // minx max
        CGFloat minVal = MIN(scrollViewOffset,-kMBackdropScrollStop);
        CGFloat maxVal = MAX(scrollViewOffset,-kMBackdropScrollStop);
        
        // Backdrop
        CGRect imageViewRect = self.backdropImageView.frame;
        imageViewRect.origin.y = scrollViewOffset;
        imageViewRect.size.height = kMBackdropHeight - maxVal;

        // Shadow
        CGRect shadowRect = self.backdropBottomShadow.frame;
        shadowRect.size.height = kMBackdropHeight - (minVal + kMBackdropScrollStop);
        shadowRect.origin.y = minVal + kMBackdropScrollStop;
        
        // Loading Button
        if(self.imageLoadingView.frame.size.width == imageViewRect.size.width && self.imageLoadingView.alpha > 0.0f) {
            self.imageLoadingView.frame = imageViewRect;
        }
        
        // set em
        self.backdropBottomShadow.frame = shadowRect;
        self.backdropImageView.frame = imageViewRect;
        self.backdropButton.frame = imageViewRect;
    }
}

- (void)toggleLoadingViewForPosterType:(ImageType)aImageType
{
    UIImageView *targetView = (aImageType == ImageTypeBackdrop) ? self.backdropImageView : self.posterImageView;
    self.imageLoadingView.frame = targetView.frame;

    if(self.imageLoadingView.alpha <= 0.0f) {
        [self.mainScrollView insertSubview:self.imageLoadingView aboveSubview:targetView];
        [UIView animateWithDuration:(0.2) animations:^{
            self.imageLoadingView.alpha = 0.5f;
        }];
    } else {
        [UIView animateWithDuration:(0.2) animations:^{
            self.imageLoadingView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.imageLoadingView removeFromSuperview];
        }];
    }
}

@end
