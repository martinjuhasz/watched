//
//  NoteViewController.h
//  watched
//
//  Created by Martin Juhasz on 01.06.12.
//  Copyright (c) 2012 watched. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WatchedStyledViewController.h"

@class Movie;

@interface MovieNoteViewController : WatchedStyledViewController

@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) Movie *movie;

@end
