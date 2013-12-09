//
//  Podcast.h
//  test01
//
//  Created by dev on 11/23/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "GDataXMLNode.h"
#import <Foundation/Foundation.h>
#import "PodcastItem.h"
#import <FMDatabase.h>

@interface Podcast : NSObject

@property NSString *title;
@property NSArray *items;
@property NSString *urlString;
@property NSNumber* currentItemIndex;

+ (Podcast*)podcastWithXML:(GDataXMLDocument *)doc
                       url:(NSURL*)url
                     error:(NSError*)error;
+ (void)downloadPodcastWithURL:(NSURL*)url
                  errorHandler:(void (^) (NSString *title, NSString *message))errorHandler
                successHandler:(void (^) (Podcast *podcast))successHandler;

- (PodcastItem*) currentItem;

+ (FMDatabase*) getDatabeseCreate;
+ (Podcast*) podcastFromDB;
- (long long) saveToDB;

@end
