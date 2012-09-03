//
//  UIViewController+MJPopupViewController.m
//  MJModalViewController
//
//  Created by Martin Juhasz on 11.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+MJPopupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+FindUIViewController.h"
#import "MJPopupBackgroundView.h"

#define kPopupModalAnimationDuration 0.35
#define kMJSourceViewTag 23941
#define kMJPopupViewTag 23942
#define kMJBackgroundViewTag 23943
#define kMJOverlayViewTag 23945

@interface UIViewController (MJPopupViewControllerPrivate)
- (UIView*)topView;
- (void)presentPopupView:(UIView*)popupView;
@end



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public

@implementation UIViewController (MJPopupViewController)

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(PopupViewAnimation)animationType
{
    [self presentPopupView:popupViewController.view animationType:animationType];
}

- (void)dismissPopupViewControllerWithanimationType:(PopupViewAnimation)animationType
{
    UIView *sourceView = [self topView];
    UIView *popupView = [sourceView viewWithTag:kMJPopupViewTag];
    UIView *overlayView = [sourceView viewWithTag:kMJOverlayViewTag];
    
    if(animationType == PopupViewAnimationSlideBottomTop || animationType == PopupViewAnimationSlideBottomBottom || animationType == PopupViewAnimationSlideRightLeft) {
        [self slideViewOut:popupView sourceView:sourceView overlayView:overlayView withAnimationType:animationType];
    } else {
        [self fadeViewOut:popupView sourceView:sourceView overlayView:overlayView];
    }
}



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Handling

- (void)presentPopupView:(UIView*)popupView animationType:(PopupViewAnimation)animationType
{
    UIView *sourceView = [self topView];
    sourceView.tag = kMJSourceViewTag;
    popupView.tag = kMJPopupViewTag;
    
    // check if source view controller is not in destination
    if ([sourceView.subviews containsObject:popupView]) return;
    
    // customize popupView
//    popupView.layer.cornerRadius = 10.0f;
//    popupView.layer.borderWidth = 1.0f;
//    popupView.layer.borderColor = [UIColor blackColor].CGColor;
//    popupView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:popupView.bounds cornerRadius:6.0f].CGPath;
//    popupView.layer.masksToBounds = YES;
////    popupView.layer.shadowPath = [UIBezierPath bezierPathWithRect:popupView.bounds].CGPath;
////    popupView.layer.masksToBounds = NO;
//    popupView.layer.shadowOffset = CGSizeMake(5, 5);
//    popupView.layer.shadowRadius = 5;
//    popupView.layer.shadowOpacity = 0.5;

    
    // Add semi overlay
    UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
    overlayView.tag = kMJOverlayViewTag;
    overlayView.backgroundColor = [UIColor clearColor];
    
    // BackgroundView
    MJPopupBackgroundView *backgroundView = [[MJPopupBackgroundView alloc] initWithFrame:sourceView.bounds];
    backgroundView.tag = kMJBackgroundViewTag;
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.alpha = 0.0f;
    [overlayView addSubview:backgroundView];
    
    // Make the Background Clickable
    UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.backgroundColor = [UIColor clearColor];
    dismissButton.frame = sourceView.frame;
    dismissButton.enabled = NO;
    [overlayView addSubview:dismissButton];
    
    popupView.alpha = 0.0f;
    [overlayView addSubview:popupView];
    [sourceView addSubview:overlayView];
    
    if(animationType == PopupViewAnimationSlideBottomTop) {
        [dismissButton addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeSlideBottomTop) forControlEvents:UIControlEventTouchUpInside];
        [self slideViewIn:popupView sourceView:sourceView overlayView:overlayView withAnimationType:animationType];
    } else if (animationType == PopupViewAnimationSlideRightLeft) {
        [dismissButton addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeSlideRightLeft) forControlEvents:UIControlEventTouchUpInside];
        [self slideViewIn:popupView sourceView:sourceView overlayView:overlayView withAnimationType:animationType];
    } else if (animationType == PopupViewAnimationSlideBottomBottom) {
        [dismissButton addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeSlideBottomBottom) forControlEvents:UIControlEventTouchUpInside];
        [self slideViewIn:popupView sourceView:sourceView overlayView:overlayView withAnimationType:animationType];
    } else {
        [dismissButton addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeFade) forControlEvents:UIControlEventTouchUpInside];
        [self fadeViewIn:popupView sourceView:sourceView overlayView:overlayView];
    }    
}

-(UIView*)topView {
    UIViewController *recentView = self;
    
    while (recentView.parentViewController != nil) {
        recentView = recentView.parentViewController;
    }
    return recentView.view;
}

- (void)dismissPopupViewControllerWithanimationTypeSlideBottomTop
{
    [self dismissPopupViewControllerWithanimationType:PopupViewAnimationSlideBottomTop];
}

- (void)dismissPopupViewControllerWithanimationTypeSlideBottomBottom
{
    [self dismissPopupViewControllerWithanimationType:PopupViewAnimationSlideBottomBottom];
}

