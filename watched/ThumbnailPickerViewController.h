//
//  ThumbnailPickerViewController.h
//  watched
//
//  Created by Martin Juhasz on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "OnlineMovieDatabase.h"

@interface ThumbnailPickerViewController : UIViewController<GMGridViewDataSource, GMGridViewActionDelegate>

@property (strong, nonatomic) GMGridView *gridView;
@property (strong, nonatomic) NSArray *imageURLs;
@property (assign, nonatomic) ImageType imageType;

@end
