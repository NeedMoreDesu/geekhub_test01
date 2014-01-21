//
//  PodcastListViewController.m
//  test01
//
//  Created by dev on 1/21/14.
//  Copyright (c) 2014 dev. All rights reserved.
//

#import "PodcastListViewController.h"
#import "CoreData.h"
#import "Reach.h"

@interface PodcastListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PodcastListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.podcasts = [[CoreData sharedInstance].mainMOC
                     fetchObjectsForEntityName:@"Podcast"
                     sortDescriptors:@[@[@"date", @NO]]
                     limit:0
                     predicate:nil];
	// Do any additional setup after loading the view.
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
                            ViewController *vc = [[ViewController alloc] init];
                            vc.podcast = podcast;
                            [self.navigationController
                             pushViewController:vc
                             animated:YES];
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



- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.podcasts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PodcastCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSInteger row = [indexPath row];
    Podcast *podcast = [self.podcasts objectAtIndex:row];
    
    [[cell textLabel] setText: podcast.title];
    [[cell detailTextLabel] setText: podcast.urlString];
    
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"PodcastShow"])
    {
        NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
        ViewController *viewController = [segue destinationViewController];
        Podcast *currentPodcast = [self.podcasts objectAtIndex:[selectedRowIndex row]];
        viewController.podcast = currentPodcast;
    }
}

@end
