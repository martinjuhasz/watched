//
//  NoteViewController.h
//  watched
//
//  Created by Martin Juhasz on 01.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Movie;

@interface MovieNoteViewController : UIViewController

@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) Movie *movie;

@end
