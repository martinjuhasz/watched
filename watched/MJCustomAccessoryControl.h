//
//  MJCustomAccessoryControl.h
//  watched
//
//  Created by Martin Juhasz on 24.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJCustomAccessoryControl : UIControl {
    BOOL highlightedImageSetted;
}

@property (nonatomic, strong) UIImageView *controlImageView;

+ (MJCustomAccessoryControl*)accessory;
@end
