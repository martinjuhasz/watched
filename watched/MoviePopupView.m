//
//  AddMovieView.m
//  watched
//
//  Created by Martin Juhasz on 17.10.12.
//
//

#import "MoviePopupView.h"
#import "UIButton+Additions.h"
#import "MJGradientView.h"
#import "UIView+Additions.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDictionary+ObjectForKeyOrNil.h"

#define kPopupOpenedHeight 140.0f

@interface MoviePopupView () {
    NSMutableArray *animations;
    BOOL didAppearCompletely;
}
@end


@implementation MoviePopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.startFrame = frame;
        animations = [[NSMutableArray alloc] init];
        self.isAnimating = NO;
        didAppearCompletely = NO;
        
        //
        self.layer.cornerRadius = 10.0f;
        self.layer.opaque = NO;
        self.opaque = NO;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        
        [self setupInterfaces];
        
        // setup interface
        [self addAnimation:PopupViewDisplayStateLoading animated:NO force:YES];
        
        
    }
    return self;
}

- (void)setupInterfaces
{
    
    //
    //  NavigationBar
    //
    _navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 44.0f)];

    // Cancel Button
    UIView *cancelView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 30.0f)];
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(2.0f, 1.0f, 55.0f, 30.0f)];
    [_cancelButton setTitle:NSLocalizedString(@"POPUP_DONEBUTTON", nil)];
    
    // cancel button styles
    UIImage *barButtonBgImage = [[UIImage imageNamed:@"g_barbutton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 4, 15, 4)];
    UIImage *barButtonBgImageActive = [[UIImage imageNamed:@"g_barbutton_active.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 4, 15, 4)];
    [_cancelButton setBackgroundImage:barButtonBgImage];
    [_cancelButton setBackgroundImage:barButtonBgImageActive forState:UIControlStateHighlighted];
    _cancelButton.titleLabel.textColor = HEXColor(0xFFFFFF);
    _cancelButton.titleLabel.shadowColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.44f];
    _cancelButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    [_cancelButton setTitleColor:HEXColor(0x730000) forState:UIControlStateDisabled];
    [_cancelButton setTitleShadowColor:HEXColor(0xC60000) forState:UIControlStateDisabled];
    
    
    // adding cancel button
    [_cancelButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [cancelView addSubview:_cancelButton];
    UIBarButtonItem *cancelBarItem = [[UIBarButtonItem alloc] initWithCustomView:cancelView];
    UINavigationItem *item = [[UINavigationItem alloc] init];
    item.rightBarButtonItem = cancelBarItem;
    item.hidesBackButton = YES;
    [_navBar pushNavigationItem:item animated:NO];
    
    [self addSubview:_navBar];
    
    
    //
    //  CoverContainerView
    //
    
    _coverContainerView = [[MJGradientView alloc] initWithFrame:CGRectMake(0.0f, _navBar.bottom, self.frame.size.width, 116.0f)];
    _coverContainerView.startColor = HEXColor(0xededed);
    _coverContainerView.stopColor = HEXColor(0xd7d7d6);
    _coverContainerView.bottomColor = HEXColor(0x7d7d7d);
    _coverContainerView.topColor = HEXColor(0xf5f5f5);
    [self addSubview:_coverContainerView];
    
    
    _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9.0f, 9.0f, 71.0f, 99.0f)];
    _coverImageView.image = [UIImage imageNamed:@"dv_placeholder-cover.png"];
    [_coverContainerView addSubview:_coverImageView];
    
    UIImageView *coverBorderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dv_cover-overlay.png"]];
    coverBorderImageView.frame = CGRectMake(7.0f, 7.0, 75.0f, 103.0f);
    [_coverContainerView addSubview:coverBorderImageView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.0f, 9.0f, 190.0f, 21.0f)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    _titleLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.4f];
    _titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [_coverContainerView addSubview:_titleLabel];
    
    _yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(90.0f, 33.0f, 190.0f, 21.0f)];
    _yearLabel.textColor = HEXColor(0x5a5a5a);
    _yearLabel.backgroundColor = [UIColor clearColor];
    [_yearLabel setFont:[UIFont systemFontOfSize:14.0f]];
    _yearLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.33f];
    _yearLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [_coverContainerView addSubview:_yearLabel];
    
    
    
    
    //
    // ContentContainerView
    //
    
    _contentContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, _coverContainerView.bottom - 142.0f, self.frame.size.width, 142.0f)];
    _contentContainerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pv_bg_content_bottom.png"]];
    [self addSubview:_contentContainerView];
    
    _overviewTextView = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 100.0f)];
    _overviewTextView.backgroundColor = [UIColor clearColor];
    _overviewTextView.textColor = HEXColor(0x000000);
    [_overviewTextView setFont:[UIFont systemFontOfSize:12.0f]];
    _overviewTextView.layer.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.4f].CGColor;
    _overviewTextView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    _overviewTextView.layer.shadowOpacity = 1.0f;
    _overviewTextView.layer.shadowRadius = 1.0f;
    _overviewTextView.editable = NO;
    [_contentContainerView addSubview:_overviewTextView];
    
    UIImageView *bottomTextFadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pv_mask-bottom.png"]];
    bottomTextFadingImageView.frame = CGRectMake(0.0f, _overviewTextView.bottom - 8.0f, _overviewTextView.width, 8.0f);
    [_contentContainerView addSubview:bottomTextFadingImageView];
    
    
    
    // Add Button
    _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addButton.frame = CGRectMake(7.0f, _contentContainerView.height - 36.0f, self.frame.size.width - 14.0f, 29.0f);
    UIImage *addBtnImage = [[UIImage imageNamed:@"g_button_popover_add.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f)];
    UIImage *addBtnImageDis = [[UIImage imageNamed:@"g_button_popover_add_disabled.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f)];
    UIImage *addBtnImageHigh = [[UIImage imageNamed:@"g_button_popover_add_highlighted.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f)];
    [_addButton setBackgroundImage:addBtnImage];
    [_addButton setBackgroundImage:addBtnImageDis forState:UIControlStateDisabled];
    [_addButton setBackgroundImage:addBtnImageHigh forState:UIControlStateHighlighted];
    [_addButton setTitle:NSLocalizedString(@"POPUP_SAVEBUTTON_ADD", nil)];
    
    _addButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    _addButton.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [_addButton setTitleShadowColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.10f]];
    [_addButton setTitleColor:HEXColor(0x858585) forState:UIControlStateDisabled];
    [_addButton setTitleShadowColor:[UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.33f] forState:UIControlStateDisabled];
    
    [_contentContainerView addSubview:_addButton];
    _contentContainerView.hidden = YES;

    
    //
    // Loading View
    //

    _loadingView = [[MJGradientView alloc] initWithFrame:CGRectMake(0.0f, _navBar.bottom, self.frame.size.width, 116.0f)];
    _loadingView.startColor = HEXColor(0xededed);
    _loadingView.stopColor = HEXColor(0xd7d7d6);
    _loadingView.bottomColor = HEXColor(0x7d7d7d);
    _loadingView.topColor = HEXColor(0xf5f5f5);
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator startAnimating];
    [activityIndicator centerInView:_loadingView];
    [_loadingView addSubview:activityIndicator];
    
    [self addSubview:_loadingView];
    
    
    
    //
    // Error View
    //
    
    _errorView = [[MJGradientView alloc] initWithFrame:CGRectMake(0.0f, _navBar.bottom, self.frame.size.width, 116.0f)];
    _errorView.startColor = HEXColor(0xededed);
    _errorView.stopColor = HEXColor(0xd7d7d6);
    _errorView.bottomColor = HEXColor(0x7d7d7d);
    _errorView.topColor = HEXColor(0xf5f5f5);
    
    [self addSubview:_errorView];
    
    UIImageView *errorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pv_error.png"]];
    errorImageView.frame = CGRectMake(0.0f, 0.0f, 52.0f, 46.0f);
    [errorImageView centerInView:_errorView];
    errorImageView.frame = CGRectMake(errorImageView.frame.origin.x, 8.0f, errorImageView.frame.size.width, errorImageView.frame.size.height);
    [_errorView addSubview:errorImageView];
    
    UILabel *errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 60.0f, self.size.width, 25.0f)];
    errorLabel.text = [NSLocalizedString(@"POPUP_TMDBERROR-INFO", nil) uppercaseString];
    errorLabel.textAlignment = NSTextAlignmentCenter;
    errorLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    errorLabel.backgroundColor = [UIColor clearColor];
    errorLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.33f];
    errorLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [_errorView addSubview:errorLabel];
    
    UILabel *errorDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 78.0f, self.size.width, 25.0f)];
    errorDescLabel.textColor = HEXColor(0x666666);
    errorDescLabel.text = NSLocalizedString(@"POPUP_TMDBERROR-LOAD", nil);
    errorDescLabel.textAlignment = NSTextAlignmentCenter;
    errorDescLabel.font = [UIFont systemFontOfSize:12.0f];
    errorDescLabel.backgroundColor = [UIColor clearColor];
    errorDescLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.33f];
    errorDescLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    [_errorView addSubview:errorDescLabel];
}

