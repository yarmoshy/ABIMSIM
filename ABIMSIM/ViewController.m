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
    BOOL showingSettings;
    BOOL showingUpgradesFromGameOver;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AudioController sharedController];
    
    showingSettings = NO;
    
    UINib * upgradesViewNib = [UINib nibWithNibName:@"UpgradesView" bundle:nil];
    self.upgradesView = [upgradesViewNib instantiateWithOwner:self options:nil][0];
    self.upgradesView.frame = self.view.frame;
    self.upgradesView.delegate = self;
    [self.view addSubview:self.upgradesView];
    
    UINib * mainMenuNib = [UINib nibWithNibName:@"MainMenuView" bundle:nil];
    self.mainMenuView = [mainMenuNib instantiateWithOwner:self options:nil][0];
    self.mainMenuView.frame = self.view.frame;
    self.mainMenuView.delegate = self;
    [self.view addSubview:self.mainMenuView];
    [self.mainMenuView layoutIfNeeded];
    
    UINib * gameOverViewNib = [UINib nibWithNibName:@"GameOverView" bundle:nil];
    self.gameOverView = [gameOverViewNib instantiateWithOwner:self options:nil][0];
    self.gameOverView.frame = self.view.frame;
    self.gameOverView.delegate = self;
    [self.view insertSubview:self.gameOverView atIndex:1];

    UINib * pausedViewNib = [UINib nibWithNibName:@"PausedView" bundle:nil];
    self.pausedView = [pausedViewNib instantiateWithOwner:self options:nil][0];
    self.pausedView.frame = self.view.frame;
    self.pausedView.delegate = self;
    [self.view insertSubview:self.pausedView atIndex:2];

    UINib * settingsViewNib = [UINib nibWithNibName:@"SettingsView" bundle:nil];
    self.settingsView = [settingsViewNib instantiateWithOwner:self options:nil][0];
    self.settingsView.delegate = self;
    [self.mainMenuView.settingsContainerView addSubview:self.settingsView];
    
    self.mainMenuView.settingsContainerTopAlignmentConstraint.constant = -1* (self.view.frame.size.height - self.mainMenuView.buttonContainerView.frame.origin.y);
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
}

-(void)hideSettings {
    [self.settingsView hideSettings];
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
        self.scene.resuming = YES;
        self.scene.gameOver = NO;
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
