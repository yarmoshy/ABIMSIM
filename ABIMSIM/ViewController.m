//
//  ViewController.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/10/14.
//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"
#import "DCRoundSwitch.h"
#import <objc/runtime.h>
#import "AudioController.h"

#define kBlurBackgroundViewTag 777

@implementation ViewController {
    NSMutableArray *hamburgerToXImages;
    NSMutableArray *hamburgerToOriginalImages;
    BOOL showingSettings;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AudioController sharedController];
    
    self.settingsContainerTopAlignmentConstraint.constant = -1* (self.view.frame.size.height - self.buttonContainerView.frame.origin.y);
    self.settingsContainerTrailingConstraint.constant = self.view.frame.size.width;
    self.settingsLeadngConstraint.constant = -1 * self.view.frame.size.height;

    showingSettings = NO;
    hamburgerToXImages = [NSMutableArray array];
    hamburgerToOriginalImages = [NSMutableArray array];
    for (int i = 0; i <= 17; i++) {
        [hamburgerToXImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"HamburgerToClose_%0*d", 3, i]]];
    }
    [hamburgerToXImages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [hamburgerToOriginalImages addObject:obj];
    }];
    self.playButton.exclusiveTouch = self.upgradeButton.exclusiveTouch = self.highScoreButton.exclusiveTouch = self.creditsButton.exclusiveTouch = self.hamburgerButton.exclusiveTouch = self.playPausedButton.exclusiveTouch = self.mainMenuButton.exclusiveTouch = YES;
    self.musicPausedSwitch.on = [ABIMSIMDefaults boolForKey:kMusicSetting];
    [self.musicPausedSwitch addTarget:self action:@selector(musicSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    self.sfxPausedSwitch.on = [ABIMSIMDefaults boolForKey:kSFXSetting];
    [self.sfxPausedSwitch addTarget:self action:@selector(sfxSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    
    self.musicSettingsToggle.on = [ABIMSIMDefaults boolForKey:kMusicSetting];
    [self.musicSettingsToggle addTarget:self action:@selector(musicSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    self.sfxSettingsToggle.on = [ABIMSIMDefaults boolForKey:kSFXSetting];
    [self.sfxSettingsToggle addTarget:self action:@selector(sfxSwitchToggled:) forControlEvents:UIControlEventValueChanged];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = NO;
    
    // Create and configure the scene.
    self.scene = [GameScene sceneWithSize:skView.bounds.size];
    
    self.scene.size = skView.bounds.size;
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.scene.viewController = self;
    // Present the scene.
    [skView presentScene:self.scene];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)pauseButtonTapped:(id)sender {
    if (self.scene.initialPause || self.scene.resuming) return;
    self.scene.paused = !self.scene.paused;
}

-(void)showPausedView {
//    if (self.mainMenuView.alpha != 0) {
//        return;
//    }
    UIImageView *blurredBackgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor clearColor];
        imageView;
    });
    blurredBackgroundImageView.tag = kBlurBackgroundViewTag;
    blurredBackgroundImageView.frame = CGRectMake(blurredBackgroundImageView.frame.origin.x, 0, blurredBackgroundImageView.frame.size.width, blurredBackgroundImageView.frame.size.height);
    UIImage *screenShot = [self.view imageFromScreenShot];
    
    UIColor *blurTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    float blurSaturationDeltaFactor = 0.6;
    float blurRadius = 5;
    
    blurredBackgroundImageView.image = [screenShot applyBlurWithRadius:blurRadius tintColor:blurTintColor saturationDeltaFactor:blurSaturationDeltaFactor maskImage:nil];
    
    [self.pausedView insertSubview:blurredBackgroundImageView atIndex:0];
    self.pausedView.backgroundColor = [UIColor clearColor];
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        self.pausedView.alpha = 1;
    } completion:^(BOOL finished) {
        ;
    }];

}
#pragma mark - Play Button

-(void)animatePlayButtonSelect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.playRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.12, 1.12)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.playRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.07, 1.07)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.playRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.playRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)animatePlayButtonDeselect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.playRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.playRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.playRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.playRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.96, 0.96)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }];
}

