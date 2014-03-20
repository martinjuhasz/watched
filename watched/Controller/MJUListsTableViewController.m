//
//  MJUCollectionsTableViewController.m
//  watched
//
//  Created by Martin Juhasz on 14.08.13.
//
//

#import "MJUListsTableViewController.h"
#import "CollectionTableViewController.h"
#import "UITableView+Additions.h"

@interface MJUListsTableViewController ()

@end

@implementation MJUListsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // make sure the tableview is empty
    [self.tableView hideEmptyCells];
    
}


////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CollectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"COLLECTIONS_TITE_UNWATCHED", nil);
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"COLLECTIONS_TITE_UNRATED", nil);
            break;
    }
    
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
        CollectionTableViewController *detailViewController = (CollectionTableViewController*)segue.destinationViewController;
        if(indexPath.row == 0) {
            detailViewController.currentSortType = MovieSortTypeUnwatched;
        } else if(indexPath.row == 1) {
            detailViewController.currentSortType = MovieSortTypeUnrated;
        }
    }
}



@end
