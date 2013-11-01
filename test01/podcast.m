//
//  Podcast.m
//  test01
//
//  Created by dev on 11/1/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Podcast.h"

@implementation Podcast

- (void)downloadPodcastWithURL:(NSURL *)URL
                  errorHandler:(void (^) (NSString *title, NSError *error))errorHandler
                successHandler:(void (^)())successHandler
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
         // must not rewrite until we know everything is ok
         _doc = doc;
         _items = items;
         successHandler();
     }];
    
}

- (NSInteger) getLength
{
    return [_items count];
}

- (NSString*) getTitleAt:(NSInteger)row
{
    GDataXMLElement * item = [_items objectAtIndex:row];
    return [[[item elementsForName:@"title"] objectAtIndex:0] stringValue];
}

- (NSURL*) getImageURLAt:(NSInteger)row
{
    GDataXMLElement * item = [_items objectAtIndex:row];
    return [NSURL
            URLWithString:
            [[[[item elementsForName:@"itunes:image"] objectAtIndex:0]
             attributeForName:@"href"] stringValue]];
}

-(UITableViewCell*) changeCell:(UITableViewCell *)cell at:(NSInteger)row
{
    [[cell textLabel] setText: [self getTitleAt:row]];
//    [[cell imageView]
//     setImageWithURL: [self getImageURLAt:row]
//     placeholderImage: [UIImage imageNamed:@"placeholder.png"]];
    return cell;
}

@end
