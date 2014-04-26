//
//  ImportController.m
//  Gamer
//
//  Created by Caio Mello on 26/02/2014.
//  Copyright (c) 2014 Caio Mello. All rights reserved.
//

#import "ImportController.h"
#import "ImportCell.h"
#import "Game.h"
#import "Platform.h"
#import "Release.h"
#import "Region.h"

@interface ImportController ()

@property (nonatomic, strong) NSMutableArray *importedWishlistGames;
@property (nonatomic, strong) NSMutableArray *importedLibraryGames;

@property (nonatomic, assign) NSInteger numberOfRunningTasks;

@property (nonatomic, strong) NSCache *imageCache;

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation ImportController

- (void)viewDidLoad{
	[super viewDidLoad];
	
	_context = [NSManagedObjectContext MR_contextForCurrentThread];
	
	_imageCache = [NSCache new];
	
	NSDictionary *importedDictionary = [NSJSONSerialization JSONObjectWithData:_backupData options:0 error:nil];
	NSLog(@"%@", importedDictionary);
	
	if (importedDictionary[@"games"] != [NSNull null]){
		_importedWishlistGames = [[NSMutableArray alloc] initWithCapacity:[importedDictionary[@"games"] count]];
		_importedLibraryGames = [[NSMutableArray alloc] initWithCapacity:[importedDictionary[@"games"] count]];
		
		for (NSDictionary *dictionary in importedDictionary[@"games"]){
			NSNumber *identifier = [Tools integerNumberFromSourceIfNotNull:dictionary[@"id"]];
			Game *game = [Game MR_findFirstByAttribute:@"identifier" withValue:identifier inContext:_context];
			if (!game) game = [Game MR_createInContext:_context];
			[game setIdentifier:identifier];
			[game setTitle:[Tools stringFromSourceIfNotNull:dictionary[@"title"]]];
			[game setFinished:[Tools booleanNumberFromSourceIfNotNull:dictionary[@"finished"] withDefault:NO]];
			[game setDigital:[Tools booleanNumberFromSourceIfNotNull:dictionary[@"digital"] withDefault:NO]];
			[game setLent:[Tools booleanNumberFromSourceIfNotNull:dictionary[@"lent"] withDefault:NO]];
			[game setPreordered:[Tools booleanNumberFromSourceIfNotNull:dictionary[@"preordered"] withDefault:NO]];
			[game setLocation:[Tools integerNumberFromSourceIfNotNull:dictionary[@"location"]]];
			[game setBorrowed:[Tools integerNumberFromSourceIfNotNull:dictionary[@"borrowed"]]];
			[game setPersonalRating:[Tools integerNumberFromSourceIfNotNull:dictionary[@"personalRating"]]];
			[game setNotes:[Tools stringFromSourceIfNotNull:dictionary[@"notes"]]]; if (!game.notes) [game setNotes:@""];
			
			if ([game.location isEqualToNumber:@(GameLocationWishlist)])
				[_importedWishlistGames addObject:game];
			else if ([game.location isEqualToNumber:@(GameLocationLibrary)])
				[_importedLibraryGames addObject:game];
			
			if (dictionary[@"selectedPlatforms"] != [NSNull null]){
				NSMutableArray *selectedPlatforms = [[NSMutableArray alloc] initWithCapacity:[dictionary[@"selectedPlatforms"] count]];
				for (NSDictionary *platformDictionary in dictionary[@"selectedPlatforms"]){
					Platform *platform = [Platform MR_findFirstByAttribute:@"identifier" withValue:platformDictionary[@"id"] inContext:_context];
					[selectedPlatforms addObject:platform];
				}
				
				[game setSelectedPlatforms:[NSSet setWithArray:selectedPlatforms]];
			}
			
			NSNumber *releaseIdentifier = [Tools integerNumberFromSourceIfNotNull:dictionary[@"selectedRelease"]];
			Release *release = [Release MR_findFirstByAttribute:@"identifier" withValue:releaseIdentifier inContext:_context];
			if (!release) release = [Release MR_createInContext:_context];
			[release setIdentifier:releaseIdentifier];
			
			[game setSelectedRelease:release];
			
			// If game not in database, download
			if (!game.releaseDate)
				[self requestGame:game];
		}
		
		_importedWishlistGames = [_importedWishlistGames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			Game *game1 = (Game *)obj1;
			Game *game2 = (Game *)obj2;
			return [game1.title compare:game2.title] == NSOrderedDescending;
		}].mutableCopy;
		
		_importedLibraryGames = [_importedLibraryGames sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			Game *game1 = (Game *)obj1;
			Game *game2 = (Game *)obj2;
			return [game1.title compare:game2.title] == NSOrderedDescending;
		}].mutableCopy;
	}
	
