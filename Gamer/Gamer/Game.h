//
//  Game.h
//  Gamer
//
//  Created by Caio Mello on 6/15/13.
//  Copyright (c) 2013 Caio Mello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Developer, Franchise, Genre, Image, Platform, Publisher, ReleasePeriod, SimilarGame, Theme, Video;

@interface Game : NSManagedObject

@property (nonatomic, retain) NSData * coverImage;
@property (nonatomic, retain) NSData * coverImageSmall;
@property (nonatomic, retain) NSString * coverImageURL;
@property (nonatomic, retain) NSNumber * hidden;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * metascore;
@property (nonatomic, retain) NSString * overview;
@property (nonatomic, retain) NSNumber * owned;
@property (nonatomic, retain) NSNumber * released;
@property (nonatomic, retain) NSDate * releaseDate;
@property (nonatomic, retain) NSString * releaseDateText;
@property (nonatomic, retain) NSNumber * releaseDay;
@property (nonatomic, retain) NSNumber * releaseMonth;
@property (nonatomic, retain) NSNumber * releaseQuarter;
@property (nonatomic, retain) NSNumber * releaseYear;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * wanted;
@property (nonatomic, retain) NSSet *developers;
@property (nonatomic, retain) NSSet *franchises;
@property (nonatomic, retain) NSSet *genres;
@property (nonatomic, retain) NSSet *images;
@property (nonatomic, retain) NSSet *platforms;
@property (nonatomic, retain) NSSet *publishers;
@property (nonatomic, retain) ReleasePeriod *releasePeriod;
@property (nonatomic, retain) Platform *selectedPlatform;
@property (nonatomic, retain) NSSet *similarGames;
@property (nonatomic, retain) NSSet *themes;
@property (nonatomic, retain) NSSet *videos;
@end

@interface Game (CoreDataGeneratedAccessors)

- (void)addDevelopersObject:(Developer *)value;
- (void)removeDevelopersObject:(Developer *)value;
- (void)addDevelopers:(NSSet *)values;
- (void)removeDevelopers:(NSSet *)values;

- (void)addFranchisesObject:(Franchise *)value;
- (void)removeFranchisesObject:(Franchise *)value;
- (void)addFranchises:(NSSet *)values;
- (void)removeFranchises:(NSSet *)values;

- (void)addGenresObject:(Genre *)value;
- (void)removeGenresObject:(Genre *)value;
- (void)addGenres:(NSSet *)values;
- (void)removeGenres:(NSSet *)values;

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

- (void)addPlatformsObject:(Platform *)value;
- (void)removePlatformsObject:(Platform *)value;
- (void)addPlatforms:(NSSet *)values;
- (void)removePlatforms:(NSSet *)values;

- (void)addPublishersObject:(Publisher *)value;
- (void)removePublishersObject:(Publisher *)value;
- (void)addPublishers:(NSSet *)values;
- (void)removePublishers:(NSSet *)values;

- (void)addSimilarGamesObject:(SimilarGame *)value;
- (void)removeSimilarGamesObject:(SimilarGame *)value;
- (void)addSimilarGames:(NSSet *)values;
- (void)removeSimilarGames:(NSSet *)values;

- (void)addThemesObject:(Theme *)value;
- (void)removeThemesObject:(Theme *)value;
- (void)addThemes:(NSSet *)values;
- (void)removeThemes:(NSSet *)values;

- (void)addVideosObject:(Video *)value;
- (void)removeVideosObject:(Video *)value;
- (void)addVideos:(NSSet *)values;
- (void)removeVideos:(NSSet *)values;

@end