- (void)slideContentViewForState:(PopupViewDisplayState)state completion:(void (^)(void))completionBlock
{
    CGRect endFrame;
    CGFloat popupHeight;
    
    if(state == PopupViewDisplayStateLoading) {
        endFrame = CGRectMake(0.0f, _coverContainerView.bottom - _contentContainerView.height, _contentContainerView.width, _contentContainerView.height);
        popupHeight = _startFrame.size.height;
    } else if(state == PopupViewDisplayStateError) {
        endFrame = CGRectMake(0.0f, _coverContainerView.bottom - _contentContainerView.height + 44.0f, _contentContainerView.width, _contentContainerView.height);
        popupHeight = _startFrame.size.height + 44.0f;
    } else if(state == PopupViewDisplayStateContent) {
        if(_overviewTextView.text && ![_overviewTextView.text isEqualToString:@""]) {
            endFrame = CGRectMake(0.0f, _coverContainerView.bottom, _contentContainerView.width, _contentContainerView.height);
            popupHeight = _startFrame.size.height + _contentContainerView.height;
        } else {
            endFrame = CGRectMake(0.0f, _coverContainerView.bottom - _contentContainerView.height + 44.0f, _contentContainerView.width, _contentContainerView.height);
            popupHeight = _startFrame.size.height + 44.0f;
        }
        
    }
    
    [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationCurveEaseOut animations:^{
        _contentContainerView.frame = endFrame;
        CGRect popupFrame = self.frame;
        popupFrame.size.height = popupHeight;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        popupFrame.origin.y = floorf((screenRect.size.height - popupHeight) / 2);
        self.frame = popupFrame;
    } completion:^(BOOL finished) {
        completionBlock();
    }];
}

