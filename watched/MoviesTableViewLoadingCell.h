//
//  MoviesTableLoadingCell.h
//  watched
//
//  Created by Martin Juhasz on 11.02.13.
//
//

#import <UIKit/UIKit.h>

@interface MoviesTableViewLoadingCell : UITableViewCell

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UILabel *titleLabel;

@end
