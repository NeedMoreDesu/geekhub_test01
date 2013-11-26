//
//  ViewController.m
//  test01
//
//  Created by dev on 10/21/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Reachability.h"
#import "ViewController.h"
#import "PodcastItem.h"
#import "Podcast.h"
#import "UIImageView+WebCache.h"
#import "ViewControllerPlayer.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSArray *_podcastItems;
    Podcast *_podcast;
    __weak IBOutlet UITextField *_textField;
    __weak IBOutlet UITableView *_tableView;
    Reachability* _reach;
}

- (BOOL)networkIsReachable
{
    NetworkStatus remoteHostStatus = [_reach currentReachabilityStatus];
    return remoteHostStatus != NotReachable;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _reach = [Reachability reachabilityForInternetConnection];
    [_reach startNotifier];
    _reach.unreachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc]
              initWithTitle:@"No connection"
              message:@""
              delegate:nil
              cancelButtonTitle:@"Ok"
              otherButtonTitles:nil]
             show];
        });
    };
    _reach.reachableBlock = ^(Reachability*reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc]
              initWithTitle:@"Internet connection established"
              message:@""
              delegate:nil
              cancelButtonTitle:@"Ok"
              otherButtonTitles:nil]
             show];
        });
    };

    if(![self networkIsReachable])
        [_reach unreachableBlock](_reach);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)simpleAlert:(NSString*)title error:(NSString*)message
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       [[[UIAlertView alloc]
                         initWithTitle:title
                         message:message
                         delegate:nil
                         cancelButtonTitle:@"Ok"
                         otherButtonTitles:nil]
                        show];
                   });
}

/// text field
- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
    if(![self networkIsReachable])
    {
        [_reach unreachableBlock](_reach);
        return NO;
    }
    NSURL *url = [NSURL
                  URLWithString: [textField text]];
    __block id _self = self;
    id errorHandler = ^(NSString *title, NSString *message)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [_self simpleAlert:title error:message];
                       });
    };
    [PodcastItem
     downloadItemsWithURL:url
     errorHandler:errorHandler
     successHandler:^(NSArray *podcastItems) {
         [Podcast
          downloadWithURL:url
          errorHandler:errorHandler
          successHandler:^(Podcast *podcast) {
              dispatch_async(dispatch_get_main_queue(),
                             ^{
                                 _podcast = podcast;
                                 _podcastItems = podcastItems;
                                 [_tableView reloadData];
                             });
          }];
     }];

    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

/// table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_podcastItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PodcastItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = [indexPath row];
    PodcastItem *podcastItem = [_podcastItems objectAtIndex:row];
    
    [[cell textLabel] setText: [podcastItem title]];
    [[cell detailTextLabel] setText: [podcastItem author]];
    [[cell imageView]
     setImageWithURL: [podcastItem imageURL]
     completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            [tableView beginUpdates];
                            [tableView
                             reloadRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
                            [tableView endUpdates];
                        });
     }];
    
    return cell;
}

///segues
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"PodcastItemShow"])
    {
        NSIndexPath *selectedRowIndex = [_tableView indexPathForSelectedRow];
        ViewControllerPlayer *viewControllerPlayer = [segue destinationViewController];
        [viewControllerPlayer
         setPodcastItem:[_podcastItems
                         objectAtIndex:[selectedRowIndex row]]];
        [viewControllerPlayer
         setPodcast:_podcast];
    }
}

@end
