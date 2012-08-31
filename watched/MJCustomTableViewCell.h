//
//  MJCustomTableViewCell.h
//  asdasd
//
//  Created by Martin Juhasz on 28.07.12.
//  Copyright (c) 2012 Martin Juhasz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJCustomCellBackgroundView.h"

@interface MJCustomTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL activated;

- (void)configureForTableView:(UITableView *)aTableView indexPath:(NSIndexPath *)anIndexPath;
- (MJCellPosition)positionForIndexPath:(NSIndexPath *)anIndexPath inTableView:(UITableView *)aTableView;

@end
