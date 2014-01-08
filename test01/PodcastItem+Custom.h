//
//  PodcastItem+Custom.h
//  test01
//
//  Created by dev on 12/24/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "GDataXMLNode.h"
#import "PodcastItem.h"
#import "NSManagedObject+Helpers.h"

@interface PodcastItem (Custom)

+ (NSArray*)podcastItemsWithXML:(GDataXMLDocument *)doc
           managedObjectContext:(NSManagedObjectContext*)moc
                          error:(NSError**)error;

- (Media*) nextMedia;

- (NSURL*)imageURL;
- (void)setImageURL:(NSURL*)url;
- (Media*)currentMedia;

@end
