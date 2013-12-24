//
//  PodcastItem+Custom.m
//  test01
//
//  Created by dev on 12/24/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "PodcastItem+Custom.h"
#import "NSArray+Func.h"
#import "Media+Custom.h"

@implementation PodcastItem (Custom)

- (NSURL*)imageURL
{
    return [NSURL URLWithString: self.imageUrlString];
}
- (void)setImageURL:(NSURL *)url
{
    self.imageUrlString = [url absoluteString];
}

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
                               Media *media = [Media
                                               newObjectWithContext:nil
                                               entity:[Media class]];
                               media.urlString =
                               [[item attributeForName:@"url"]
                                stringValue];
                               media.seconds = @0.0;
                               return media;
                           }];
         
         PodcastItem *podcastItem = [PodcastItem
                                     newObjectWithContext:nil
                                     entity:[PodcastItem class]];
         
         [podcastItem setTitle:title];
         [podcastItem setImageURL:imageURL];
         [podcastItem setAuthor:author];
         [podcastItem setDate:date];
         [podcastItem setMedia:[NSSet setWithArray: media]];
         [podcastItem setCurrentMediaIndex:@0];
         
         return podcastItem;
     }];
    return podcastItems;
}

- (int) nextMedia
{
    int media = [self.currentMediaIndex intValue];
    media++;
    if (media >= self.media.count)
        media = 0;
    self.currentMediaIndex = [NSNumber numberWithInt:media];
    return media;
}

- (Media*) currentMedia
{
    return [[self.media allObjects]
            objectAtIndex:self.currentMediaIndex.integerValue];
}

@end
