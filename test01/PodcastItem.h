//
//  Podcast.h
//  test01
//
//  Created by dev on 11/1/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "GDataXMLNode.h"
#import <Foundation/Foundation.h>
#import <FMDatabase.h>

@interface PodcastItem : NSObject
{
}

@property NSString *title;
@property NSURL *imageURL;
@property NSString *author;
@property NSArray *media;
@property NSDate *date;
@property double secondsForCurrentMedia;
@property int currentMedia;

+ (NSArray*)podcastItemsWithXML:(GDataXMLDocument *)doc error:(NSError*)error;

- (int) nextMedia;

+ (NSArray*) podcastItemsFromDB:(FMDatabase*)db
                  WithPodcastID:(long long)podcastId;
- (long long) saveToDB:(FMDatabase*)db
         WithPodcastID:(long long)podcastId;
+ (NSArray*) podcastItemsFromDBWithPodcastID:(long long)podcastId;
- (long long) saveToDBWithPodcastID:(long long)podcastId;

@end
