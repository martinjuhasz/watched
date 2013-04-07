//
//  ThumbnailPickerViewController.h
//  watched
//
//  Created by Martin Juhasz on 04.06.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "OnlineMovieDatabase.h"

@protocol ThumbnailPickerDelegate;

@interface ThumbnailPickerViewController : UIViewController<GMGridViewDataSource, GMGridViewActionDelegate>

@property (strong, nonatomic) IBOutlet GMGridView *gridView;
@property (strong, nonatomic) NSArray *imageURLs;
@property (assign, nonatomic) ImageType imageType;
@property (assign, nonatomic) id <ThumbnailPickerDelegate>delegate;

@end

@protocol ThumbnailPickerDelegate<NSObject>
@optional
- (void) thumbnailPicker:(ThumbnailPickerViewController*)aPicker didSelectImage:(NSString*)aImage forImageType:(ImageType)aImageType;
@end