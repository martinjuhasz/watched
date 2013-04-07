//
//  UITableView+CellPosition.m
//  watched
//
//  Created by Martin Juhasz on 01.04.13.
//
//

#import "UITableView+CellPosition.h"

@implementation UITableView (CellPosition)

- (MJCellPosition)positionForIndexPath:(NSIndexPath *)anIndexPath
{
	MJCellPosition result;
    
    result = ([anIndexPath row] != 0) ? MJCellPositionMiddle : MJCellPositionTop;
    
    id<UITableViewDataSource> dataSource = self.dataSource;
    int numRows = ([dataSource tableView:self numberOfRowsInSection:anIndexPath.section]) - 1;
    
    if(anIndexPath.row == numRows) {
        if(result == MJCellPositionTop) return MJCellPositionTopAndBottom;
        return MJCellPositionBottom;
    }
    return result;
}

@end