- (void)setOverviewContent:(NSString*)content
{
    if(!content || [content isEqualToString:@""]) return;
    
    NSString *overviewTitle = [NSLocalizedString(@"DETAIL_DESCRIPTION_TITLE", nil) uppercaseString];
    NSString *contentString = [NSString stringWithFormat:@"%@\n%@", overviewTitle, content];
    NSMutableAttributedString *cAttrString = [[NSMutableAttributedString alloc] initWithString:contentString];
    [cAttrString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:10.0f] range:NSMakeRange(0, overviewTitle.length)];
    _overviewTextView.attributedText = cAttrString;
}

- (void)setDisplayState:(PopupViewDisplayState)aDisplayState
{
    [self addAnimation:aDisplayState animated:YES];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.layer.masksToBounds = YES;
}

// hit this if the start animation is finished
- (void)viewAppeardCompletely
{
    didAppearCompletely = YES;
    [self animate];
}

- (void)addAnimation:(PopupViewDisplayState)aState animated:(BOOL)animated
{
    [self addAnimation:aState animated:animated force:NO];
}

- (void)addAnimation:(PopupViewDisplayState)aState animated:(BOOL)animated force:(BOOL)force
{
    _displayState = aState;
    NSDictionary *animationDict = @{
        @"state":[NSNumber numberWithInt:aState],
        @"animated":[NSNumber numberWithBool:animated],
        @"force":[NSNumber numberWithBool:force]
    };
    [animations addObject:animationDict];
    [self animate];
}

