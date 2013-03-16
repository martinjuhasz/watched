//
//  MoviesTableViewCell.h
//  watched
//
//  Created by Martin Juhasz on 10.02.13.
//
//

#import <UIKit/UIKit.h>

@interface MoviesTableViewCell : UITableViewCell

@property(strong, nonatomic) UILabel *titleLabel;
@property(strong, nonatomic) UILabel *yearLabel;
@property(strong, nonatomic) UIImageView *coverImageView;

- (void)setDetailText:(NSString*)aText;
- (void)setYear:(NSDate*)aDate;
- (void)setCoverImage:(UIImage*)aImage;

@end
