//
//  AddMovieView.h
//  watched
//
//  Created by Martin Juhasz on 17.10.12.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    PopupViewDisplayStateLoading,
    PopupViewDisplayStateError,
    PopupViewDisplayStateContent
} PopupViewDisplayState;


@class MJGradientView;

@interface MoviePopupView : UIView

@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) MJGradientView *coverContainerView;
@property (strong, nonatomic) UIView *contentContainerView;
@property (strong, nonatomic) UIButton *addButton;
@property (assign, nonatomic) CGRect startFrame;
@property (strong, nonatomic) MJGradientView *loadingView;
@property (strong, nonatomic) UIImageView *coverImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *yearLabel;
@property (strong, nonatomic) UITextView *overviewTextView;
@property (strong, nonatomic) MJGradientView *errorView;
@property (assign, nonatomic) PopupViewDisplayState displayState;
@property (assign, nonatomic) BOOL isAnimating;

- (void)setOverviewContent:(NSString*)content;
- (void)viewAppeardCompletely;
- (void)addAnimation:(PopupViewDisplayState)aState animated:(BOOL)animated;
@end
