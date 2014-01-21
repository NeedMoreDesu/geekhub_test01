//
//  ViewController.m
//  test01
//
//  Created by dev on 10/21/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "Reach.h"
#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "ViewControllerPlayer.h"
#import "CoreData.h"

@interface ViewController ()

@end

@implementation ViewController
{
    __weak IBOutlet UITextField *_textField;
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UINavigationItem *_navigationItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSArray *firstOne = [[CoreData sharedInstance].mainMOC
//                         fetchObjectsForEntityName:@"Podcast"
//                         sortDescriptors:@[@[@"date", @NO]]
//                         limit:1
//                         predicate:nil];
    
//    if(firstOne.count > 0)
//    {
//        self.podcast = [firstOne objectAtIndex:0];
    if (self.podcast)
    {
        [_textField setText:self.podcast.urlString];
        [_navigationItem setTitle:self.podcast.title];
        [_tableView reloadData];
        if (self.podcast.currentItem)
        {
            ViewControllerPlayer *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"player"];
            controller.podcast = self.podcast;

            [self.navigationController
             pushViewController:controller
             animated:NO];
        }
    }
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)simpleAlert:(NSString*)title message:(NSString*)message
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
    if(![[Reach sharedInstance] networkIsReachable])
    {
        [[Reach sharedInstance].reach unreachableBlock]([Reach sharedInstance].reach);
        return NO;
    }
    self.podcast.urlString = [textField text];
    NSURL *url = [NSURL
                  URLWithString: [textField text]];
    __block id _self = self;
    [Podcast
     downloadPodcastWithURL:url
     errorHandler:^(NSString *title, NSString *message) {
         [_self simpleAlert:title message:message];
     } successHandler:^(Podcast *podcast) {
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            _podcast = podcast;
                            [_navigationItem setTitle:podcast.title];
                            [_tableView reloadData];
                        });
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
    return [_podcast.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PodcastItemCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSInteger row = [indexPath row];
    PodcastItem *podcastItem = [self.podcast.items objectAtIndex:row];
    
    [[cell textLabel] setText: [podcastItem title]];
    [[cell detailTextLabel] setText: [podcastItem author]];
    [[cell imageView]
     setImageWithURL: [podcastItem imageURL]
     completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            if (self.podcast.items.count <= indexPath.row)
                                return;
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
        self.podcast.currentItem = [self.podcast.items objectAtIndex:[selectedRowIndex row]];
        viewControllerPlayer.podcast = self.podcast;
    }
}

@end
