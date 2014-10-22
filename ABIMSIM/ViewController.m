//
//  ViewController.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/10/14.
//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"
#import <objc/runtime.h>

#define kBlurBackgroundViewTag 777


@implementation ViewController {
    NSMutableArray *hamburgerToXImages;
    NSMutableArray *hamburgerToOriginalImages;
    BOOL showingSettings;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (IBAction)pauseButtonTapped:(id)sender {
    if (self.scene.initialPause) return;
    self.scene.paused = !self.scene.paused;
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
    [self animatePlayButtonDeselect:^{
        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
            self.mainMenuView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.scene transitionFromMainMenu];
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
        self.scene.paused = YES;
        [self presentViewController: gameCenterController animated: YES completion:nil];
    } else {
        [self configureButtonsEnabled:YES];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        self.scene.paused = NO;
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
        self.hamburgerBottomConstraint.constant = self.view.frame.size.height - self.buttonContainerView.frame.origin.y - 62;
        self.hamburgerLeadingConstraint.constant = self.buttonContainerView.frame.origin.x + self.buttonContainerView.frame.size.width - 62;
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
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        showingSettings = NO;
        [self configureButtonsEnabled:YES];
    }];
}


#pragma mark - Show Other Views

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
    }];

}

-(void)handleTap:(UITapGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self hideGameOverView];
    }
}

#pragma mark - UI Helpers

-(void)configureButtonsEnabled:(BOOL)enabled {
    self.playButton.userInteractionEnabled = self.upgradeButton.userInteractionEnabled = self.highScoreButton.userInteractionEnabled = self.creditsButton.userInteractionEnabled = self.hamburgerButton.userInteractionEnabled = enabled;
}
@end
