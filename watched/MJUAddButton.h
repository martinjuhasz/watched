//
//  MJUAddButton.h
//  watched
//
//  Created by Martin Juhasz on 25.08.13.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MJUAddButtonState) {
    MJUAddButtonStateLoading,
    MJUAddButtonStateNormal
};

@interface MJUAddButton : UIButton

@property (nonatomic, assign) MJUAddButtonState state;
@property (nonatomic, strong) CALayer *rotatingLayer;
@property (nonatomic, strong) CALayer *borderLayer;

@end
