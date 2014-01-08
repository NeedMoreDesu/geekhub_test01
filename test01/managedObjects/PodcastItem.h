//
//  PodcastItem.h
//  test01
//
//  Created by dev on 1/8/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media, Podcast;

@interface PodcastItem : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * currentMediaIndex;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * imageUrlString;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSOrderedSet *media;
@property (nonatomic, retain) Podcast *podcast;
@property (nonatomic, retain) Podcast *podcastWithMeAsCurrent;
@end

@interface PodcastItem (CoreDataGeneratedAccessors)

- (void)insertObject:(Media *)value inMediaAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMediaAtIndex:(NSUInteger)idx;
- (void)insertMedia:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMediaAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMediaAtIndex:(NSUInteger)idx withObject:(Media *)value;
- (void)replaceMediaAtIndexes:(NSIndexSet *)indexes withMedia:(NSArray *)values;
- (void)addMediaObject:(Media *)value;
- (void)removeMediaObject:(Media *)value;
- (void)addMedia:(NSOrderedSet *)values;
- (void)removeMedia:(NSOrderedSet *)values;
@end
