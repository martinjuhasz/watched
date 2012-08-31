//
//  BrowserBarButtonItem.h
//  watched
//
//  Created by Martin Juhasz on 30.08.12.
//
//

#import <UIKit/UIKit.h>

@interface BrowserBarButtonItem : UIBarButtonItem

@property (nonatomic, strong) UIButton *button;

+ (BrowserBarButtonItem*)browserItemWithImageName:(NSString*)imageName disabledImageName:(NSString*)disabledImageName;

@end
