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
#define kMJScreenshotViewTag 23944
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
    
    if(animationType == PopupViewAnimationSlide) {
        [self slideViewOut:popupView sourceView:sourceView overlayView:overlayView];
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
    
    // Add semi overlay
    UIView * overlay = [[UIView alloc] initWithFrame:sourceView.bounds];
    overlay.tag = kMJOverlayViewTag;
    overlay.backgroundColor = [UIColor blackColor];
    
    // Add Image kMJScreenshotViewTag
    UIGraphicsBeginImageContextWithOptions(sourceView.bounds.size, NO, 0);
    [sourceView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tag = kMJScreenshotViewTag;
    [overlay addSubview:imageView];
    [sourceView addSubview:overlay];
    
    // Make the Background Clickable
    UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.backgroundColor = [UIColor clearColor];
    dismissButton.frame = sourceView.frame;
    [overlay addSubview:dismissButton];
    
    popupView.alpha = 0.0f;
    [overlay addSubview:popupView];
    
    if(animationType == PopupViewAnimationSlide) {
        [dismissButton addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeSlide) forControlEvents:UIControlEventTouchUpInside];
        [self slideViewIn:popupView sourceView:sourceView backgroundView:imageView];
    } else {
        [dismissButton addTarget:self action:@selector(dismissPopupViewControllerWithanimationTypeFade) forControlEvents:UIControlEventTouchUpInside];
        [self fadeViewIn:popupView sourceView:sourceView backgroundView:imageView];
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



//////////////////////////////////////////////////////////////////////////////
//#pragma mark -
//#pragma mark Animations
//
//#pragma mark --- Slide
//
//- (void)slideViewIn:(UIView*)popupView sourceView:(UIView*)sourceView backgroundView:(UIView*)background
//{
//    // Generating Start and Stop Positions
//    CGSize sourceSize = sourceView.frame.size;
//    CGSize popupSize = popupView.frame.size;
//    CGRect popupStartRect = CGRectMake((sourceSize.width - popupSize.width) / 2, 
//                                       sourceSize.height, 
//                                       popupSize.width, 
//                                       popupSize.height);
//    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2, 
//                                     (sourceSize.height - popupSize.height) / 2,
//                                     popupSize.width, 
//                                     popupSize.height);
//    
//    // Set starting properties
//    popupView.frame = popupStartRect;
//    popupView.layer.shadowColor = [[UIColor blackColor] CGColor];
//    popupView.layer.shadowOffset = CGSizeMake(0, -2);
//    popupView.layer.shadowRadius = 5.0f;
//    popupView.layer.shadowOpacity = 0.8f;
//    background.alpha = 0.0f;
//    
//    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
//        popupView.frame = popupEndRect;
//        background.alpha = 0.5f;
//    } completion:^(BOOL finished) {
//        [self notifyAppearForView:popupView];
//    }];
//}
//
//- (void)slideViewOut:(UIView*)popupView sourceView:(UIView*)sourceView backgroundView:(UIView*)background
//{
//    // Generating Start and Stop Positions
//    CGSize sourceSize = sourceView.frame.size;
//    CGSize popupSize = popupView.frame.size;
//    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2, 
//                                     -popupSize.height, 
//                                     popupSize.width, 
//                                     popupSize.height);
//    
//    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
//        popupView.frame = popupEndRect;
//        background.alpha = 0.0f;
//    } completion:^(BOOL finished) {
//        [self notifyDisappearForView:popupView];
//        [popupView removeFromSuperview];
//        [background removeFromSuperview];
//    }];
//}
//
//#pragma mark --- Fade
//
//- (void)fadeViewIn:(UIView*)popupView sourceView:(UIView*)sourceView backgroundView:(UIView*)background
//{
//    // Generating Start and Stop Positions
//    CGSize sourceSize = sourceView.frame.size;
//    CGSize popupSize = popupView.frame.size;
//    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2, 
//                                     (sourceSize.height - popupSize.height) / 2,
//                                     popupSize.width, 
//                                     popupSize.height);
//    
//    // Set starting properties
//    popupView.frame = popupEndRect;
//    popupView.layer.shadowColor = [[UIColor blackColor] CGColor];
//    popupView.layer.shadowOffset = CGSizeMake(0, -2);
//    popupView.layer.shadowRadius = 5.0f;
//    popupView.layer.shadowOpacity = 0.8f;
//    popupView.alpha = 0.0f;
//    background.alpha = 0.0f;
//    
//    [UIView animateWithDuration:kPopupModalAnimationDuration/2 animations:^{
//        background.alpha = 0.5f;
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:kPopupModalAnimationDuration/1.5 animations:^{
//            popupView.alpha = 1.0f;
//        } completion:^(BOOL finished) {
//            [self notifyAppearForView:popupView];
//        }];
//    }];
//}
//
//- (void)fadeViewOut:(UIView*)popupView sourceView:(UIView*)sourceView backgroundView:(UIView*)background
//{
//    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
//        background.alpha = 0.0f;
//        popupView.alpha = 0.0f;
//    } completion:^(BOOL finished) {
//        [self notifyDisappearForView:popupView];
//        [popupView removeFromSuperview];
//        [background removeFromSuperview];
//    }];
//}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Animations

#pragma mark --- Slide

- (void)slideViewIn:(UIView*)popupView sourceView:(UIView*)sourceView backgroundView:(UIImageView*)background
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
    popupView.alpha = 1.0f;
    
    [UIView animateWithDuration:kPopupModalAnimationDuration/2 animations:^{
        background.alpha = 0.5f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
            popupView.frame = popupEndRect;
        } completion:^(BOOL finished) {
            [self notifyAppearForView:popupView];
        }];
    }];
}

- (void)slideViewOut:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView
{
    // Generating Start and Stop Positions
    UIImageView *imageView = (UIImageView*)[overlayView viewWithTag:kMJScreenshotViewTag];
    CGSize sourceSize = sourceView.frame.size;
    CGSize popupSize = popupView.frame.size;
    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2, 
                                     -popupSize.height, 
                                     popupSize.width, 
                                     popupSize.height);
    
    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
        popupView.frame = popupEndRect;
        imageView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [popupView removeFromSuperview];
        [overlayView removeFromSuperview];
        [self notifyDisappearForView:popupView];
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
    
    [UIView animateWithDuration:kPopupModalAnimationDuration/2 animations:^{
        background.alpha = 0.5f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
            popupView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [self notifyAppearForView:popupView];
        }];
    }];
}

- (void)fadeViewOut:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView
{
    UIImageView *imageView = (UIImageView*)[overlayView viewWithTag:kMJScreenshotViewTag];
    [UIView animateWithDuration:kPopupModalAnimationDuration animations:^{
        imageView.alpha = 1.0f;
        popupView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [popupView removeFromSuperview];
        [overlayView removeFromSuperview];
        [self notifyDisappearForView:popupView];
    }];
}


@end
