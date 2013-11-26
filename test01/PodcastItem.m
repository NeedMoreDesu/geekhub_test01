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

+ (void)downloadItemsWithURL:(NSURL *)url
               errorHandler:(void (^) (NSString* title, NSString* message))errorHandler
             successHandler:(void (^) (NSArray* podcastItems))successHandler
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
         NSArray *items = [doc nodesForXPath:@"//channel/item" error: &error];
         if (error)
         {
             errorHandler(@"Given url have no podcast items", [error description]);
             return;
         }
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
         successHandler(podcastItems);
     }];
}

@end
