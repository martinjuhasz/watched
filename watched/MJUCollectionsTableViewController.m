//
//  MJUCollectionsTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 14.08.13.
//
//

#import "MJUCollectionsTableViewController.h"
#import "MoviesTableViewController.h"

@interface MJUCollectionsTableViewController ()

@end

@implementation MJUCollectionsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // make sure the tableview is empty
    UIView *emptyTable = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 1.0f)];
    [emptyTable setBackgroundColor:[UIColor clearColor]];
    self.tableView.tableFooterView = emptyTable;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CollectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"COLLECTIONS_TITE_ALL", nil);
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"COLLECTIONS_TITE_UNWATCHED", nil);
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"COLLECTIONS_TITE_UNRATED", nil);
            break;
            
        default:
            break;
    }
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"CollectionSlectedSegue" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(![sender isKindOfClass:[NSIndexPath class]]) return;
    NSIndexPath *indexPath = (NSIndexPath*)sender;
    
    if([segue.identifier isEqualToString:@"CollectionSlectedSegue"]) {
        MoviesTableViewController *detailViewController = (MoviesTableViewController*)segue.destinationViewController;
        if(indexPath.row == 0) {
            [detailViewController loadMoviesWithSortType:MovieSortTypeAll];
        } else if(indexPath.row == 1) {
            [detailViewController loadMoviesWithSortType:MovieSortTypeUnwatched];
        } else if(indexPath.row == 2) {
            [detailViewController loadMoviesWithSortType:MovieSortTypeUnrated];
        }
    }
}



@end
