//
//  SettingsView.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/25/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "SettingsView.h"
#import "AudioController.h"
#import "UIView+Fancy.h"
#import "DCRoundSwitch.h"
#import <Social/Social.h>
#import "SessionM.h"

@implementation SettingsView {
    BOOL showingSettings;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupMusicToggle) name:kMusicToggleChanged object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupSFXToggle) name:kSFXToggleChanged object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupSessionMToggle) name:kSessionMToggleChanged object:nil];
    }
    return self;
}

-(void)didMoveToSuperview {
    self.settingsLeadngConstraint.constant = -1 * self.superview.frame.size.height;
    [self setupToggles];
    [self.musicSettingsToggle addTarget:self action:@selector(musicSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    [self.sfxSettingsToggle addTarget:self action:@selector(sfxSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    [self.sessionMSettingsToggle addTarget:self action:@selector(sessionMSwitchToggled:) forControlEvents:UIControlEventValueChanged];
}


-(void)setupToggles {
    [self setupMusicToggle];
    [self setupSFXToggle];
    [self setupSessionMToggle];
}

-(void)setupMusicToggle {
    self.musicSettingsToggle.on = [ABIMSIMDefaults boolForKey:kMusicSetting];
}

-(void)setupSFXToggle {
    self.sfxSettingsToggle.on = [ABIMSIMDefaults boolForKey:kSFXSetting];
}

-(void)setupSessionMToggle {
    self.sessionMSettingsToggle.on = ![SessionM sharedInstance].user.isOptedOut;
    self.sessionMSettingsToggle.ignoreTap = NO;
}


-(void)showSettings {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.settingsTopConstraint.constant = 50;
        self.settingsLeadngConstraint.constant = 15;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        showingSettings = YES;
    }];
}

-(void)hideSettings {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.settingsLeadngConstraint.constant = -1 * self.superview.frame.size.height;
        self.settingsTopConstraint.constant = 200;
        
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        showingSettings = NO;
    }];
}

-(void)musicSwitchToggled:(DCRoundSwitch*)toggle {
    [ABIMSIMDefaults setBool:toggle.on forKey:kMusicSetting];
    [ABIMSIMDefaults synchronize];
    self.musicSettingsToggle.on = toggle.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMusicToggleChanged object:nil];
}

-(void)sfxSwitchToggled:(DCRoundSwitch*)toggle {
    [ABIMSIMDefaults setBool:toggle.on forKey:kSFXSetting];
    [ABIMSIMDefaults synchronize];
    self.sfxSettingsToggle.on = toggle.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSFXToggleChanged object:nil];
}

-(void)sessionMSwitchToggled:(DCRoundSwitch*)toggle {
    [SessionM sharedInstance].user.isOptedOut = !toggle.on;
    self.sessionMSettingsToggle.on = toggle.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSessionMToggleChanged object:nil];
}

- (IBAction)twitterTapped:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [composeController setInitialText:@"I'm exploring the farthest reaches of space playing Parsecs! Check it out:"];
        [composeController addURL: [NSURL URLWithString:
                                    @"http://bit.ly/parsecs"]];
        
        [self.delegate presentViewController:composeController
                           animated:YES completion:nil];
    } else {
        UIAlertView *alert;
        if ([UIDevice currentDevice].systemVersion.integerValue >= 8) {
            alert = [[UIAlertView alloc] initWithTitle:@"Twitter Unavailable" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
            
        } else {
            alert = [[UIAlertView alloc] initWithTitle:@"Twitter Unavailable" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        }
        [alert show];
    }
}

- (IBAction)facebookTapped:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [composeController setInitialText:@"I'm exploring the farthest reaches of space playing Parsecs! Check it out: http://bit.ly/parsecs"];
        [composeController addURL: [NSURL URLWithString:
                                    @"http://bit.ly/parsecs"]];
        
        [self.delegate presentViewController:composeController
                           animated:YES completion:nil];
    } else {
        UIAlertView *alert;
        if ([UIDevice currentDevice].systemVersion.integerValue >= 8) {
            alert = [[UIAlertView alloc] initWithTitle:@"Facebook Unavailable" message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
            
        } else {
            alert = [[UIAlertView alloc] initWithTitle:@"Twitter Unavailable" message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        }
        [alert show];
    }
}

- (IBAction)resetTapped:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Are you sure you want to reset all game data? This includes all upgrades and XP earned. This cannot be undone." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag = 777;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { //do nothing
        ;
    } else {
        if (alertView.tag == 777) {//reset
            [ABIMSIMDefaults setInteger:0 forKey:kShieldOccuranceLevel];
            [ABIMSIMDefaults setInteger:0 forKey:kShieldDurabilityLevel];
            [ABIMSIMDefaults setBool:NO forKey:kShieldOnStart];
            [ABIMSIMDefaults setInteger:0 forKey:kMineOccuranceLevel];
            [ABIMSIMDefaults setInteger:0 forKey:kMineBlastSpeedLevel];
            [ABIMSIMDefaults setInteger:0 forKey:kUserDuckets];
            [ABIMSIMDefaults setBool:NO forKey:kWalkthroughSeen];
            [ABIMSIMDefaults synchronize];
            [self.delegate settingsDidReset];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
