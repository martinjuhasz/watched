//
//  MJLoadingAccessoryControl.h
//  watched
//
//  Created by Martin Juhasz on 19.02.13.
//
//

#import <UIKit/UIKit.h>

@interface MJLoadingAccessoryControl : UIControl {
    BOOL highlightedImageSetted;
}

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

+ (MJLoadingAccessoryControl*)accessory;
@end
