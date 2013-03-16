//
//  MoviesTableViewOnlineCell.h
//  watched
//
//  Created by Martin Juhasz on 12.02.13.
//
//

#import <UIKit/UIKit.h>

@interface MoviesTableViewOnlineCell : UITableViewCell

@property (strong, nonatomic) UIImageView *coverImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;


- (void)setYear:(NSDate*)aDate;

@end
