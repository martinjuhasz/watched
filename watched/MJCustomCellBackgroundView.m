//
//  MJCustomCellBackgroundView.m
//  asdasd
//
//  Created by Martin Juhasz on 28.07.12.
//  Copyright (c) 2012 Martin Juhasz. All rights reserved.
//

#import "MJCustomCellBackgroundView.h"

@implementation MJCustomCellBackgroundView

- (id)initSelected:(BOOL)isSelected grouped:(BOOL)isGrouped
{
	self = [super init];
	if (self != nil) {
		selected = isSelected;
		grouped = isGrouped;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 43.0f)];
        [self addSubview:self.backgroundImage];
	}
	return self;
}

- (void)setPosition:(MJCellPosition)aPosition
{
    _position = aPosition;
    [self setupBackground];
}

- (void)setupBackground
{
    UIImage *defaultImage;
    UIImage *selectedImage;
    if(self.position == MJCellPositionTop) {
        defaultImage = [UIImage imageNamed:@"g_bg-grp_table_top.png"];
        selectedImage = [UIImage imageNamed:@"g_bg-grp_table_top_highlighted.png"];
    } else if(self.position == MJCellPositionBottom) {
        defaultImage = [UIImage imageNamed:@"g_bg-grp_table_bottom.png"];
        selectedImage = [UIImage imageNamed:@"g_bg-grp_table_bottom_highlighted.png"];
    } else if(self.position == MJCellPositionTopAndBottom) {
        defaultImage = [UIImage imageNamed:@"g_bg-grp_table_topbottom.png"];
        selectedImage = [UIImage imageNamed:@"g_bg-grp_table_topbottom_highlighted.png"];
    } else {
        defaultImage = [UIImage imageNamed:@"g_bg-grp_table_middle.png"];
        selectedImage = [UIImage imageNamed:@"g_bg-grp_table_middle_highlighted.png"];
    }
    
    if(selected) {
        self.backgroundImage.image = selectedImage;
    } else {
        self.backgroundImage.image = defaultImage;
    }
    
    if(self.position == MJCellPositionTop) {
        self.backgroundImage.frame = CGRectMake(0.0f, 0.0f, 300.0f, 44.0f);
    } else {
        self.backgroundImage.frame = CGRectMake(0.0f, 0.0f, 300.0f, 43.0f);
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
