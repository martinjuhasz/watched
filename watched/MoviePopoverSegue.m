//
//  MoviePopoverSegue.m
//  watched
//
//  Created by Martin Juhasz on 03.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoviePopoverSegue.h"
#import "SearchMoviePopupViewController.h"

@implementation MoviePopoverSegue

- (void) perform {
    UIViewController *sourceViewController = (UIViewController *)self.sourceViewController;
    SearchMoviePopupViewController *destinationViewController = (SearchMoviePopupViewController *)self.destinationViewController;
    
    destinationViewController.view.bounds = [[UIScreen mainScreen] bounds];
    destinationViewController.backgroundView.alpha = 0.0f;
    destinationViewController.popoverView.frame = CGRectMake(25.0f, 480.0f, 270.0f, 310.0f);

    [sourceViewController.view addSubview:destinationViewController.view];
    
    [UIView animateWithDuration:0.7 animations:^() {
        destinationViewController.backgroundView.alpha = 1.0f;
    }];
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^() {
        destinationViewController.popoverView.frame = CGRectMake(25.0f, 40.0f, 270.0f, 310.0f);
    } completion:nil];
    
}

@end
