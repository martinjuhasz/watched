//
//  NoteViewController.m
//  watched
//
//  Created by Martin Juhasz on 01.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MovieNoteViewController.h"
#import "MoviesDataModel.h"
#import "Movie.h"

@interface MovieNoteViewController ()

@end

@implementation MovieNoteViewController
@synthesize textView;
@synthesize movie;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.movie.note) {
        self.textView.text = self.movie.note;
    }
    [self.textView becomeFirstResponder];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self saveNote];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)saveNote
{
    NSString *newText = self.textView.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        NSManagedObjectContext *context = [[MoviesDataModel sharedDataModel] mainContext];
        
        self.movie.note = newText;
        NSError *error;
        [context save:&error];
        if(error) {
            XLog("%@", [error localizedDescription]);
        }
        
    });
}

@end
