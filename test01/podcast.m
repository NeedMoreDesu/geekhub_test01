//
//  Podcast.m
//  test01
//
//  Created by dev on 11/23/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Podcast.h"

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
    
    Podcast *podcast = [[Podcast alloc] init];
    [podcast setTitle:title];
    
    return podcast;
}

@end
