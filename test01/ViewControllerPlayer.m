//
//  ViewControllerPlayer.m
//  test01
//
//  Created by dev on 11/19/13.
//  Copyright (c) 2013 dev. All rights reserved.
//

#import "ViewControllerPlayer.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewControllerPlayer ()
{
    __weak IBOutlet UISlider *_slider;
    __weak IBOutlet UIImageView *_picture;
    __weak IBOutlet UILabel *_time;
    __weak IBOutlet UILabel *_podcastItemTitle;
    __weak IBOutlet UILabel *_podcastTitle;
    __weak IBOutlet UILabel *_author;
    AVPlayer *_player;
    id _timeObserver;
}

@end

@implementation ViewControllerPlayer

- (NSTimeInterval)currentPlaybackTime
{
    return CMTimeGetSeconds(_player.currentItem.currentTime);
}


- (void)setCurrentPlaybackTime:(NSTimeInterval)time
{
    CMTime cmTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    [_player.currentItem seekToTime:cmTime];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.podcastItem.currentMedia = 0;
    }
    return self;
}

- (NSString*)stringifyTime:(CMTime)arg
{
    Float64 currentSeconds = CMTimeGetSeconds(arg);
    int mins = currentSeconds/60.0;
    int hours = mins/60.0;
    mins = fmodf(mins, 60.0);
    int secs = fmodf(currentSeconds, 60.0);
    NSString *hoursString = hours < 10 ?
    [NSString stringWithFormat:@"0%d", hours] :
    [NSString stringWithFormat:@"%d", hours];
    NSString *minsString = mins < 10 ?
    [NSString stringWithFormat:@"0%d", mins] :
    [NSString stringWithFormat:@"%d", mins];
    NSString *secsString = secs < 10 ?
    [NSString stringWithFormat:@"0%d", secs] :
    [NSString stringWithFormat:@"%d", secs];
    return [NSString
            stringWithFormat:@"%@:%@:%@",
            hoursString,
            minsString,
            secsString];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *minImage =
    [[UIImage imageNamed:@"album-seeker-progress"]
     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 0)
     resizingMode:UIImageResizingModeStretch
     ];
    UIImage *maxImage =
    [[UIImage imageNamed:@"album-seeker-base"]
     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)
     resizingMode:UIImageResizingModeStretch
     ];
    UIImage *thumbImage = [UIImage imageNamed:@"album-seeker-pointer"];
    [_slider
     setMinimumTrackImage:minImage
     forState:UIControlStateNormal];
    [_slider
     setMaximumTrackImage:maxImage
     forState:UIControlStateNormal];
    [_slider
     setThumbImage:thumbImage
     forState:UIControlStateNormal];
    
    [_picture
     setImageWithURL: self.podcast.currentItem.imageURL];
    [[_picture layer] setCornerRadius:5.0];
    [[_picture layer] setMasksToBounds:YES];
    
    [_podcastItemTitle
     setText: self.podcast.currentItem.title];
    [_podcastTitle
     setText: self.podcast.title];
    [_author
     setText: self.podcast.currentItem.author];
    
    NSURL *currentMediaURL = self.podcast.currentItem.currentMedia.url;

    AVURLAsset *asset = [[AVURLAsset alloc]
                         initWithURL:currentMediaURL
                         options:nil];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
    _player = [[AVPlayer alloc] initWithPlayerItem:item];
    [self setCurrentPlaybackTime:self.podcast.currentItem.currentMedia.seconds.doubleValue];
}

- (void) viewDidAppear:(BOOL)animated
{
    [_player play];
    
    __block AVPlayer *blockPlayer = _player;
    __block UISlider *blockSlider = _slider;
    __block UILabel *blockTime = _time;
    __block ViewControllerPlayer *blockSelf = self;
    _timeObserver =
    [_player
     addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.2f, NSEC_PER_SEC)
     queue:dispatch_get_main_queue()
     usingBlock:^(CMTime time) {
         CMTime endTime =
         CMTimeConvertScale (blockPlayer.currentItem.asset.duration,
                             blockPlayer.currentTime.timescale,
                             kCMTimeRoundingMethod_RoundHalfAwayFromZero);
         if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
             double normalizedTime =
             (double) blockPlayer.currentTime.value /
             (double) endTime.value;
             
             blockSelf.podcast.currentItem.currentMedia.seconds =
             [NSNumber numberWithFloat: CMTimeGetSeconds(blockPlayer.currentTime)];
             
             blockSlider.value = normalizedTime;
             blockTime.text = [NSString
                               stringWithFormat:@"%@ / %@",
                               [blockSelf stringifyTime:blockPlayer.currentTime],
                               [blockSelf stringifyTime:endTime]];
         }
     }];
}

- (IBAction)rewind15Sec:(UIButton *)sender {
    [self setCurrentPlaybackTime:
     [self currentPlaybackTime]-15];
}

- (IBAction)playOrResume:(id)sender {
    if (_player.rate == 1.0) {
        [_player pause];
    } else {
        [_player play];
    }
}

- (IBAction)nextTrack:(id)sender {
    
    NSURL *currentMediaURL = self.podcast.currentItem.nextMedia.url;
    
    AVURLAsset *asset = [[AVURLAsset alloc]
                         initWithURL:currentMediaURL
                         options:nil];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
    [_player replaceCurrentItemWithPlayerItem:item];
}

- (IBAction)sliderChanging:(UISlider *)sender {
    [_player pause];
    CMTime endTime =
    CMTimeConvertScale (_player.currentItem.asset.duration,
                        _player.currentTime.timescale,
                        kCMTimeRoundingMethod_RoundHalfAwayFromZero);
    double multi = (double)CMTimeGetSeconds(endTime);
    double time = multi*[sender value];
    _time.text = [NSString
                  stringWithFormat:@"%@ / %@",
                  [self stringifyTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)],
                  [self stringifyTime:endTime]];
}

- (IBAction)sliderChanged:(UISlider *)sender {
    CMTime endTime =
    CMTimeConvertScale (_player.currentItem.asset.duration,
                        _player.currentTime.timescale,
                        kCMTimeRoundingMethod_RoundHalfAwayFromZero);
    double multi = (double)CMTimeGetSeconds(endTime);
    double time = multi*[sender value];
    [self setCurrentPlaybackTime:time];
    [_player play];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_player removeTimeObserver:_timeObserver];
    _timeObserver = nil; // jeez. That was hard.
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
    self.podcast.currentItem = nil;
}

@end
