//
//  Podcast.m
//  test01
//
//  Created by dev on 11/1/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Podcast.h"
#import "NSArray+Func.h"

@implementation Podcast

+ (void)downloadPodcastWithURL:(NSURL *)URL
                  errorHandler:(void (^) (NSString *title, NSError *error))errorHandler
                successHandler:(void (^) (NSArray *podcasts))successHandler
{
    NSURLRequest *request = [NSURLRequest
                             requestWithURL: URL];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if(error)
         {
             errorHandler(@"Connection error", error);
             return;
         }
         GDataXMLDocument *doc = [[GDataXMLDocument alloc]
                                  initWithData:data
                                  options:0
                                  error:&error];
         if (error)
         {
             errorHandler(@"XML-obtaining error", error);
             return;
         }
         
         NSArray *items = [doc nodesForXPath:@"//channel/item" error: &error];
         if (error)
         {
             errorHandler(@"Parsing error", error);
             return;
         }
         NSArray *podcasts =
         [items
          map:
          ^id(id arg)
          {
              GDataXMLElement *item = arg;
              NSString *title = [[[item elementsForName:@"title"]
                                  objectAtIndex:0]
                                 stringValue];
              NSURL *imageURL = [NSURL
                                 URLWithString:
                                 [[[[item elementsForName:@"itunes:image"]
                                    objectAtIndex:0]
                                   attributeForName:@"href"]
                                  stringValue]];
              Podcast *podcast = [[Podcast alloc]
                                  initWithTitle:title
                                  imageURL:imageURL];
              return podcast;
          }];
         successHandler(podcasts);
     }];
    
}

-(id)initWithTitle:(NSString *)title imageURL:(NSURL *)imageURL
{
    if(self = [super init])
    {
        [self setTitle:title];
        [self setImageURL:imageURL];
    }
    return self;
}

-(UITableViewCell*) changeCell:(UITableViewCell *)cell completeHandler:(void (^)(UIImage *image, NSError *error, SDImageCacheType cacheType))handler
{
    [[cell textLabel] setText: [self title]];
    [[cell imageView]
     setImageWithURL: [self imageURL]
     completed: handler];
    return cell;
}

@end
