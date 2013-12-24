//
//  Podcast.h
//  test01
//
//  Created by dev on 12/24/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PodcastItem;

@interface Podcast : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * urlString;
@property (nonatomic, retain) PodcastItem *currentItem;
@property (nonatomic, retain) NSSet *items;
@end

@interface Podcast (CoreDataGeneratedAccessors)

- (void)addItemsObject:(PodcastItem *)value;
- (void)removeItemsObject:(PodcastItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
