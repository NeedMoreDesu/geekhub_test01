//
//  Podcast.m
//  test01
//
//  Created by dev on 11/23/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Podcast.h"

@implementation Podcast

+ (void)downloadWithURL:(NSURL *)url
          errorHandler:(void (^) (NSString* title, NSString* message))errorHandler
        successHandler:(void (^) (Podcast* podcast))successHandler
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
         GDataXMLElement *channel = [[doc nodesForXPath:@"//channel" error: &error]
                                     objectAtIndex:0];
         if (error)
         {
             errorHandler(@"Given url have no podcast title", [error description]);
             return;
         }
         
         NSString *title = [[[channel elementsForName:@"title"]
                             objectAtIndex:0]
                            stringValue];
         
         Podcast *podcast = [[Podcast alloc] init];
         [podcast setTitle:title];
         
         successHandler(podcast);
     }];
}

@end
