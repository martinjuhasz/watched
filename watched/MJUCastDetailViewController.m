//
//  MJUCastDetailSegue.m
//  watched
//
//  Created by Martin Juhasz on 06.08.13.
//
//

#import "MJUCastDetailViewController.h"
#import "OnlineMovieDatabase.h"
#import "AFJSONRequestOperation.h"
#import "UILabel+Additions.h"
@interface MJUCastDetailViewController ()

@end

@implementation MJUCastDetailViewController

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
	// Do any additional setup after loading the view.
    AFJSONRequestOperation *operation = [[OnlineMovieDatabase sharedMovieDatabase] getCastDetailsWithPersonID:self.personID completion:^(NSDictionary *personDetails) {
        NSLog(@"%@", personDetails);
        
        self.biographyLabel.text = [personDetails objectForKey:@"biography"];
        [self.biographyLabel sizeToFitWithWith:280.0f andMaximumNumberOfLines:20];
        
    } failure:^(NSError *error) {
        self.biographyLabel.text = [error localizedDescription];
        [self.biographyLabel sizeToFitWithWith:280.0f andMaximumNumberOfLines:20];
    }];
    [operation start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
