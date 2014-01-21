//
//  Podcast+Custom.m
//  test01
//
//  Created by dev on 12/24/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Podcast+Custom.h"
#import "PodcastItem+Custom.h"
#import "CoreData.h"
#import "NSManagedObjectContext+Helpers.h"

@implementation Podcast (Custom)

+ (Podcast*)podcastWithXML:(GDataXMLDocument *)doc
      managedObjectContext:(NSManagedObjectContext*)moc
                       url:(NSURL*)url
                     error:(NSError**)error
{
    GDataXMLElement *channel = [[doc nodesForXPath:@"//channel" error: error]
                                objectAtIndex:0];
    if (*error)
        return nil;
    
    NSString *title = [[[channel elementsForName:@"title"]
                        objectAtIndex:0]
                       stringValue];
    NSArray *items = [PodcastItem
                      podcastItemsWithXML:doc
                      managedObjectContext:moc
                      error:error];
    NSString *urlString = [url absoluteString];
    
    if (error && *error)
        return nil;
    Podcast *podcast = [[moc
                         fetchObjectsForEntityName:NSStringFromClass([self class])
                         sortDescriptors:nil
                         limit:1
                         predicate:@"title = %@", title] firstObject];
    if (podcast)
    {
        items = [items filter:^BOOL(NSUInteger idx, PodcastItem *item) {
            NSLog(@"i:%@, p:%@", item.date, podcast.date);
            return [item.date compare:podcast.date]==NSOrderedDescending;
        }];
        [items enumerateObjectsUsingBlock:^(PodcastItem *obj, NSUInteger idx, BOOL *stop) {
            [obj insertToContext:moc];
        }];
        items = [items arrayByAddingObjectsFromArray:podcast.items.array];
    }
    else
    {
        podcast = [Podcast
                   newObjectWithContext:moc
                   entity:nil];
        [items enumerateObjectsUsingBlock:^(PodcastItem *obj, NSUInteger idx, BOOL *stop) {
            [obj insertToContext:moc];
        }];
    }
    [podcast setTitle:title];
    [podcast setUrlString:urlString];
    [podcast setDate:[NSDate date]];
    [podcast setItems:[NSOrderedSet orderedSetWithArray: items]];
    
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
             dispatch_async(dispatch_get_main_queue(), ^{
                 errorHandler(@"Connection error", [error description]);
             });
             return;
         }
         GDataXMLDocument *doc = [[GDataXMLDocument alloc]
                                  initWithData:data
                                  options:0
                                  error:&error];
         if (error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 errorHandler(@"XML-obtaining error", [error description]);
             });
             return;
         }
         
         [[CoreData sharedInstance].backgroundMOC performBlock:^{
             NSError *error = nil;
             Podcast *podcast = [Podcast
                                 podcastWithXML:doc
                                 managedObjectContext:[CoreData sharedInstance].backgroundMOC
                                 url:url
                                 error:&error];
             if (error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     errorHandler(@"XML-parsing error", [error description]);
                 });
                 return;
             }
             [[CoreData sharedInstance].backgroundMOC save:&error];
             if (error)
                 dispatch_async(dispatch_get_main_queue(), ^{
                     errorHandler(@"Error during save", [error description]);
                 });

             NSManagedObjectID *moid = [podcast objectID];
             [[CoreData sharedInstance].mainMOC performBlock:^{
                 Podcast *podcast = (Podcast*)[[CoreData sharedInstance].mainMOC
                                               objectWithID:moid];
                 successHandler(podcast);
             }];
         }];
     }];
}

@end
