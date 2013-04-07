//
//  UITableView+CellPosition.h
//  watched
//
//  Created by Martin Juhasz on 01.04.13.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
	MJCellPositionUnknown = 0,
	MJCellPositionTop,
	MJCellPositionBottom,
	MJCellPositionMiddle,
	MJCellPositionTopAndBottom
} MJCellPosition;

@interface UITableView (CellPosition)

- (MJCellPosition)positionForIndexPath:(NSIndexPath *)anIndexPath;

@end
