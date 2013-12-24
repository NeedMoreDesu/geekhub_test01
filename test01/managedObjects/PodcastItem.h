//
//  PodcastItem.h
//  test01
//
//  Created by dev on 12/24/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Media, Podcast;

@interface PodcastItem : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * imageUrlString;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * currentMedia;
@property (nonatomic, retain) NSSet *media;
@property (nonatomic, retain) Podcast *podcast;
@property (nonatomic, retain) Podcast *podcastWithMeAsCurrent;
@end

@interface PodcastItem (CoreDataGeneratedAccessors)

- (void)addMediaObject:(Media *)value;
- (void)removeMediaObject:(Media *)value;
- (void)addMedia:(NSSet *)values;
- (void)removeMedia:(NSSet *)values;

@end
