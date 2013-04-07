//
//  UIViewController+MJPopupViewController.h
//  MJModalViewController
//
//  Created by Martin Juhasz on 11.05.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PopupViewAnimationSlideBottomTop = 1,
    PopupViewAnimationSlideRightLeft,
    PopupViewAnimationSlideBottomBottom,
    PopupViewAnimationFade
} PopupViewAnimation;

@interface UIViewController (MJPopupViewController)

@property (nonatomic, retain) UIViewController *popupViewController;

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(PopupViewAnimation)animationType;
- (void)dismissPopupViewControllerWithanimationType:(PopupViewAnimation)animationType completion:(void (^)(void))complete;

@end

@protocol MJPopupViewControllerDelegate<NSObject>
@optional
- (void)MJPopViewControllerDidAppearCompletely;
- (void)MJPopViewControllerDidDisappearCompletely;
@end
