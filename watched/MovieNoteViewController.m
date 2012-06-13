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
@synthesize navBar;
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
    self.navBar.topItem.title = self.title;
    
    if(self.movie.note) {
        self.textView.text = self.movie.note;
    } else {
        self.textView.text = NSLocalizedString(@"INITIAL_NOTE", nil);
    }
    [self.textView becomeFirstResponder];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setNavBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)saveNote
{
    NSString *newText = self.textView.text;
    if([newText isEqualToString:NSLocalizedString(@"INITIAL_NOTE", nil)]) return;
    
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

- (IBAction)saveButtonClicked:(id)sender {
    [self saveNote];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}



@end
