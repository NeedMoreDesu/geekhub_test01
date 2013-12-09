//
//  Podcast.m
//  test01
//
//  Created by dev on 11/1/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "PodcastItem.h"
#import "NSArray+Func.h"
#import "Podcast.h"

@implementation PodcastItem

+ (NSArray*)podcastItemsWithXML:(GDataXMLDocument *)doc error:(NSError*)error
{
    NSArray *items = [doc nodesForXPath:@"//channel/item" error: &error];
    if (error)
        return nil;
    NSArray *podcastItems =
    [items
     map:
     ^id(GDataXMLElement *item)
     {
         NSString *title = [[[item elementsForName:@"title"]
                             objectAtIndex:0]
                            stringValue];
         NSURL *imageURL = [NSURL
                            URLWithString:
                            [[[[item elementsForName:@"itunes:image"]
                               objectAtIndex:0]
                              attributeForName:@"href"]
                             stringValue]];
         NSString *author = [[[item elementsForName:@"itunes:author"]
                              objectAtIndex:0]
                             stringValue];
         NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
         [dateFormat setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
         NSDate *date = [dateFormat
                         dateFromString:[[[item elementsForName:@"pubDate"]
                                          objectAtIndex:0]
                                         stringValue]];
         if (author == nil)
             author = [[[item elementsForName:@"author"]
                        objectAtIndex:0]
                       stringValue];
         NSArray *media = [[item elementsForName:@"enclosure"]
                           map:^id(GDataXMLElement* item) {
                               return [NSURL
                                       URLWithString:
                                       [[item attributeForName:@"url"]
                                        stringValue]];
                           }];
         
         PodcastItem *podcastItem = [[PodcastItem alloc] init];
         
         [podcastItem setTitle:title];
         [podcastItem setImageURL:imageURL];
         [podcastItem setAuthor:author];
         [podcastItem setDate:date];
         [podcastItem setMedia:media];
         [podcastItem setSecondsForCurrentMedia:0.0];
         [podcastItem setCurrentMedia:0];
         
         return podcastItem;
     }];
    return podcastItems;
}

- (int) nextMedia
{
    self.currentMedia++;
    if (self.currentMedia >= self.media.count)
        self.currentMedia = 0;
    return self.currentMedia;
}

+ (NSArray*) mediaFromDB:(FMDatabase*)db
       WithPodcastItemID:(long long)podcastItemId
{
    FMResultSet *s = [db
                      executeQuery:@"SELECT * FROM media WHERE podcast_item_id = :podcast_item_id"
                      withParameterDictionary:@{@"podcast_item_id":[NSNumber numberWithLongLong:podcastItemId]}];
    
    NSMutableArray *media = [[NSMutableArray alloc] init];
    while ([s next])
    {
        NSURL *media_url = [NSURL URLWithString:[s stringForColumn:@"url_string"]];
        [media addObject:media_url];
    }
    return media;
}

- (long long) saveMediaToDB:(FMDatabase*)db
              WithPodcastItemID:(long long)podcastItemId
{
    [self.media enumerateObjectsUsingBlock:^(NSURL *item, NSUInteger idx, BOOL *stop) {
        [db
         executeUpdate:@"INSERT INTO media (podcast_item_id, url_string) VALUES (:podcast_item_id, :url_string)"
         withParameterDictionary:@{@"podcast_item_id":[NSNumber numberWithLongLong:podcastItemId],
                                   @"url_string":[item absoluteString]}];
    }];
    long long last_id = [db lastInsertRowId];
    return last_id;
}

+ (NSArray*) podcastItemsFromDB:(FMDatabase*)db
                  WithPodcastID:(long long)podcastId
{
    FMResultSet *s = [db
                      executeQuery:@"SELECT * FROM podcast_item WHERE podcast_id = :podcast_id"
                      withParameterDictionary:@{@"podcast_id":[NSNumber numberWithLongLong:podcastId]}];
    
    NSMutableArray *podcastItems = [[NSMutableArray alloc] init];
    while ([s next])
    {
        PodcastItem *podcastItem = [[PodcastItem alloc] init];
        
        podcastItem.title = [s stringForColumn:@"title"];
        podcastItem.imageURL = [NSURL URLWithString:[s stringForColumn:@"image_url_string"]];
        podcastItem.author = [s stringForColumn:@"author"];
        podcastItem.secondsForCurrentMedia = [s doubleForColumn:@"seconds_for_current_media"];
        podcastItem.currentMedia = [s intForColumn:@"current_media"];
        podcastItem.date = [s dateForColumn:@"date"];
        
        long long podcastItemId = [s longLongIntForColumn:@"id"];
        podcastItem.media = [self
                             mediaFromDB:db
                             WithPodcastItemID:podcastItemId];
        
        [podcastItems addObject:podcastItem];
    }
    return podcastItems;
}

- (long long) saveToDB:(FMDatabase*)db
         WithPodcastID:(long long)podcastId
{
    FMResultSet *s = [db
                      executeQuery:@"SELECT * FROM podcast_item "
                      @"WHERE podcast_id = :podcast_id AND title = :title AND image_url_string = :image_url_string AND author = :author AND date = :date"
                      withParameterDictionary:
                      @{@"podcast_id":[NSNumber numberWithLongLong:podcastId],
                        @"title":self.title,
                        @"image_url_string":[self.imageURL absoluteString],
                        @"author":self.author,
                        @"date":self.date}];
    long long last_id;
    if ([s next])
    {
        [db
         executeUpdate:
         @"UPDATE podcast_item "
         @"SET podcast_id = :podcast_id, title = :title, image_url_string = :image_url_string, author = :author, seconds_for_current_media = :seconds_for_current_media, current_media = :current_media, date = :date "
         @"WHERE podcast_id = :podcast_id AND title = :title AND image_url_string = :image_url_string AND author = :author AND date = :date"
         withParameterDictionary:
         @{@"podcast_id":[NSNumber numberWithLongLong:podcastId],
           @"title":self.title,
           @"image_url_string":[self.imageURL absoluteString],
           @"author":self.author,
           @"seconds_for_current_media":[NSNumber numberWithDouble:self.secondsForCurrentMedia],
           @"current_media":[NSNumber numberWithInt:self.currentMedia],
           @"date":self.date}];
        last_id = [db lastInsertRowId];
    }
    else
    {
        [db
         executeUpdate:@"INSERT INTO podcast_item (podcast_id, title, image_url_string, author, seconds_for_current_media, current_media, date) VALUES (:podcast_id, :title, :image_url_string, :author, :seconds_for_current_media, :current_media, :date)"
         withParameterDictionary:@{@"podcast_id":[NSNumber numberWithLongLong:podcastId],
                                   @"title":self.title,
                                   @"image_url_string":[self.imageURL absoluteString],
                                   @"author":self.author,
                                   @"seconds_for_current_media":[NSNumber numberWithDouble:self.secondsForCurrentMedia],
                                   @"current_media":[NSNumber numberWithInt:self.currentMedia],
                                   @"date":self.date}];
        last_id = [db lastInsertRowId];
        [self
         saveMediaToDB:db
         WithPodcastItemID:last_id];
    }
    return last_id;
}

+ (NSArray*) podcastItemsFromDBWithPodcastID:(long long)podcastId
{
    FMDatabase *db = [Podcast getDatabeseCreate];
    if(![db open])
        return nil;
    id result = [self podcastItemsFromDB:db WithPodcastID:podcastId];
    [db close];
    return result;
}
     

- (long long) saveToDBWithPodcastID:(long long)podcastId
{
    FMDatabase *db = [Podcast getDatabeseCreate];
    if(![db open])
        return -1;
    long long result = [self saveToDB:db WithPodcastID:podcastId];
    [db close];
    return result;
}


@end