- (void)dismissPopupViewControllerWithanimationTypeSlideRightLeft
{
    [self dismissPopupViewControllerWithanimationType:PopupViewAnimationSlideRightLeft];
}

- (void)dismissPopupViewControllerWithanimationTypeFade
{
    [self dismissPopupViewControllerWithanimationType:PopupViewAnimationFade];
}

- (void)notifyAppearForView:(UIView*)popupView
{
    UIViewController *popupViewController = [popupView firstAvailableUIViewController];
    if (popupViewController && [popupViewController respondsToSelector:@selector(MJPopViewControllerDidAppearCompletely)]) {
        [popupViewController performSelector:@selector(MJPopViewControllerDidAppearCompletely)];
    }
}

- (void)notifyDisappearForView:(UIView*)popupView
{
    UIViewController *popupViewController = [popupView firstAvailableUIViewController];
    if (popupViewController && [popupViewController respondsToSelector:@selector(MJPopViewControllerDidDisappearCompletely)]) {
        [popupViewController performSelector:@selector(MJPopViewControllerDidDisappearCompletely)];
    }
}



//////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animations

#pragma mark --- Slide

- (void)slideViewIn:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView withAnimationType:(PopupViewAnimation)animationType
{
    UIView *backgroundView = [overlayView viewWithTag:kMJBackgroundViewTag];
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.frame.size;
    CGSize popupSize = popupView.frame.size;
    
    CGRect popupStartRect;
    if(animationType == PopupViewAnimationSlideBottomTop || animationType == PopupViewAnimationSlideBottomBottom) {
        popupStartRect = CGRectMake(floorf((sourceSize.width - popupSize.width) / 2),
                                    sourceSize.height, 
                                    popupSize.width, 
                                    popupSize.height);
    } else {
        popupStartRect = CGRectMake(sourceSize.width, 
                                    floorf((sourceSize.height - popupSize.height) / 2),
                                    popupSize.width, 
                                    popupSize.height);
    }
    CGRect popupEndRect = CGRectMake(floorf((sourceSize.width - popupSize.width) / 2),
                                     floorf((sourceSize.height - popupSize.height) / 2),
                                     popupSize.width, 
                                     popupSize.height);
    // Set starting properties
    popupView.frame = popupStartRect;
    popupView.alpha = 1.0f;
    [UIView animateWithDuration:kPopupModalAnimationDuration delay:0.0f options:UIViewAnimationCurveEaseOut animations:^{
        backgroundView.alpha = 1.0f;
        popupView.frame = popupEndRect;
    } completion:^(BOOL finished) {
        [self notifyAppearForView:popupView];
    }];
}

- (void)slideViewOut:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView withAnimationType:(PopupViewAnimation)animationType
{
    UIView *backgroundView = [overlayView viewWithTag:kMJBackgroundViewTag];
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.frame.size;
    CGSize popupSize = popupView.frame.size;
    CGRect popupEndRect;
    if(animationType == PopupViewAnimationSlideBottomTop) {
        popupEndRect = CGRectMake(floorf((sourceSize.width - popupSize.width) / 2),
                                  -popupSize.height, 
                                  popupSize.width, 
                                  popupSize.height);
    } else if(animationType == PopupViewAnimationSlideBottomBottom) {
        popupEndRect = CGRectMake(floorf((sourceSize.width - popupSize.width) / 2),
                                  sourceSize.height, 
                                  popupSize.width, 
                                  popupSize.height);
    } else {
        popupEndRect = CGRectMake(-popupSize.width, 
                                  popupView.frame.origin.y, 
                                  popupSize.width, 
                                  popupSize.height);
    }
    
    [UIView animateWithDuration:kPopupModalAnimationDuration delay:0.0f options:UIViewAnimationCurveEaseIn animations:^{
        popupView.frame = popupEndRect;
        backgroundView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [popupView removeFromSuperview];
        [overlayView removeFromSuperview];
        [self notifyDisappearForView:popupView];
    }];
}

#pragma mark --- Fade

- (void)fadeViewIn:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView
{
    UIView *backgroundView = [overlayView viewWithTag:kMJBackgroundViewTag];
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.frame.size;
    CGSize popupSize = popupView.frame.size;
    CGRect popupEndRect = CGRectMake(floorf((sourceSize.width - popupSize.width) / 2),
                                     floorf((sourceSize.height - popupSize.height) / 2),
                                     popupSize.width, 
                                     popupSize.height);
    
    // Set starting properties
    popupView.frame = popupEndRect;
    popupView.alpha = 0.0f;
    
    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
        backgroundView.alpha = 0.5f;
        popupView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self notifyAppearForView:popupView];
    }];
}

- (void)fadeViewOut:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView
{
    UIView *backgroundView = [overlayView viewWithTag:kMJBackgroundViewTag];
    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
        backgroundView.alpha = 0.0f;
        popupView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [popupView removeFromSuperview];
        [overlayView removeFromSuperview];
        [self notifyDisappearForView:popupView];
    }];
}


@end
