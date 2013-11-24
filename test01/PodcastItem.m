//
//  Podcast.m
//  test01
//
//  Created by dev on 11/1/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "PodcastItem.h"
#import "NSArray+Func.h"

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
         [podcastItem setMedia:media];
         
         return podcastItem;
     }];
    return podcastItems;
}

@end
