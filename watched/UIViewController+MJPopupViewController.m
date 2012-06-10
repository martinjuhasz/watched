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

#define kPopupModalAnimationDuration 0.35
#define kMJSourceViewTag 23941
#define kMJPopupViewTag 23942
#define kMJBackgroundViewTag 23943

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
    UIView *backgroundView = [sourceView viewWithTag:kMJBackgroundViewTag];
    
    if(animationType == PopupViewAnimationSlide) {
        [self slideViewOut:popupView sourceView:sourceView backgroundView:backgroundView];
    } else {
        [self fadeViewOut:popupView sourceView:sourceView backgroundView:backgroundView];
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
    
    // Add a black Background
    UIView *background = [[UIView alloc] initWithFrame:sourceView.bounds];
    background.backgroundColor = [UIColor blackColor];
    background.tag = kMJBackgroundViewTag;
    background.alpha = 0.0f;
    [sourceView addSubview:background];
    
    // Make the Background Clickable
    UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.backgroundColor = [UIColor clearColor];
    dismissButton.frame = sourceView.frame;
    [background addSubview:dismissButton];
    
    [sourceView addSubview:popupView];
    
    if(animationType == PopupViewAnimationSlide) {
        [dismissButton addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeSlide) forControlEvents:UIControlEventTouchUpInside];
        [self slideViewIn:popupView sourceView:sourceView backgroundView:background];
    } else {
        [dismissButton addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeFade) forControlEvents:UIControlEventTouchUpInside];
        [self fadeViewIn:popupView sourceView:sourceView backgroundView:background];
    }
   
    
}

-(UIView*)topView {
    UIViewController *recentView = self;
    
    while (recentView.parentViewController != nil) {
        recentView = recentView.parentViewController;
    }
    return recentView.view;
}

- (void)dismissPopupViewControllerWithanimationTypeSlide
{
    [self dismissPopupViewControllerWithanimationType:PopupViewAnimationSlide];
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



////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animations

#pragma mark --- Slide

- (void)slideViewIn:(UIView*)popupView sourceView:(UIView*)sourceView backgroundView:(UIView*)background
{
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.frame.size;
    CGSize popupSize = popupView.frame.size;
    CGRect popupStartRect = CGRectMake((sourceSize.width - popupSize.width) / 2, 
                                       sourceSize.height, 
                                       popupSize.width, 
                                       popupSize.height);
    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2, 
                                     (sourceSize.height - popupSize.height) / 2,
                                     popupSize.width, 
                                     popupSize.height);
    
    // Set starting properties
    popupView.frame = popupStartRect;
    popupView.layer.shadowColor = [[UIColor blackColor] CGColor];
    popupView.layer.shadowOffset = CGSizeMake(0, -2);
    popupView.layer.shadowRadius = 5.0f;
    popupView.layer.shadowOpacity = 0.8f;
    background.alpha = 0.0f;
    
    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
        popupView.frame = popupEndRect;
        background.alpha = 0.5f;
    } completion:^(BOOL finished) {
        [self notifyAppearForView:popupView];
    }];
}

- (void)slideViewOut:(UIView*)popupView sourceView:(UIView*)sourceView backgroundView:(UIView*)background
{
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.frame.size;
    CGSize popupSize = popupView.frame.size;
    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2, 
                                     -popupSize.height, 
                                     popupSize.width, 
                                     popupSize.height);
    
    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
        popupView.frame = popupEndRect;
        background.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self notifyDisappearForView:popupView];
        [popupView removeFromSuperview];
        [background removeFromSuperview];
    }];
}

#pragma mark --- Fade

- (void)fadeViewIn:(UIView*)popupView sourceView:(UIView*)sourceView backgroundView:(UIView*)background
{
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.frame.size;
    CGSize popupSize = popupView.frame.size;
    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2, 
                                     (sourceSize.height - popupSize.height) / 2,
                                     popupSize.width, 
                                     popupSize.height);
    
    // Set starting properties
    popupView.frame = popupEndRect;
    popupView.layer.shadowColor = [[UIColor blackColor] CGColor];
    popupView.layer.shadowOffset = CGSizeMake(0, -2);
    popupView.layer.shadowRadius = 5.0f;
    popupView.layer.shadowOpacity = 0.8f;
    popupView.alpha = 0.0f;
    background.alpha = 0.0f;
    
    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
        background.alpha = 0.5f;
        popupView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self notifyAppearForView:popupView];
    }];
}

- (void)fadeViewOut:(UIView*)popupView sourceView:(UIView*)sourceView backgroundView:(UIView*)background
{
    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
        background.alpha = 0.0f;
        popupView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self notifyDisappearForView:popupView];
        [popupView removeFromSuperview];
        [background removeFromSuperview];
    }];
}


@end
