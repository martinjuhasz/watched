//
//  MoviesTableViewController.h
//  watched
//
//  Created by Martin Juhasz on 09.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

typedef enum {
    MovieSortTypeAll = 1,
    MovieSortTypeUnwatched,
    MovieSortTypeUnrated
} MovieSortType;

@interface MoviesTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) MovieSortType currentSortType;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UIView *addButtonBackgroundView;

@end
