//
//  DLTMasterViewController.m
//  Delecteddit
//
//  Created by Antonin Lacombe on 18/02/2014.
//  Copyright (c) 2014 Antonin Lacombe. All rights reserved.
//

#import "DLTMasterViewController.h"
#import "DLTDetailViewController.h"
#import "DLTPostTableViewCell.h"
#import "MBProgressHUD.h"
#import "DLTRestManager.h"
#import "DLTPost.h"
#import "DLTPage.h"

@interface DLTMasterViewController ()
- (void)configureCell:(UITableViewCell *)originalCell atIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) UIButton *footButton;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) DLTRestManager *restManager;

@property (nonatomic, strong) NSString *nextPage;


@end

@implementation DLTMasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = self.footButton;
	// Do any additional setup after loading the view, typically from a nib.
    self.nextPage = nil;
    [self loadData];

}

#pragma mark - Lazy Loaders
- (NSFetchedResultsController *)fetchedResultsController{
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
        fetchRequest.sortDescriptors = @[
                                         [NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO],
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


- (DLTRestManager *)restManager {
    if (!_restManager) {
        _restManager = [[DLTRestManager alloc]init];
    }
    return _restManager;
}

-(UIButton *)footButton {
    if (!_footButton) {
        CGRect footerRect = CGRectMake(0, 0, 320, 40);
        _footButton = [[UIButton alloc] initWithFrame:footerRect];
        [_footButton setTitle:@"Show more" forState:UIControlStateNormal];
        _footButton.backgroundColor = [UIColor redColor];
        _footButton.titleLabel.textColor = [UIColor blackColor];
        [_footButton addTarget:self action:@selector(loadMorePosts:) forControlEvents:UIControlEventTouchDown];
    }
    return _footButton;
}

- (void)loadData{
    // Load the object model via RestKit
    NSString *jsonPath = @".json";
    if (self.nextPage) {
        NSString *arguments = [NSString stringWithFormat:@"?after=%@", self.nextPage];
        jsonPath = [jsonPath stringByAppendingString:arguments];
    }
    RKObjectManager *objectManager = [self.restManager objectManager];
    [objectManager getObjectsAtPath:jsonPath parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        //the fetchedResultsController send notification when objects are loaded, we don't need to call the reload data
        if ([mappingResult count]>0){
            self.nextPage = [[[mappingResult dictionary] objectForKey:@"data"] valueForKey:@"after"];
        }
        [self.refreshControl endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Load failed with error: %@", error);
        [self.refreshControl endRefreshing];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
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
    DLTPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    DLTPost *post = [self postForIndexPath:[self.tableView indexPathForSelectedRow]];
    if (post.selftext && [post.selftext length] > 0) {
        return YES;
//        [self performSegueWithIdentifier:@"showDetail" sender:
    } else if (post.url && [post.url length] > 0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:post.url]];
        return NO;
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DLTPost *post = [self postForIndexPath:indexPath];
        [[segue destinationViewController] setPost:post];
    }
}

#pragma mark - Fetched results controller

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

- (void)configureCell:(UITableViewCell *)originalCell atIndexPath:(NSIndexPath *)indexPath
{
    DLTPostTableViewCell *cell = (DLTPostTableViewCell *)originalCell;
    DLTPost *post = [self postForIndexPath:indexPath];
    cell.titleLabel.text = post.title;
    cell.scoreLabel.text = [post.score stringValue];
    [cell.thumbnailImageView setImageWithURL:[NSURL URLWithString:post.thumbnailURL] placeholderImage:[UIImage imageNamed:@"Placeholder"]];
    cell.commentNumberLabel.text = [NSString stringWithFormat:@"%@ comments", [post.commentsNumber stringValue]];
    
    if ([post.selftext length] > 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}


-(void)loadMorePosts:(id)sender
{
    if (self.nextPage) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self loadData];
    } else {
        [self.footButton setTitle:@"No more post to load" forState:UIControlStateNormal];
    }
}

@end
