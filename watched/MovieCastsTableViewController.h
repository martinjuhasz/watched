//
//  MovieCastsTableViewController.h
//  watched
//
//  Created by Martin Juhasz on 31.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Movie;

@interface MovieCastsTableViewController : UITableViewController

@property (nonatomic, strong) Movie *movie;
@property (nonatomic, assign) BOOL internetAvailable;

@end