- (void)animate
{
    BOOL forceAnimate = NO;
    NSDictionary *animationDict;
    
    // check if force the animation
    if([animations count] > 0) {
        animationDict = [animations objectAtIndex:0];
        forceAnimate = [[animationDict objectForKeyOrNil:@"force"] boolValue];
    }
    
    // else fallback if something else is happening
    if(!forceAnimate && (_isAnimating || [animations count] <= 0 || !didAppearCompletely)) return;
    
    [self transitToState:animationDict];
}

- (void)transitToState:(NSDictionary*)animationDict
{
    _isAnimating = YES;
    void(^endBlock)(void);
    CGRect endFrame;
    CGFloat popupHeight;
    BOOL animated = [[animationDict objectForKey:@"animated"] boolValue];
    PopupViewDisplayState displayState = [[animationDict objectForKey:@"state"] intValue];
    
    
    if(displayState == PopupViewDisplayStateLoading) {
        
        // handling the view stack
        [self bringSubviewToFront:_loadingView];
        _loadingView.hidden = NO;
//        self.navBar.topItem.title = NSLocalizedString(@"POPUP_TITLE_LOADING", nil);
        endBlock = ^(void) {
            _errorView.hidden = YES;
            _contentContainerView.hidden = YES;
        };
        
        
        // animating states
        endFrame = CGRectMake(0.0f, _coverContainerView.bottom - _contentContainerView.height, _contentContainerView.width, _contentContainerView.height);
        popupHeight = _startFrame.size.height;
        
    } else if(displayState == PopupViewDisplayStateError) {
        
        // handling the view stack
        [self bringSubviewToFront:_contentContainerView];
        [self bringSubviewToFront:_errorView];
        [_addButton setTitle:NSLocalizedString(@"POPUP_TMDBERROR-BUTTON", nil)];
        _errorView.hidden = NO;
        _contentContainerView.hidden = NO;
        endBlock = ^(void) {
            _loadingView.hidden = YES;
        };
        
        
        // animating states
        endFrame = CGRectMake(0.0f, _coverContainerView.bottom - _contentContainerView.height + 44.0f, _contentContainerView.width, _contentContainerView.height);
        popupHeight = _startFrame.size.height + 44.0f;
        
    } else if(displayState == PopupViewDisplayStateContent) {
        
        // handling the view stack
        [self bringSubviewToFront:_contentContainerView];
        [self bringSubviewToFront:_coverContainerView];
        _contentContainerView.hidden = NO;
        endBlock = ^(void) {
            _loadingView.hidden = YES;
            _errorView.hidden = YES;
        };
        
        
        // animating states
        if(_overviewTextView.text && ![_overviewTextView.text isEqualToString:@""]) {
            endFrame = CGRectMake(0.0f, _coverContainerView.bottom, _contentContainerView.width, _contentContainerView.height);
            popupHeight = _startFrame.size.height + _contentContainerView.height;
        } else {
            endFrame = CGRectMake(0.0f, _coverContainerView.bottom - _contentContainerView.height + 44.0f, _contentContainerView.width, _contentContainerView.height);
            popupHeight = _startFrame.size.height + 44.0f;
        }
        
    }
    
    [self bringSubviewToFront:_navBar];

    
    CGFloat animationTime = (animated) ? 0.4f : 0.0f;
    [UIView animateWithDuration:animationTime delay:0.0f options:UIViewAnimationCurveEaseOut animations:^{
        _contentContainerView.frame = endFrame;
        CGRect popupFrame = self.frame;
        popupFrame.size.height = popupHeight;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        popupFrame.origin.y = floorf((screenRect.size.height - popupHeight) / 2);
        self.frame = popupFrame;
    } completion:^(BOOL finished) {
        endBlock();
        _isAnimating = NO;
        [animations removeObject:animationDict];
        [self animate];
    }];
}



@end
