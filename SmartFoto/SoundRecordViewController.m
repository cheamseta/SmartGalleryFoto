//
//  SoundRecordViewController.m
//  Photobook
//
//  Created by seta cheam on 17/5/16.
//  Copyright © 2016 seta cheam. All rights reserved.
//

#import "SoundRecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SYWaveformPlayerView.h"
#import "PhotoSound.h"
#import "TextCollectionViewCell.h"
#import "QueryServices.h"
#import "Tags.h"
#import "PhotoSound.h"


@interface SoundRecordViewController ()<AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITextFieldDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) AVAudioRecorder * recorder;
@property (strong, nonatomic) AVAudioPlayer * player;
@property (strong, nonatomic) NSString * soundFile;

@property (strong, nonatomic) NSMutableSet<Tags *> * tagSet;
@property (strong, nonatomic) Tags * tags;
@property (strong, nonatomic) PhotoSound * sound;
@property (strong, nonatomic) SYWaveformPlayerView *playerWaveView;

@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *soundTimerLabel;
@property (strong, nonatomic) IBOutlet UIView *playerView;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;

@property (strong, nonatomic) NSTimer * myTimer;

@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;
@property (strong, nonatomic) NSString * placeName;

@end

@implementation SoundRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // default sound recording setting up
    [self defaultView];
    
}

#pragma mark - mehtod

- (void)defaultView {
    
    self.placeName = [Services storeGetDefaultSettingByKey:@"countryKey"];
    self.longitude = [Services storeGetFloatDefaultSettingByKey:@"lngKey"];
    self.latitude = [Services storeGetFloatDefaultSettingByKey:@"latKey"];
    
    [self.photoImageView setImage:self.galleryImage];
    [self.saveButton setHidden:YES];
    
}

- (void)defaultSettingUpSoundInName:(NSString *)nameString {
    
    // set sound locaton
    NSURL * fileLocationUrl = [NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:
                                                                [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                                                nameString, nil]];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    
    self.recorder = [[AVAudioRecorder alloc] initWithURL:fileLocationUrl settings:recordSetting error:NULL];
    
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
}

- (void)updateSlider {
    // Update the slider about the music time
    if([self.recorder isRecording])
    {
        
        NSInteger minutes = floor(self.recorder.currentTime/60);
        NSInteger seconds = self.recorder.currentTime - (minutes * 60);
        
        NSString *time = [[NSString alloc]
                          initWithFormat:@" • Now recording %0.2ld:%0.2ld",
                          (long)minutes, (long)seconds];
        self.soundTimerLabel.text = time;
    }
}

#pragma mark - IB Action

- (IBAction)saveAction:(id)sender {
    
    NSString * soundUrl = @"";
    
    if (self.soundFile)
        soundUrl = [NSString stringWithFormat:@"Documents/%@", self.soundFile];
    
    self.editedSound.sound = soundUrl;
    [[NSManagedObjectContext MR_defaultContext]
     MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"editRefresh" object:self];
         [self.navigationController popViewControllerAnimated:YES];
     }];
}

- (IBAction)recordAction:(UIButton *)sender {
    
    if (!self.recorder) {
        self.soundFile = [NSString stringWithFormat:@"%@.m4a", [[NSUUID UUID] UUIDString]];
        [self defaultSettingUpSoundInName:self.soundFile];
    }
    
    if (!self.recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [self.recorder record];
        
        [sender setImage:[UIImage imageNamed:@"Recording"] forState:UIControlStateNormal];
        [self.saveButton setHidden:YES];
        [self.playerView setHidden:YES];
        
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(updateSlider)
                                                      userInfo:nil
                                                       repeats:YES];
        
    } else {
        
        [self.recorder pause];
        [self.recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        [sender setImage:[UIImage imageNamed:@"Record"] forState:UIControlStateNormal];
        [self.saveButton setHidden:NO];
        [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
        
        [self.playerView setHidden:NO];
        [self.playerWaveView removeFromSuperview];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.recorder.url
                                                    options:nil];
        
        self.playerWaveView = [[SYWaveformPlayerView alloc]
                               initWithFrame:CGRectMake(0, 5, self.playerView.frame.size.width - 40, 30)
                               asset:asset
                               color:[UIColor lightGrayColor]
                               progressColor:[UIColor colorWithRed:1 green:0.2 blue:0.2 alpha:1]];
        
        [self.playerView addSubview:self.playerWaveView];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
