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
#import "SMPortalButton.h"
#import "SessionM.h"

@implementation ViewController {
    NSMutableArray *hamburgerToXImages;
    NSMutableArray *hamburgerToOriginalImages;
    BOOL showingSettings;
    BOOL showingUpgradesFromGameOver;
    SMPortalButton *mainMenuPortalButton, *gameOverPortalButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AudioController sharedController];
//    [ABIMSIMDefaults setInteger:30000 forKey:kUserDuckets];
    
    showingSettings = NO;
    
    UINib * upgradesViewNib = [UINib nibWithNibName:@"UpgradesView" bundle:nil];
    self.upgradesView = [upgradesViewNib instantiateWithOwner:self options:nil][0];
    self.upgradesView.frame = self.view.frame;
    self.upgradesView.delegate = self;
    [self.view addSubview:self.upgradesView];
    
    UINib * mainMenuNib;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        mainMenuNib = [UINib nibWithNibName:@"MainMenuView_iPad" bundle:nil];
    } else {
        mainMenuNib = [UINib nibWithNibName:@"MainMenuView" bundle:nil];
    }
    self.mainMenuView = [mainMenuNib instantiateWithOwner:self options:nil][0];
    self.mainMenuView.frame = self.view.frame;
    self.mainMenuView.delegate = self;
    
    mainMenuPortalButton=[SMPortalButton buttonWithType:UIButtonTypeCustom];
    [mainMenuPortalButton.button setImage:[UIImage imageNamed:@"RewardsBox"] forState:UIControlStateNormal];
    [mainMenuPortalButton sizeToFit];
    CGRect rect = CGRectMake(self.mainMenuView.frame.size.width - mainMenuPortalButton.button.frame.size.width - 10, self.mainMenuView.frame.size.height - mainMenuPortalButton.button.frame.size.height - 10, mainMenuPortalButton.button.frame.size.width, mainMenuPortalButton.button.frame.size.height);
    mainMenuPortalButton.frame = rect;
    [self.mainMenuView addSubview:mainMenuPortalButton];

    [self.view addSubview:self.mainMenuView];
    [self.mainMenuView layoutIfNeeded];
    
    UINib * gameOverViewNib;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        gameOverViewNib = [UINib nibWithNibName:@"GameOverView_iPad" bundle:nil];
    } else {
        gameOverViewNib = [UINib nibWithNibName:@"GameOverView" bundle:nil];
    }
    self.gameOverView = [gameOverViewNib instantiateWithOwner:self options:nil][0];
    self.gameOverView.frame = self.view.frame;
    self.gameOverView.delegate = self;
    
    gameOverPortalButton=[SMPortalButton buttonWithType:UIButtonTypeCustom];
    [gameOverPortalButton.button setImage:[UIImage imageNamed:@"RewardsBox"] forState:UIControlStateNormal];
    [gameOverPortalButton sizeToFit];
    gameOverPortalButton.frame = rect;
    [self.gameOverView addSubview:gameOverPortalButton];

    [self.view insertSubview:self.gameOverView atIndex:1];

    UINib * pausedViewNib;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        pausedViewNib = [UINib nibWithNibName:@"PausedView_iPad" bundle:nil];
    } else {
        pausedViewNib = [UINib nibWithNibName:@"PausedView" bundle:nil];
    }

    self.pausedView = [pausedViewNib instantiateWithOwner:self options:nil][0];
    self.pausedView.frame = self.view.frame;
    self.pausedView.delegate = self;
    [self.view insertSubview:self.pausedView atIndex:2];

    UINib * settingsViewNib = [UINib nibWithNibName:@"SettingsView" bundle:nil];
    self.settingsView = [settingsViewNib instantiateWithOwner:self options:nil][0];
    self.settingsView.delegate = self;
    [self.mainMenuView.settingsContainerView addSubview:self.settingsView];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.mainMenuView.settingsContainerTopAlignmentConstraint.constant = (self.view.frame.size.height - self.mainMenuView.buttonContainerView.frame.origin.y);
    } else {
        self.mainMenuView.settingsContainerTopAlignmentConstraint.constant = -1* (self.view.frame.size.height - self.mainMenuView.buttonContainerView.frame.origin.y);
    }
    self.mainMenuView.settingsContainerTrailingConstraint.constant = self.view.frame.size.width;

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    
    // Create and configure the scene.
    self.scene = [GameScene sceneWithSize:skView.bounds.size];
    
    self.scene.size = skView.bounds.size;
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.scene.viewController = self;
    // Present the scene.
    [skView presentScene:self.scene];
    
    if ([SessionM sharedInstance].user.isOptedOut) {
        mainMenuPortalButton.hidden = gameOverPortalButton.hidden = YES;
    } else if ([SessionM sharedInstance].sessionState != SessionMStateStartedOnline) {
        mainMenuPortalButton.button.enabled = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionMStateChanged:) name:kSessionMStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionMOptOutChanged:) name:kSessionMToggleChanged object:nil];
}

