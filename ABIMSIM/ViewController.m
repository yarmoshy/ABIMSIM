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


@implementation ViewController {
    NSMutableArray *hamburgerToXImages;
    NSMutableArray *hamburgerToOriginalImages;
    BOOL showingSettings, killAnimations;
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
    self.playButton.exclusiveTouch = self.upgradeButton.exclusiveTouch = self.highScoreButton.exclusiveTouch = self.creditsButton.exclusiveTouch = self.hamburgerButton.exclusiveTouch = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupMusicToggle) name:kMusicToggleChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupSFXToggle) name:kSFXToggleChanged object:nil];
    [self setupToggles];
    [self.musicSettingsToggle addTarget:self action:@selector(musicSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    [self.sfxSettingsToggle addTarget:self action:@selector(sfxSwitchToggled:) forControlEvents:UIControlEventValueChanged];
    
    UINib * gameOverViewNib = [UINib nibWithNibName:@"GameOverView" bundle:nil];
    self.gameOverView = [gameOverViewNib instantiateWithOwner:self options:nil][0];
    self.gameOverView.delegate = self;
    [self.view insertSubview:self.gameOverView atIndex:1];

    UINib * pausedViewNib = [UINib nibWithNibName:@"PausedView" bundle:nil];
    self.pausedView = [pausedViewNib instantiateWithOwner:self options:nil][0];
    self.pausedView.delegate = self;
    [self.view insertSubview:self.pausedView atIndex:2];

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
-(void)setupToggles {
    [self setupMusicToggle];
    [self setupSFXToggle];
}

-(void)setupMusicToggle {
    self.musicSettingsToggle.on = [ABIMSIMDefaults boolForKey:kMusicSetting];
}

-(void)setupSFXToggle {
    self.sfxSettingsToggle.on = [ABIMSIMDefaults boolForKey:kSFXSetting];
}

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
    self.musicSettingsToggle.on = toggle.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:kMusicToggleChanged object:nil];
}

-(void)sfxSwitchToggled:(DCRoundSwitch*)toggle {
    [ABIMSIMDefaults setBool:toggle.on forKey:kSFXSetting];
    [ABIMSIMDefaults synchronize];
    self.sfxSettingsToggle.on = toggle.on;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSFXToggleChanged object:nil];
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

#pragma mark - Paused View

-(void)pausedViewViewDidSelectButtonType:(PausedViewViewButtonType)type {
    if (type == PausedViewViewButtonTypeMainMenu) {
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
    } else if (type == PausedViewViewButtonTypePlay) {
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
    }
}

- (IBAction)pauseButtonTapped:(id)sender {
    if (self.scene.initialPause || self.scene.resuming) return;
    self.scene.paused = !self.scene.paused;
}

-(void)showPausedView {
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


#pragma mark - Game Over View

-(void)gameOverViewDidSelectButtonType:(GameOverViewButtonType)type {

    if (type == GameOverViewButtonTypeMainMenu) {
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
    } else if (type == GameOverViewButtonTypePlay) {
        [[AudioController sharedController] gameplay];
        [self hideGameOverView];
    }
}

-(void)showGameOverView {
    [self.gameOverView show];
}

-(void)hideGameOverView {
    [self.gameOverView hide];
}

#pragma mark - UI Helpers

-(void)configureButtonsEnabled:(BOOL)enabled {
    self.playButton.userInteractionEnabled = self.upgradeButton.userInteractionEnabled = self.highScoreButton.userInteractionEnabled = self.creditsButton.userInteractionEnabled = self.hamburgerButton.userInteractionEnabled = enabled;
    [self.gameOverView configureButtonsEnabled:enabled];
    [self.pausedView configureButtonsEnabled:enabled];
}


@end