- (IBAction)playSelect:(id)sender {
    [self animatePlayButtonSelect:nil];
}

- (IBAction)playDeselect:(id)sender {
    [self animatePlayButtonDeselect:nil];
}

- (IBAction)playTouchUpInside:(id)sender {
    [self configureButtonsEnabled:NO];
    [self animatePlayButtonDeselect:^{
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            self.mainMenuView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.scene transitionFromMainMenu];
            [self configureButtonsEnabled:YES];
        }];
    }];
}

#pragma mark - High Scores

-(void)animateHighScoresButtonSelect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.hsRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.12, 1.12)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.hsRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.07, 1.07)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.hsRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.hsRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)animateHighScoresButtonDeselect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.hsRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.hsRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.hsRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.hsRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.hsRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.hsRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.hsRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.96, 0.96)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.hsRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }];
}


- (IBAction)highScoresSelect:(id)sender {
    [self animateHighScoresButtonSelect:nil];
}

- (IBAction)highScoresDeselect:(id)sender {
    [self animateHighScoresButtonDeselect:nil];
}

- (IBAction)highScoresTouchUpInside:(id)sender {
    [self configureButtonsEnabled:NO];
    [self animateHighScoresButtonDeselect:^{
        [self showGameCenter];
    }];
}

- (void) showGameCenter {
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init];
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        [self presentViewController: gameCenterController animated: YES completion:nil];
    } else {
        [self configureButtonsEnabled:YES];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [self configureButtonsEnabled:YES];
    }];
}


#pragma mark - Upgrades

-(void)animateUpgradesButtonSelect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.upgradeRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.12, 1.12)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.upgradeRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.07, 1.07)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.upgradeRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.upgradeRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)animateUpgradesButtonDeselect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.upgradeRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.upgradeRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.upgradeRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.upgradeRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.upgradeRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.upgradeRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.upgradeRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.96, 0.96)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.upgradeRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }];
}

- (IBAction)upgradesSelect:(id)sender {
    [self animateUpgradesButtonSelect:nil];
}

- (IBAction)upgradesDeselect:(id)sender {
    [self animateUpgradesButtonDeselect:nil];
}

- (IBAction)upgradesTouchUpInside:(id)sender {
    [self animateUpgradesButtonDeselect:^{
        
    }];
}

#pragma mark - Settings

- (IBAction)hamburgerTapped:(id)sender {
    [self configureButtonsEnabled:NO];
    if (showingSettings) {
        [self hideSettings];
        [self.hamburgerButton.imageView setAnimationImages:hamburgerToOriginalImages];
        [self.hamburgerButton setImage:hamburgerToOriginalImages.lastObject forState:UIControlStateNormal];
    } else {
        [self showSettings];
        [self.hamburgerButton.imageView setAnimationImages:hamburgerToXImages];
        [self.hamburgerButton setImage:hamburgerToXImages.lastObject forState:UIControlStateNormal];
    }
    [self.hamburgerButton setHighlighted:NO];
    [self.hamburgerButton.imageView setAnimationDuration:1];
    [self.hamburgerButton.imageView setAnimationRepeatCount:1];
    [self.hamburgerButton.imageView startAnimating];
}

-(void)showSettings {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.buttonContainerView.alpha = 0;
    } completion:^(BOOL finished) {
        ;
    }];

    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.hamburgerBottomConstraint.constant = self.view.frame.size.height - self.buttonContainerView.frame.origin.y - 100;
        self.hamburgerLeadingConstraint.constant = self.buttonContainerView.frame.origin.x + self.buttonContainerView.frame.size.width - 100;
        self.settingsContainerTopAlignmentConstraint.constant = 0;
        self.settingsContainerTrailingConstraint.constant = 0;
        self.settingsTopConstraint.constant = 50;
        self.settingsLeadngConstraint.constant = 15;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        showingSettings = YES;
        [self configureButtonsEnabled:YES];
    }];
}

