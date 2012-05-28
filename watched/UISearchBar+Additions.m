//
//  UISearchBar+Additions.m
//  MovieRater
//
//  Created by Martin Juhasz on 03.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UISearchBar+Additions.h"

@implementation UISearchBar(Additions)

- (void)setCancelButtonActive {
    for (UIView *possibleButton in self.subviews)
    {
        if ([possibleButton isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton*)possibleButton;
            cancelButton.enabled = YES;
            break;
        }
    }
}

@end
