//
//  MovieCastTableViewCell.m
//  watched
//
//  Created by Martin Juhasz on 30.08.12.
//
//

#import "MovieCastTableViewCell.h"
#import "MovieCastCellBackgroundView.h"

@implementation MovieCastTableViewCell

- (void)configureForTableView:(UITableView *)aTableView indexPath:(NSIndexPath *)anIndexPath
{
    [super configureForTableView:aTableView indexPath:anIndexPath];
    MJCellPosition position = [self positionForIndexPath:anIndexPath inTableView:aTableView];
    
    BOOL grouped = aTableView.style == UITableViewStyleGrouped;
    
    MovieCastCellBackgroundView *cellBackgroundView = [[MovieCastCellBackgroundView alloc] initSelected:NO grouped:grouped];
    MovieCastCellBackgroundView *selectedCellBackgroundView = [[MovieCastCellBackgroundView alloc] initSelected:YES grouped:grouped];
    
    self.backgroundView = cellBackgroundView;
    self.selectedBackgroundView = selectedCellBackgroundView;
    
	if (aTableView.style == UITableViewStyleGrouped) {
        [(MJCustomCellBackgroundView*)self.backgroundView setPosition:position];
        [(MJCustomCellBackgroundView*)self.selectedBackgroundView setPosition:position];
	}
}

@end
