//
//  ViewController.m
//  test01
//
//  Created by dev on 10/21/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    [[self textField] setText:@"http://obrazovanie.rpod.ru/rss.xml"];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// text field
- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
    NSURLRequest *request = [NSURLRequest
                             requestWithURL: [NSURL
                                              URLWithString: [textField text]]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    return YES;
}

/// networking
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    _doc = [[GDataXMLDocument alloc]
            initWithData:_responseData
            options:0
            error:&error];
    if (error) NSLog(@"xml-obtaining error: %@", error);
    _items = [_doc nodesForXPath:@"//channel/item" error: &error];
    if (error) NSLog(@"parse error: %@", error);
    
    [[self tableView] reloadData];

    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"connection error%@", error);
    // The request has failed for some reason!
    // Check the error var
}

/// table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }

    NSInteger row = [indexPath row];
    GDataXMLElement * item = [_items objectAtIndex:row];
    
    NSString *imageUrl = [[[[item elementsForName:@"itunes:image"] objectAtIndex:0]
                          attributeForName:@"href"] stringValue];

    NSString *text = [[[item elementsForName:@"title"] objectAtIndex:0] stringValue];
    UIImage *image = [UIImage imageWithData:
                      [NSData dataWithContentsOfURL:   // sync, so may cause slowdown
                       [NSURL URLWithString:imageUrl]]];
    
    [[cell textLabel]
     setText:text];
    
    [[cell imageView]
     setImage:image];
    
    return cell;
}

@end
