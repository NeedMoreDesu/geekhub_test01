//
//  ViewControllerPlayer.m
//  test01
//
//  Created by dev on 11/19/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "ViewControllerPlayer.h"

@interface ViewControllerPlayer ()
{
    __weak IBOutlet UISlider *_slider;
}

@end

@implementation ViewControllerPlayer

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
    UIImage *minImage =
    [[UIImage imageNamed:@"album_seeker_progress"]
     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 0)
//     resizingMode:UIImageResizingModeStretch
     ];
    UIImage *maxImage =
    [[UIImage imageNamed:@"album_seeker_base"]
     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)
//     resizingMode:UIImageResizingModeStretch
     ];
    UIImage *thumbImage = [UIImage imageNamed:@"album_seeker_pointer"];
    [_slider
     setMinimumTrackImage:minImage
     forState:UIControlStateNormal];
    [_slider
     setMaximumTrackImage:maxImage
     forState:UIControlStateNormal];
    [_slider
     setThumbImage:thumbImage
     forState:UIControlStateNormal];
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
