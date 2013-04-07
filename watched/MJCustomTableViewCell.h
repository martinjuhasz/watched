//
//  MJCustomTableViewCell.h
//  asdasd
//
//  Created by Martin Juhasz on 28.07.12.
//  Copyright (c) 2012 Martin Juhasz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJCustomCellBackgroundView.h"
#import "UITableView+CellPosition.h"

@interface MJCustomTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL activated;
@property (nonatomic, assign) MJCellPosition position;

- (void)configureForTableView:(UITableView *)aTableView indexPath:(NSIndexPath *)anIndexPath;

@end
