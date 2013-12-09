//
//  Podcast.m
//  test01
//
//  Created by dev on 11/23/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Podcast.h"
#import "NSArray+Func.h"

@implementation Podcast

+ (Podcast*)podcastWithXML:(GDataXMLDocument *)doc
                       url:(NSURL*)url
                     error:(NSError*)error
{
    GDataXMLElement *channel = [[doc nodesForXPath:@"//channel" error: &error]
                                objectAtIndex:0];
    if (error)
        return nil;
    
    NSString *title = [[[channel elementsForName:@"title"]
                        objectAtIndex:0]
                       stringValue];
    NSArray *items = [PodcastItem
                      podcastItemsWithXML:doc
                      error:error];
    NSString *urlString = [url absoluteString];
    
    if (error)
        return nil;
    Podcast *podcast = [[Podcast alloc] init];
    [podcast setTitle:title];
    [podcast setItems:items];
    [podcast setUrlString:urlString];
    
    return podcast;
}

+ (void)downloadPodcastWithURL:(NSURL*)url
                  errorHandler:(void (^) (NSString *title, NSString *message))errorHandler
                successHandler:(void (^) (Podcast *podcast))successHandler
{
    NSURLRequest *request = [NSURLRequest
                             requestWithURL: url];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error)
         {
             errorHandler(@"Connection error", [error description]);
             return;
         }
         GDataXMLDocument *doc = [[GDataXMLDocument alloc]
                                  initWithData:data
                                  options:0
                                  error:&error];
         if (error)
         {
             errorHandler(@"XML-obtaining error", [error description]);
             return;
         }
         Podcast *podcast = [Podcast
                             podcastWithXML:doc
                             url:url
                             error:error];
         if (error)
         {
             errorHandler(@"XML-parsing error", [error description]);
             return;
         }
         successHandler(podcast);
     }];
}

- (PodcastItem*) currentItem
{
    return self.items[self.currentItemIndex.intValue];
}

+ (FMDatabase*) getDatabeseCreate
{
    NSString *documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                                objectAtIndex:0];
    NSString *dbTargetPath = [documentFolder stringByAppendingPathComponent:@"db.sqlite"];
    NSString *dbFromBundlePath = [[NSBundle mainBundle] pathForResource:@"db"
                                                                 ofType:@"sqlite"];
    
    NSLog(@"docFolder: %@", documentFolder);
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if(![fileManager fileExistsAtPath:dbTargetPath])
    {
        if(![fileManager fileExistsAtPath:dbFromBundlePath])
            return nil;
        NSError *error = nil;
        [fileManager
         copyItemAtPath:dbFromBundlePath
         toPath:dbTargetPath
         error:&error];
        if (error)
            return nil;
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbTargetPath];
    return db;
}

+ (Podcast*) podcastFromDB
{
    FMDatabase *db = [Podcast getDatabeseCreate];
    if(![db open])
        return nil;
    
    FMResultSet *s = [db executeQuery:@"SELECT * FROM podcast ORDER BY id DESC LIMIT 1"];
    if ([s next])
    {
        Podcast *podcast = [[Podcast alloc] init];
        podcast.title = [s stringForColumn:@"title"];
        podcast.urlString = [s stringForColumn:@"url_string"];
        if(![s columnIsNull:@"current_item_index"])
            podcast.currentItemIndex = [NSNumber numberWithInt: [s intForColumn:@"current_item_index"]];
        
        long long podcastId = [s longLongIntForColumn:@"id"];
        podcast.items = [PodcastItem
                         podcastItemsFromDB:db
                         WithPodcastID:podcastId];

        [db close];
        
        return podcast;
    }
    return nil;
}

- (long long) saveToDB
{
    FMDatabase *db = [Podcast getDatabeseCreate];
    
    if(![db open])
        return -1;
    long long last_id = 0;
    NSDate *date = nil;
    FMResultSet *s = [db
                      executeQuery:@"SELECT * FROM podcast WHERE url_string = ?",
                      self.urlString];
    if ([s next])
    {
        last_id = [s longLongIntForColumn:@"id"];
        s = [db
             executeQuery:@"SELECT * FROM podcast_item WHERE podcast_id = ? ORDER BY date DESC LIMIT 1",
             [NSNumber numberWithLongLong:last_id]];
        if ([s next])
        {
            date = [s dateForColumn:@"date"];
        }
        
        [db
         executeUpdate:@"UPDATE podcast SET title = :title, url_string = :url_string, current_item_index = :current_item_index WHERE url_string = :url_string"
         withParameterDictionary:@{@"title":self.title,
                                   @"url_string":self.urlString,
                                   @"current_item_index":self.currentItemIndex?self.currentItemIndex:[[NSNull alloc] init]}];
    }
    else
    {
        [db
         executeUpdate:@"INSERT INTO podcast (title, url_string, current_item_index) VALUES (:title, :url_string, :current_item_index)"
         withParameterDictionary:@{@"title":self.title,
                                   @"url_string":self.urlString,
                                   @"current_item_index":self.currentItemIndex?self.currentItemIndex:[[NSNull alloc] init]}];
        last_id = [db lastInsertRowId];
    }
    NSArray *items_to_save = self.items;
    if(date)
        items_to_save = [items_to_save filter:^BOOL(NSUInteger idx, PodcastItem* item) {
            return [item.date compare:date] == NSOrderedDescending;
        }];
    [items_to_save
     enumerateObjectsUsingBlock:^(PodcastItem* item, NSUInteger idx, BOOL *stop) {
        [item saveToDB:db
         WithPodcastID:last_id];
    }];
    
    [db close];
    return last_id;
}

@end
