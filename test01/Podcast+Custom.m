//
//  Podcast+Custom.m
//  test01
//
//  Created by dev on 12/24/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Podcast+Custom.h"
#import "PodcastItem+Custom.h"

@implementation Podcast (Custom)

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
    Podcast *podcast = [Podcast
                        newObjectWithContext:nil
                        entity:[Podcast class]];
    [podcast setTitle:title];
    [podcast setItems:[NSOrderedSet orderedSetWithArray: items]];
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

@end
