//
//  MJReloadAccessoryControl.h
//  watched
//
//  Created by Martin Juhasz on 30.03.13.
//
//

#import <UIKit/UIKit.h>

@interface MJReloadAccessoryControl : UIControl {
BOOL highlightedImageSetted;
}

@property (nonatomic, strong) UIImageView *controlImageView;

+ (MJReloadAccessoryControl*)accessory;
@end
