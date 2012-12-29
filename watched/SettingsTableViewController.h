//
//  SettingsTableViewController.h
//  watched
//
//  Created by Martin Juhasz on 04.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoadingPopupViewController;

@interface SettingsTableViewController : UITableViewController<UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *settings;
@property (nonatomic, strong) NSNumber *movieCount;
@property (nonatomic, strong) NSNumber *movieVotedCount;
@property (nonatomic, strong) NSNumber *averageRating;
@property (nonatomic, strong) UILabel *movieCountLabel;
@property (nonatomic, strong) UILabel *averageRatingLabel;
@property (nonatomic, strong) LoadingPopupViewController *loadingController;

- (IBAction)doneButtonClicked:(id)sender;
- (IBAction)optOutSwitchToggled:(id)sender;
@end
