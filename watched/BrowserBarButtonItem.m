//
//  BrowserBarButtonItem.m
//  watched
//
//  Created by Martin Juhasz on 30.08.12.
//
//

#import "BrowserBarButtonItem.h"

@implementation BrowserBarButtonItem

+ (BrowserBarButtonItem*)browserItemWithImageName:(NSString*)imageName disabledImageName:(NSString*)disabledImageName
{
    UIImage *buttonImage = [UIImage imageNamed:imageName];
    
    // Initialize the UIButton
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    [aButton setImage:[UIImage imageNamed:disabledImageName] forState:UIControlStateDisabled];
    
    aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    aButton.showsTouchWhenHighlighted = YES;
    
    // Initialize the UIBarButtonItem
    BrowserBarButtonItem *aBarButtonItem = [[self alloc] initWithCustomView:aButton];
    aBarButtonItem.button = aButton;
    
    return aBarButtonItem;
}

@end
