//
//  Podcast.m
//  test01
//
//  Created by dev on 11/23/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Podcast.h"
#import "PodcastItem.h"

@implementation Podcast

+ (Podcast*)podcastWithXML:(GDataXMLDocument *)doc error:(NSError*)error
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
    if (error)
        return nil;
    Podcast *podcast = [[Podcast alloc] init];
    [podcast setTitle:title];
    [podcast setItems:items];
    
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
                             error:error];
         if (error)
         {
             errorHandler(@"XML-parsing error", [error description]);
             return;
         }
         successHandler(podcast);
     }];
}


@end
