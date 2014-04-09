//
//  RegionsController.m
//  Gamer
//
//  Created by Caio Mello on 04/04/2014.
//  Copyright (c) 2014 Caio Mello. All rights reserved.
//

#import "RegionsController.h"
#import "Region.h"
#import "RegionCell.h"

@interface RegionsController ()

@property (nonatomic, strong) NSArray *regions;

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation RegionsController

- (void)viewDidLoad{
	[super viewDidLoad];
	
	_context = [NSManagedObjectContext MR_contextForCurrentThread];
	
	_regions = [Region MR_findAllSortedBy:@"identifier" ascending:YES inContext:_context];
}

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return _regions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	Region *region = _regions[indexPath.row];
	
	RegionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	[cell.flagImageView setImage:[UIImage imageNamed:region.imageName]];
	[cell.titleLabel setText:region.name];
	[cell setAccessoryType:region == [Session gamer].region ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
	[cell setBackgroundColor:[UIColor colorWithRed:.164705882 green:.164705882 blue:.164705882 alpha:1]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[_regions indexOfObject:[Session gamer].region] inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
	
	[[Session gamer] setRegion:_regions[indexPath.row]];
	[_context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
		[[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	}];
}

@end