//	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning{
	[super didReceiveMemoryWarning];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	switch (section) {
		case 0: return @"Wishlist";
		case 1: return @"Library";
		default: return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	switch (section) {
		case 0: return _importedWishlistGames.count;
		case 1: return _importedLibraryGames.count;
		default: return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	Game *game = indexPath.section == 0 ? _importedWishlistGames[indexPath.row] : _importedLibraryGames[indexPath.row];
	
	ImportCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	[cell.titleLabel setText:game.title];
	
	UIImage *image = [_imageCache objectForKey:game.imagePath.lastPathComponent];
	
	if (image){
		[cell.coverImageView setImage:image];
		[cell.coverImageView setBackgroundColor:[UIColor clearColor]];
	}
	else{
		[cell.coverImageView setImage:nil];
		[cell.coverImageView setBackgroundColor:[UIColor clearColor]];
		
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			UIImage *image = [UIImage imageWithContentsOfFile:game.imagePath];
			
			CGSize imageSize = [Tools sizeOfImage:image aspectFitToWidth:cell.coverImageView.frame.size.width];
			
			UIGraphicsBeginImageContext(imageSize);
			[image drawInRect:CGRectMake(0, 0, imageSize.width, imageSize.height)];
			image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[cell.coverImageView setImage:image];
				[cell.coverImageView setBackgroundColor:image ? [UIColor clearColor] : [UIColor darkGrayColor]];
			});
			
			if (image){
				[_imageCache setObject:image forKey:game.imagePath.lastPathComponent];
			}
		});
	}
	
	[cell setBackgroundColor:[UIColor colorWithRed:.164705882 green:.164705882 blue:.164705882 alpha:1]];
	[cell setAccessoryType:game.releaseDate ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];
	
	return cell;
}

#pragma mark - Networking

- (void)requestGame:(Game *)game{
	NSURLRequest *request = [Networking requestForGameWithIdentifier:game.identifier fields:@"deck,developers,expected_release_day,expected_release_month,expected_release_quarter,expected_release_year,franchises,genres,id,image,name,original_release_date,platforms,publishers,similar_games,themes,releases"];
	
	NSURLSessionDataTask *dataTask = [[Networking manager] dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
		if (error){
			if (((NSHTTPURLResponse *)response).statusCode != 0) NSLog(@"Failure in %@ - Status code: %ld - Game", self, (long)((NSHTTPURLResponse *)response).statusCode);
			
			_numberOfRunningTasks--;
			
			if (_numberOfRunningTasks == 0){
				[self.navigationItem.rightBarButtonItem setEnabled:YES];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Some games might not have downloaded properly" message:@"You can save the import and just refresh your wishlist or library later to complete the download" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alertView show];
			}
		}
		else{
			NSLog(@"Success in %@ - Status code: %ld - Game - Size: %lld bytes", self, (long)((NSHTTPURLResponse *)response).statusCode, response.expectedContentLength);
			
			_numberOfRunningTasks--;
			
			[Networking updateGameInfoWithGame:game JSON:responseObject context:_context];
			
			NSString *coverImageURL = (responseObject[@"results"][@"image"] != [NSNull null]) ? [Tools stringFromSourceIfNotNull:responseObject[@"results"][@"image"][@"super_url"]] : nil;
			
			UIImage *coverImage = [UIImage imageWithContentsOfFile:game.imagePath];
			
			if (!coverImage || !game.imagePath || ![game.imageURL isEqualToString:coverImageURL]){
				[self downloadCoverImageWithURL:coverImageURL game:game];
			}
			
			[self requestReleasesForGame:game];
			
			if (_numberOfRunningTasks == 0){
				[self.navigationItem.rightBarButtonItem setEnabled:YES];
			}
		}
	}];
	[dataTask resume];
	_numberOfRunningTasks++;
}

