//
//  MJCustomCellBackgroundView.h
//  asdasd
//
//  Created by Martin Juhasz on 28.07.12.
//  Copyright (c) 2012 Martin Juhasz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableView+CellPosition.h"

@interface MJCustomCellBackgroundView : UIView {
    BOOL selected;
	BOOL grouped;
}

@property (assign, nonatomic) MJCellPosition position;
@property (strong, nonatomic) UIImageView *backgroundImage;

- (id)initSelected:(BOOL)isSelected grouped:(BOOL)isGrouped;
- (void)setupBackground;

@end
