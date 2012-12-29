//
//  MJCustomTableViewCell.m
//  asdasd
//
//  Created by Martin Juhasz on 28.07.12.
//  Copyright (c) 2012 Martin Juhasz. All rights reserved.
//

#import "MJCustomTableViewCell.h"

@implementation MJCustomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.activated = YES;
    }
    return self;
}

- (void)addStyles {
    self.backgroundColor = [UIColor clearColor];
    
    self.textLabel.textColor = HEXColor(0x333333);
    self.textLabel.highlightedTextColor = HEXColor(0x333333);
    self.textLabel.shadowColor = [UIColor colorWithRed:255.0f green:255.0f blue:255.0f alpha:0.4f];
    self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
    
    self.indentationLevel = 1;
    self.indentationWidth = 5.0f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(10,10,24,23);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureForTableView:(UITableView *)aTableView indexPath:(NSIndexPath *)anIndexPath
{
    [self addStyles];
    MJCellPosition position = [self positionForIndexPath:anIndexPath inTableView:aTableView];
    
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.backgroundColor = [UIColor clearColor];
    
	if (!self.backgroundView) {
        BOOL grouped = aTableView.style == UITableViewStyleGrouped;
        
		MJCustomCellBackgroundView *cellBackgroundView = [[MJCustomCellBackgroundView alloc] initSelected:NO grouped:grouped];
        MJCustomCellBackgroundView *selectedCellBackgroundView = [[MJCustomCellBackgroundView alloc] initSelected:YES grouped:grouped];
		
        self.backgroundView = cellBackgroundView;
		self.selectedBackgroundView = selectedCellBackgroundView;
	}

	if (aTableView.style == UITableViewStyleGrouped) {
        [(MJCustomCellBackgroundView*)self.backgroundView setPosition:position];
        [(MJCustomCellBackgroundView*)self.selectedBackgroundView setPosition:position];
	}
    
    if(!self.activated) {
        self.textLabel.textColor = HEXColor(0x969696);
        self.textLabel.highlightedTextColor = HEXColor(0x969696);
    }
}

- (MJCellPosition)positionForIndexPath:(NSIndexPath *)anIndexPath inTableView:(UITableView *)aTableView
{
	MJCellPosition result;
    
    result = ([anIndexPath row] != 0) ? MJCellPositionMiddle : MJCellPositionTop;
    
    id<UITableViewDataSource> dataSource = aTableView.dataSource;
    int numRows = ([dataSource tableView:aTableView numberOfRowsInSection:anIndexPath.section]) - 1;
    
    if(anIndexPath.row == numRows) {
        if(result == MJCellPositionTop) return MJCellPositionTopAndBottom;
        return MJCellPositionBottom;
    }
    
    return result;
}

@end