-(void)sessionMStateChanged:(NSNotification*)notif {
    [self setupSessionMButtons:notif];
}

-(void)sessionMOptOutChanged:(NSNotification*)notif {
    [self setupSessionMButtons:notif];
}

-(void)setupSessionMButtons:(NSNotification*)notif {
    if ([SessionM sharedInstance].sessionState != SessionMStateStartedOnline) {
        mainMenuPortalButton.button.enabled = gameOverPortalButton.button.enabled = NO;
    } else {
        mainMenuPortalButton.button.enabled = gameOverPortalButton.button.enabled = YES;
    }
    
    if ([SessionM sharedInstance].user.isOptedOut) {
        mainMenuPortalButton.hidden = gameOverPortalButton.hidden = YES;
    } else {
        mainMenuPortalButton.hidden = gameOverPortalButton.hidden = NO;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Main Menu

-(void)mainMenuViewDidSelectButtonType:(MainMenuViewButtonType)type {
    if (type == MainMenuViewButtonTypeUpgrades) {
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            self.mainMenuView.alpha = 0;
        } completion:^(BOOL finished) {
            [self showUpgradesView];
        }];
    } else if (type == MainMenuViewButtonTypeHighScores) {
        [self showGameCenter];
    } else if (type == MainMenuViewButtonTypePlay) {
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            self.mainMenuView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.scene transitionFromMainMenu];
            [self configureButtonsEnabled:YES];
        }];
    }
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


#pragma mark - Settings

-(void)settingsDidReset {
    self.scene = [GameScene sceneWithSize:self.view.bounds.size];
    self.scene.gameOver = NO;
    self.scene.size = self.view.bounds.size;
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.scene.viewController = self;
    // Present the scene.
    [(SKView*)self.view presentScene:self.scene];
}

-(void)showSettings {
    [self.settingsView showSettings];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        mainMenuPortalButton.alpha = 0;
    } completion:^(BOOL finished) {
        ;
    }];
}

-(void)hideSettings {
    [self.settingsView hideSettings];
    [UIView animateWithDuration:0.25 delay:0.25 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        mainMenuPortalButton.alpha = 1;
    } completion:^(BOOL finished) {
        ;
    }];
}


#pragma mark - Paused View

-(void)pausedViewViewDidSelectButtonType:(PausedViewViewButtonType)type {
    if (type == PausedViewViewButtonTypeMainMenu) {
        self.scene = [GameScene sceneWithSize:self.view.bounds.size];
        self.scene.gameOver = NO;
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
        [self.scene setDefaultValues];
        [self.scene configureGestureRecognizers:YES];
        self.scene.resuming = YES;
        self.scene.gameOver = NO;
        [self.view insertSubview:[self.pausedView viewWithTag:kBlurBackgroundViewTag] atIndex:1];
        
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            self.pausedView.alpha = 0;
        } completion:^(BOOL finished) {
            ;
        }];
        UIImageView *ring3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"Play_3%@", UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"_iPad" : @""]]];
        UIImageView *ring2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"Play_2%@", UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"_iPad" : @""]]];
        UIImageView *ring1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"Play_1%@", UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"_iPad" : @""]]];
        UIImageView *ring0 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"Play_0%@", UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"_iPad" : @""]]];
        __block UILabel *countDownLabel = [[UILabel alloc] init];
        countDownLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 150 : 75];
        countDownLabel.textAlignment = NSTextAlignmentCenter;
        countDownLabel.textColor = [UIColor whiteColor];
        UIView *resumeView = [[UIView alloc] initWithFrame:ring3.frame];
        countDownLabel.frame = resumeView.bounds;
        countDownLabel.contentMode = UIViewContentModeCenter;
        [resumeView addSubview:ring3];
        [resumeView addSubview:ring2];
        [resumeView addSubview:ring1];
        [resumeView addSubview:ring0];
        [resumeView addSubview:countDownLabel];
        ring3.center = ring2.center = ring1.center = ring0.center = countDownLabel.center = CGPointMake(resumeView.frame.size.width/2.f, resumeView.frame.size.height/2.f);
        resumeView.alpha = 0;
        resumeView.center = self.view.center;
        resumeView.userInteractionEnabled = NO;
        [self.view addSubview:resumeView];
        [UIView animateWithDuration:0.25 delay:0.25 options:0 animations:^{
            resumeView.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    countDownLabel.text = @"3";
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        countDownLabel.text = @"2";
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            countDownLabel.text = @"1";
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                countDownLabel.attributedText = [[NSAttributedString alloc] initWithString:@"GO!" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"Futura-CondensedMedium" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 150 : 75],
                                                                                                                               NSForegroundColorAttributeName : [UIColor colorWithRed:131.f/255.f green:216.f/255.f blue:12.f/255.f alpha:1]}];
                                countDownLabel.layer.shadowColor = countDownLabel.textColor.CGColor;
                                countDownLabel.layer.shadowRadius = 10;
                                countDownLabel.layer.shadowOpacity = 0.25;
                            });
                        });
                    });
                });
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
    [self.scene pause];
}

