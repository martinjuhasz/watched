//
//  MJUStarRatingHeaderView.h
//  watched
//
//  Created by Martin Juhasz on 20/03/14.
//
//

#import <UIKit/UIKit.h>

@interface MJUStarRatingHeaderView : UIView

@property (assign, nonatomic) NSUInteger rating;
@property (strong, nonatomic) UIView *starView;
@property (strong, nonatomic) UILabel *unratedLabel;

+ (MJUStarRatingHeaderView*)headerViewWithRating:(NSUInteger)rating;
+ (CGFloat)headerHeight;

@end
