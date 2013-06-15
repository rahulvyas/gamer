//
//  LibraryViewController.m
//  Gamer
//
//  Created by Caio Mello on 6/15/13.
//  Copyright (c) 2013 Caio Mello. All rights reserved.
//

#import "LibraryTableViewController.h"
#import "LibraryCell.h"
#import "Game.h"
#import "Platform.h"
#import "GameTableViewController.h"
#import "SearchTableViewController.h"

@interface LibraryTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *gamesFetch;
@property (nonatomic, strong) NSPredicate *predicate;

@end

@implementation LibraryTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
	NSArray *favoritePlatforms = [Platform findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"favorite = %@", @(YES)]];
	
	UISegmentedControl *segmentedControl = (UISegmentedControl *)self.tableView.tableHeaderView;
	[segmentedControl removeAllSegments];
	
	if (favoritePlatforms.count > 0){
		[segmentedControl insertSegmentWithTitle:@"All" atIndex:0 animated:NO];
		for (Platform *platform in favoritePlatforms)
			[segmentedControl insertSegmentWithTitle:platform.abbreviation atIndex:([favoritePlatforms indexOfObject:platform] + 1) animated:NO];
	}
	else
		[segmentedControl insertSegmentWithTitle:@"Select your platforms in Settings" atIndex:0 animated:NO];
	
	[segmentedControl setSelectedSegmentIndex:0];
	
	_gamesFetch = [self libraryFetchedResultsControllerWithPredicate:_predicate];
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_gamesFetch.sections[section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LibraryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	
	Game *game = [_gamesFetch objectAtIndexPath:indexPath];
	[cell.titleLabel setText:game.title];
	[cell.coverImageView setImage:[UIImage imageWithData:game.coverImageSmall]];
	[cell.platformLabel setText:game.selectedPlatform.abbreviation];
	[cell.platformLabel setBackgroundColor:game.selectedPlatform.color];
	[cell.metascoreLabel setText:game.metascore];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[self performSegueWithIdentifier:@"GameSegue" sender:nil];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	NSManagedObjectContext *context = [NSManagedObjectContext contextForCurrentThread];
	Game *game = [_gamesFetch objectAtIndexPath:indexPath];
	//	[Game deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", game.identifier] inContext:context];
	[game setOwned:@(NO)];
	[context saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
		_gamesFetch = [self libraryFetchedResultsControllerWithPredicate:_predicate];
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}];
}

#pragma mark - Custom

- (NSFetchedResultsController *)libraryFetchedResultsControllerWithPredicate:(NSPredicate *)predicate{
	return [Game fetchAllGroupedBy:nil withPredicate:(predicate) ? predicate : [NSPredicate predicateWithFormat:@"owned = %@", @(YES)] sortedBy:@"title" ascending:YES];
}

#pragma mark - Actions

- (IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender{
	NSPredicate *predicate;
	
	if (sender.selectedSegmentIndex > 0){
		NSArray *platforms = [Platform findAllSortedBy:@"name" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"favorite = %@", @(YES)]];
		Platform *selectedPlatform = platforms[sender.selectedSegmentIndex - 1];
		predicate = [NSPredicate predicateWithFormat:@"owned = %@ AND selectedPlatform = %@", @(YES), selectedPlatform];
	}
	else
		predicate = nil;
	
	_gamesFetch = [self libraryFetchedResultsControllerWithPredicate:predicate];
	[self.tableView reloadData];
}

- (IBAction)addBarButtonPressAction:(UIBarButtonItem *)sender{
	[self performSegueWithIdentifier:@"SearchSegue" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
	if ([segue.identifier isEqualToString:@"GameSegue"]){
		GameTableViewController *destination = [segue destinationViewController];
		[destination setGame:[_gamesFetch objectAtIndexPath:self.tableView.indexPathForSelectedRow]];
	}
//	if ([segue.identifier isEqualToString:@"SearchSegue"]){
//		SearchTableViewController *destination = [segue destinationViewController];
//		[destination setOrigin:2];
//	}
}

@end