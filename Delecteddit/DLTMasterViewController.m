//
//  DLTMasterViewController.m
//  Delecteddit
//
//  Created by Antonin Lacombe on 18/02/2014.
//  Copyright (c) 2014 Antonin Lacombe. All rights reserved.
//

#import "DLTMasterViewController.h"
#import "DLTDetailViewController.h"
#import "DLTRestManager.h"
#import "DLTPost.h"

@interface DLTMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) DLTRestManager *restManager;

@end

@implementation DLTMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect footerRect = CGRectMake(0, 0, 320, 40);
    UIButton *tableFooter = [[UIButton alloc] initWithFrame:footerRect];
    [tableFooter setTitle:@"Show more" forState:UIControlStateNormal];
    tableFooter.titleLabel.textColor = [UIColor blackColor];
    self.tableView.tableFooterView = tableFooter;
	// Do any additional setup after loading the view, typically from a nib.
    [self loadData];

}

#pragma mark - Lazy Loaders

- (DLTRestManager *)restManager {
    if (_restManager == nil) {
        _restManager = [[DLTRestManager alloc]init];
    }
    return _restManager;
}


- (void)loadData {
    
    // Load the object model via RestKit
    RKObjectManager *objectManager = [self.restManager objectManager];
    [objectManager getObjectsAtPath:@".json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        //the fetchedResultsController send notification when objects are loaded, we don't need to call the reload data
        [self.refreshControl endRefreshing];

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
        [self.refreshControl endRefreshing];
    }];
}
- (IBAction)refresh:(id)sender {
    [self loadData];
}

- (DLTPost *)postForIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}


#pragma mark - Table View

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo name];
    } else
        return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController{
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
        fetchRequest.sortDescriptors = @[
                                         [NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO],
                                         ];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
        self.fetchedResultsController.delegate = self;
        NSError *error;
        [self.fetchedResultsController performFetch:&error];
        //        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
        NSAssert(!error, @"Error performing fetch request: %@", error);
    }
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
*/
// - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    // In the simplest, most efficient, case, reload the table view.
//    [self.tableView reloadData];
//}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DLTPost *post = [self postForIndexPath:indexPath];
    cell.textLabel.text = post.title;
}

@end
