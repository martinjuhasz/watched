//
//  UIViewController+FindUIViewController.h
//  watched
//
//  Created by Martin Juhasz on 10.06.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(FindUIViewController)
- (UIViewController *)firstAvailableUIViewController;
- (id) traverseResponderChainForUIViewController;
@end