-(void)showPausedView {
    if (self.pausedView.alpha != 0 || self.gameOverView.alpha != 0 || self.mainMenuView.alpha != 0) {
        return;
    }
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
        self.scene.gameOver = NO;
        self.scene.size = self.view.bounds.size;
        self.scene.scaleMode = SKSceneScaleModeAspectFill;
        self.scene.viewController = self;
        // Present the scene.
        [(SKView*)self.view presentScene:self.scene];
        self.pauseButton.alpha = 0;
        
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            self.gameOverView.alpha = 0;
            [self.gameOverView.superview viewWithTag:kBlurBackgroundViewTag].alpha = 0;
        } completion:^(BOOL finished) {
            [[self.gameOverView.superview viewWithTag:kBlurBackgroundViewTag] removeFromSuperview];
            [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
                self.mainMenuView.alpha = 1;
            } completion:^(BOOL finished) {
                [self configureButtonsEnabled:YES];
            }];
        }];
    } else if (type == GameOverViewButtonTypePlay) {
        [[AudioController sharedController] gameplay];
        [self hideGameOverView];
    } else if (type == GameOverViewButtonTypeUpgrades) {
        showingUpgradesFromGameOver = YES;
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            self.gameOverView.alpha = 0;
        } completion:^(BOOL finished) {
            [self showUpgradesView];
        }];
    } else if (type == GameOverViewButtonTypeHighScores) {
        [self showGameCenter];
    }
}

-(void)showGameOverView {
    [self.gameOverView show];
}

-(void)hideGameOverView {
    [self.gameOverView hide];
}

#pragma mark - Upgrades View

-(void)upgradesViewDidSelectBackButton {
    [self hideUpgradesView];
}

-(void)showUpgradesView {
    [self.upgradesView.tableView reloadData];
    [self.upgradesView.tableView setContentOffset:CGPointZero animated:YES];
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        self.upgradesView.alpha = 1;
    } completion:^(BOOL finished) {
        [self configureButtonsEnabled:YES];
    }];
}

-(void)hideUpgradesView {
    if (showingUpgradesFromGameOver) {
        showingUpgradesFromGameOver = NO;
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            self.upgradesView.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
                self.gameOverView.alpha = 1;
            } completion:^(BOOL finished) {
                [self configureButtonsEnabled:YES];
            }];
        }];
        return;
    }
    self.scene = [GameScene sceneWithSize:self.view.bounds.size];
    self.scene.gameOver = NO;
    self.scene.size = self.view.bounds.size;
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.scene.viewController = self;
    // Present the scene.
    [(SKView*)self.view presentScene:self.scene];
    self.pauseButton.alpha = 0;
    
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        self.upgradesView.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            self.mainMenuView.alpha = 1;
        } completion:^(BOOL finished) {
            [self configureButtonsEnabled:YES];
        }];
    }];
}

#pragma mark - UI Helpers

-(void)configureButtonsEnabled:(BOOL)enabled {
    [self.mainMenuView configureButtonsEnabled:enabled];
    [self.gameOverView configureButtonsEnabled:enabled];
    [self.pausedView configureButtonsEnabled:enabled];
}


@end