-(void)hideSettings {
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.buttonContainerView.alpha = 1;
    } completion:^(BOOL finished) {
        ;
    }];

    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.hamburgerBottomConstraint.constant = 10;
        self.hamburgerLeadingConstraint.constant = 10;
        self.settingsContainerTopAlignmentConstraint.constant = -1* (self.view.frame.size.height - self.buttonContainerView.frame.origin.y);
        self.settingsContainerTrailingConstraint.constant = self.view.frame.size.width;
        self.settingsLeadngConstraint.constant = -1 * self.view.frame.size.height;
        self.settingsTopConstraint.constant = 200;

        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        showingSettings = NO;
        [self configureButtonsEnabled:YES];
    }];
}

-(void)musicSwitchToggled:(DCRoundSwitch*)toggle {
    [ABIMSIMDefaults setBool:toggle.on forKey:kMusicSetting];
    [ABIMSIMDefaults synchronize];
    self.musicPausedSwitch.on = self.musicSettingsToggle.on = toggle.on;
}

-(void)sfxSwitchToggled:(DCRoundSwitch*)toggle {
    [ABIMSIMDefaults setBool:toggle.on forKey:kSFXSetting];
    [ABIMSIMDefaults synchronize];
    self.sfxPausedSwitch.on = self.sfxSettingsToggle.on = toggle.on;
}

- (IBAction)twitterTapped:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [composeController setInitialText:@"I'm exploring the farthest reaches of space playing Parsecs! Check it out: http://bit.ly/parsecs"];
        [composeController addURL: [NSURL URLWithString:
                                    @"http://bit.ly/parsecs"]];
        
        [self presentViewController:composeController
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
        
        [self presentViewController:composeController
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Are you sure you want to reset all game data? This includes all upgrades and space duckets earned. This cannot be undone." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
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
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

#pragma mark - Paused Play Button

-(void)animatePlayPausedButtonSelect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.playPausedRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.12, 1.12)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.playPausedRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.07, 1.07)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.playPausedRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.playPausedRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)animatePlayPausedButtonDeselect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.playPausedRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playPausedRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.playPausedRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playPausedRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.playPausedRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playPausedRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.playPausedRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.96, 0.96)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playPausedRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }];
}

- (IBAction)playPausedSelect:(id)sender {
    [self animatePlayPausedButtonSelect:nil];
}

- (IBAction)playPausedDeselect:(id)sender {
    [self animatePlayPausedButtonDeselect:nil];
}

- (IBAction)playPausedTouchUpInside:(id)sender {
    [[AudioController sharedController] gameplay];
    
    [self configureButtonsEnabled:NO];
    [self animatePlayPausedButtonDeselect:^{
        self.scene.resuming = YES;
        [self.view insertSubview:[self.pausedView viewWithTag:kBlurBackgroundViewTag] atIndex:1];

        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            self.pausedView.alpha = 0;
        } completion:^(BOOL finished) {
            ;
        }];
        UIImageView *ring3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Play_3"]];
        UIImageView *ring2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Play_2"]];
        UIImageView *ring1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Play_1"]];
        UIImageView *ring0 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Play_0"]];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Countdown_0"]];
        UIView *resumeView = [[UIView alloc] initWithFrame:ring3.frame];
        imageView.frame = resumeView.bounds;
        imageView.contentMode = UIViewContentModeCenter;
        [resumeView addSubview:ring3];
        [resumeView addSubview:ring2];
        [resumeView addSubview:ring1];
        [resumeView addSubview:ring0];
        [resumeView addSubview:imageView];
        ring3.center = ring2.center = ring1.center = ring0.center = imageView.center = CGPointMake(resumeView.frame.size.width/2.f, resumeView.frame.size.height/2.f);
        resumeView.alpha = 0;
        resumeView.center = self.view.center;
        resumeView.userInteractionEnabled = NO;
        [self.view addSubview:resumeView];
        [UIView animateWithDuration:0.25 delay:0.25 options:0 animations:^{
            resumeView.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                [imageView setImage:[UIImage imageNamed:@"Countdown_3"]];
                [imageView setAnimationDuration:2.5];
                [imageView setAnimationRepeatCount:1];
                [imageView setAnimationImages:@[[UIImage imageNamed:@"Countdown_0"],[UIImage imageNamed:@"Countdown_1"],[UIImage imageNamed:@"Countdown_2"],[UIImage imageNamed:@"Countdown_3"]]];
                [imageView startAnimating];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.25 animations:^{
                        resumeView.alpha = 0;
                        [[self.view viewWithTag:kBlurBackgroundViewTag] setAlpha:0];
                    } completion:^(BOOL finished) {
                        if (finished) {
                            [[self.view viewWithTag:kBlurBackgroundViewTag] removeFromSuperview];
                            [resumeView removeFromSuperview];
                        }
                    }];
                });
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self configureButtonsEnabled:YES];
                    self.scene.resuming = self.scene.paused = NO;
                });
            }
        }];

    }];
}

