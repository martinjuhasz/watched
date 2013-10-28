//
//  MovieDetailViewController.h
//  watched
//
//  Created by Martin Juhasz on 28.05.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLStarRatingControl.h"
#import <MessageUI/MessageUI.h>

@class Movie;
@class MovieDetailView;

@interface MovieDetailViewController : UIViewController<DLStarRatingDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) Movie *movie;
@property (nonatomic, strong) NSManagedObjectContext *currentContext;
@property (nonatomic, strong) MovieDetailView *detailView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *shareButton;

@end