- (void)downloadCoverImageWithURL:(NSString *)URLString game:(Game *)game{
	if (!URLString) return;
	
	NSURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
	
	NSURLSessionDownloadTask *downloadTask = [[Networking manager] downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
		NSURL *fileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [Tools imagesDirectory], request.URL.lastPathComponent]];
		return fileURL;
	} completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
		if (error){
			if (((NSHTTPURLResponse *)response).statusCode != 0) NSLog(@"Failure in %@ - Status code: %ld - Cover Image", self, (long)((NSHTTPURLResponse *)response).statusCode);
			
			_numberOfRunningTasks--;
			
			if (_numberOfRunningTasks == 0){
				[self.navigationItem.rightBarButtonItem setEnabled:YES];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Some games might not have downloaded properly" message:@"You can save the import and just refresh your wishlist or library later to complete the download" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alertView show];
			}
		}
		else{
			NSLog(@"Success in %@ - Status code: %ld - Cover Image - Size: %lld bytes", self, (long)((NSHTTPURLResponse *)response).statusCode, response.expectedContentLength);
			
			_numberOfRunningTasks--;
			
			[game setImagePath:[NSString stringWithFormat:@"%@/%@", [Tools imagesDirectory], request.URL.lastPathComponent]];
			
			[self.tableView reloadData];
			
			if (_numberOfRunningTasks == 0){
				[self.navigationItem.rightBarButtonItem setEnabled:YES];
			}
		}
	}];
	[downloadTask resume];
	_numberOfRunningTasks++;
}

- (void)requestReleasesForGame:(Game *)game{
	NSURLRequest *request = [Networking requestForReleasesWithGameIdentifier:game.identifier fields:@"id,name,platform,region,release_date,expected_release_day,expected_release_month,expected_release_quarter,expected_release_year,image"];
	
	NSURLSessionDataTask *dataTask = [[Networking manager] dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
		if (error){
			if (((NSHTTPURLResponse *)response).statusCode != 0) NSLog(@"Failure in %@ - Status code: %ld - Releases", self, (long)((NSHTTPURLResponse *)response).statusCode);
			
			_numberOfRunningTasks--;
			
			if (_numberOfRunningTasks == 0){
				[self.navigationItem.rightBarButtonItem setEnabled:YES];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Some games might not have downloaded properly" message:@"You can save the import and just refresh your wishlist or library later to complete the download" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alertView show];
			}
		}
		else{
			NSLog(@"Success in %@ - Status code: %ld - Releases - Size: %lld bytes", self, (long)((NSHTTPURLResponse *)response).statusCode, response.expectedContentLength);
//			NSLog(@"%@", responseObject);
			
			_numberOfRunningTasks--;
			
			[game setReleases:nil];
			
			[Networking updateGameReleasesWithGame:game JSON:responseObject context:_context];
			
			if (_numberOfRunningTasks == 0){
				[self.navigationItem.rightBarButtonItem setEnabled:YES];
			}
		}
	}];
	[dataTask resume];
	_numberOfRunningTasks++;
}

#pragma mark - Actions

- (IBAction)cancelBarButtonAction:(UIBarButtonItem *)sender{
	[_context rollback];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveBarButtonAction:(UIBarButtonItem *)sender{
	[_context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshWishlist" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshLibrary" object:nil];
		[self dismissViewControllerAnimated:YES completion:nil];
	}];
}

@end
