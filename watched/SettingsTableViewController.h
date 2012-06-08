//
//  SettingsTableViewController.h
//  watched
//
//  Created by Martin Juhasz on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController<UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *settings;
@property (nonatomic, strong) NSNumber *movieCount;
@property (nonatomic, strong) NSNumber *averageRating;

- (IBAction)doneButtonClicked:(id)sender;

@end