#pragma mark - Main Menu Button

-(void)animateMainMenuButtonSelect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.mmRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.12, 1.12)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.mmRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.07, 1.07)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.mmRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.mmRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)animateMainMenuButtonDeselect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.mmRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.mmRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.mmRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.mmRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.mmRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.mmRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.mmRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.96, 0.96)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.mmRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }];
}

- (IBAction)mainMenuSelect:(id)sender {
    [self animateMainMenuButtonSelect:nil];
}

- (IBAction)mainMenuDeselect:(id)sender {
    [self animateMainMenuButtonDeselect:nil];
}

- (IBAction)mainMenuTouchUpInside:(id)sender {
    [[AudioController sharedController] playerDeath];
    [self configureButtonsEnabled:NO];
    [self animateMainMenuButtonDeselect:^{
        self.scene = [GameScene sceneWithSize:self.view.bounds.size];
        
        self.scene.size = self.view.bounds.size;
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        self.scene.viewController = self;
        // Present the scene.
        [(SKView*)self.view presentScene:self.scene];
        self.pauseButton.alpha = 0;

        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            self.pausedView.alpha = 0;
        } completion:^(BOOL finished) {
            [[self.pausedView viewWithTag:kBlurBackgroundViewTag] removeFromSuperview];
            [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
                self.mainMenuView.alpha = 1;
            } completion:^(BOOL finished) {
                [self configureButtonsEnabled:YES];
            }];
        }];
    }];
}



#pragma mark - Game Over Play Button

-(void)animateGGPlayButtonSelect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ggPlayRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.12, 1.12)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ggPlayRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.07, 1.07)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ggPlayRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ggPlayRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)animateGGPlayButtonDeselect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.ggPlayRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.ggPlayRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.ggPlayRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.ggPlayRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.ggPlayRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.ggPlayRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.ggPlayRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.96, 0.96)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.ggPlayRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }];
}

- (IBAction)ggPlaySelect:(id)sender {
    [self animateGGPlayButtonSelect:nil];
}

- (IBAction)ggPlayDeselect:(id)sender {
    [self animateGGPlayButtonDeselect:nil];
}

- (IBAction)ggPlayTouchUpInside:(id)sender {
    [self configureButtonsEnabled:NO];
    [self animateMainMenuButtonDeselect:^{
        [[AudioController sharedController] gameplay];
        [self hideGameOverView];
    }];
}

#pragma mark - Game Over Main Menu Button

-(void)animateGGMainMenuButtonSelect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ggMMRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.12, 1.12)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ggMMRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.07, 1.07)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ggMMRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ggMMRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)animateGGMainMenuButtonDeselect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.ggMMRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.ggMMRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.ggMMRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.ggMMRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.ggMMRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.ggMMRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.ggMMRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.96, 0.96)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.ggMMRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }];
}

- (IBAction)ggMainMenuSelect:(id)sender {
    [self animateGGMainMenuButtonSelect:nil];
}

- (IBAction)ggMainMenuDeselect:(id)sender {
    [self animateGGMainMenuButtonDeselect:nil];
}

