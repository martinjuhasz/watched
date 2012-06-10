//
//  UIViewController+MJPopupViewController.h
//  MJModalViewController
//
//  Created by Martin Juhasz on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PopupViewAnimationSlide = 1,
    PopupViewAnimationFade
} PopupViewAnimation;

@interface UIViewController (MJPopupViewController)

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(PopupViewAnimation)animationType;
- (void)dismissPopupViewControllerWithanimationType:(PopupViewAnimation)animationType;

@end

@protocol MJPopupViewControllerDelegate<NSObject>
@optional
- (void)MJPopViewControllerDidAppearCompletely;
- (void)MJPopViewControllerDidDisappearCompletely;
@end
