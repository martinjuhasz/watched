//
//  MovieCastCellBackgroundView.m
//  watched
//
//  Created by Martin Juhasz on 30.08.12.
//
//

#import "MovieCastCellBackgroundView.h"

@implementation MovieCastCellBackgroundView

- (void)setupBackground
{
    UIImage *defaultImage;
    UIImage *selectedImage;
    if(self.position == MJCellPositionTop) {
        defaultImage = [UIImage imageNamed:@"cv_bg-grp_table_top.png"];
        selectedImage = [UIImage imageNamed:@"cv_bg-grp_table_top_highlighted.png"];
    } else if(self.position == MJCellPositionBottom) {
        defaultImage = [UIImage imageNamed:@"cv_bg-grp_table_bottom.png"];
        selectedImage = [UIImage imageNamed:@"cv_bg-grp_table_bottom_highlighted.png"];
    } else if(self.position == MJCellPositionTopAndBottom) {
        defaultImage = [UIImage imageNamed:@"cv_bg-grp_table_topbottom.png"];
        selectedImage = [UIImage imageNamed:@"cv_bg-grp_table_topbottom_highlighted.png"];
    } else {
        defaultImage = [UIImage imageNamed:@"cv_bg-grp_table_middle.png"];
        selectedImage = [UIImage imageNamed:@"cv_bg-grp_table_middle_highlighted.png"];
    }
    
    if(selected) {
        self.backgroundImage.image = selectedImage;
    } else {
        self.backgroundImage.image = defaultImage;
    }
    
    if(self.position == MJCellPositionTop) {
        self.backgroundImage.frame = CGRectMake(0.0f, 0.0f, 300.0f, 55.0f);
    } else {
        self.backgroundImage.frame = CGRectMake(0.0f, 0.0f, 300.0f, 54.0f);
    }
}

@end