- (IBAction)ggMainMenuTouchUpInside:(id)sender {
    [self configureButtonsEnabled:NO];
    [self animateGGMainMenuButtonDeselect:^{
        self.scene = [GameScene sceneWithSize:self.view.bounds.size];
        
        self.scene.size = self.view.bounds.size;
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        self.scene.viewController = self;
        // Present the scene.
        [(SKView*)self.view presentScene:self.scene];
        self.pauseButton.alpha = 0;
        
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            self.gameOverView.alpha = 0;
        } completion:^(BOOL finished) {
            [[self.gameOverView viewWithTag:kBlurBackgroundViewTag] removeFromSuperview];
            [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
                self.mainMenuView.alpha = 1;
            } completion:^(BOOL finished) {
                [self configureButtonsEnabled:YES];
            }];
        }];
    }];
}

#pragma mark - Game Over Upgrade Button

-(void)animateGGUpgradesButtonSelect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ggUpgradeRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.12, 1.12)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ggUpgradeRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.07, 1.07)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ggUpgradeRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.ggUpgradeRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)animateGGUpgradesButtonDeselect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.ggUpgradeRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.ggUpgradeRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.ggUpgradeRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.ggUpgradeRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.ggUpgradeRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.ggUpgradeRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.ggUpgradeRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.96, 0.96)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.ggUpgradeRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }];
}

- (IBAction)ggUpgradeSelect:(id)sender {
    [self animateGGUpgradesButtonSelect:nil];
}

- (IBAction)ggUpgradeDeselect:(id)sender {
    [self animateGGUpgradesButtonDeselect:nil];
}

- (IBAction)ggUpgradeTouchUpInside:(id)sender {
    [self animateGGUpgradesButtonDeselect:^{
        
    }];
}

#pragma mark - Game Over

-(void)showGameOverView {
    
    UIImageView *blurredBackgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.contentMode = UIViewContentModeBottom;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor clearColor];
        imageView;
    });
    blurredBackgroundImageView.tag = kBlurBackgroundViewTag;
    blurredBackgroundImageView.frame = CGRectMake(blurredBackgroundImageView.frame.origin.x, 0, blurredBackgroundImageView.frame.size.width, blurredBackgroundImageView.frame.size.height);
    UIImage *screenShot = [self.view imageFromScreenShot];
    
    UIColor *blurTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    float blurSaturationDeltaFactor = 0.6;
    float blurRadius = 5;
    
    blurredBackgroundImageView.image = [screenShot applyBlurWithRadius:blurRadius tintColor:blurTintColor saturationDeltaFactor:blurSaturationDeltaFactor maskImage:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.gameOverView addGestureRecognizer:tap];
    
    [self.gameOverView insertSubview:blurredBackgroundImageView atIndex:0];
    self.gameOverView.backgroundColor = [UIColor clearColor];
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        self.gameOverView.alpha = 1;
    } completion:^(BOOL finished) {
        ;
    }];
}

-(void)hideGameOverView {
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        self.gameOverView.alpha = 0;
        self.scene.reset = YES;
        self.scene.paused = NO;
    } completion:^(BOOL finished) {
        [[self.gameOverView viewWithTag:kBlurBackgroundViewTag] removeFromSuperview];
        [self configureButtonsEnabled:YES];
    }];
}

-(void)handleTap:(UITapGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
//        [[AudioController sharedController] gameplay];
//        [self hideGameOverView];
    }
}

#pragma mark - UI Helpers

-(void)configureButtonsEnabled:(BOOL)enabled {
    self.playButton.userInteractionEnabled = self.upgradeButton.userInteractionEnabled = self.highScoreButton.userInteractionEnabled = self.creditsButton.userInteractionEnabled = self.hamburgerButton.userInteractionEnabled =  self.playPausedButton.userInteractionEnabled = self.mainMenuButton.userInteractionEnabled = self.ggPlayButton.userInteractionEnabled = self.ggMainMenuButton.userInteractionEnabled = self.ggUpgradeButton.userInteractionEnabled = enabled;
}


@end
