//
//  MainMenuView.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/25/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "MainMenuView.h"
#import "UIView+Fancy.h"
#import "GameScene.h"
#import <ReplayKit/ReplayKit.h>
#import "DCRoundSwitch.h"

@implementation MainMenuView {
    BOOL showingSettings, settingUpRecordToggle;
    NSMutableArray *hamburgerToXImages;
    NSMutableArray *hamburgerToOriginalImages;
    UILabel *autoRecordLabel;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

-(void)didMoveToSuperview {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupAutoRecordToggle) name:kAutoRecordToggleChanged object:nil];

    hamburgerToXImages = [NSMutableArray array];
    hamburgerToOriginalImages = [NSMutableArray array];
    for (int i = 0; i <= 17; i++) {
        [hamburgerToXImages addObject:[UIImage imageNamed:[NSString stringWithFormat:@"HamburgerToClose_%0*d", 3, i]]];
    }
    [hamburgerToXImages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [hamburgerToOriginalImages addObject:obj];
    }];
    self.playButton.exclusiveTouch = self.upgradeButton.exclusiveTouch = self.highScoreButton.exclusiveTouch = self.hamburgerButton.exclusiveTouch = YES;
    
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle.lineHeightMultiple= 1;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.maximumLineHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 43 : 25;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    self.highScoreButton.titleLabel.numberOfLines = 0;
    [self.highScoreButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"HIGH\nSCORES" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura-CondensedMedium" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 43 : 25],
                                                                                                                  NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                                  NSParagraphStyleAttributeName: paragraphStyle}] forState:UIControlStateNormal];
    
    self.upgradeButton.titleLabel.numberOfLines = 0;
    [self.upgradeButton setTitleEdgeInsets:UIEdgeInsetsMake(8.0f, 0.0f, 0.0f, 0.0f)];
    [self.upgradeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"POWER\nUPS" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura-CondensedMedium" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 43 : 25],
                                                                                                                 NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                                 NSParagraphStyleAttributeName: paragraphStyle}] forState:UIControlStateNormal];

    NSMutableParagraphStyle *paragraphStyle2 = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle2.lineHeightMultiple= 1;
    paragraphStyle2.alignment = NSTextAlignmentCenter;
    paragraphStyle2.lineSpacing = 0;
    paragraphStyle2.lineBreakMode = NSLineBreakByWordWrapping;
    self.playButton.titleLabel.numberOfLines = 0;
    [self.playButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"PLAY" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura-CondensedMedium" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 93 : 50],
                                                                                                              NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                              NSParagraphStyleAttributeName: paragraphStyle2}] forState:UIControlStateNormal];

    
    if ([RPScreenRecorder class] && [RPScreenRecorder sharedRecorder].available) {
        settingUpRecordToggle = YES;
        [self setupAutoRecordToggle];
    } else {
        [ABIMSIMDefaults setBool:NO forKey:kAutoRecordingSetting];
        [ABIMSIMDefaults synchronize];
        self.replayContainerView.hidden = YES;
    }
}

#pragma mark - Auto Replay

-(void)setupAutoRecordToggle {
    self.replayRedCircle.hidden = ![ABIMSIMDefaults boolForKey:kAutoRecordingSetting];
    if (!autoRecordLabel) {
        autoRecordLabel = [[UILabel alloc] init];
        autoRecordLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:15];
        autoRecordLabel.textColor = [UIColor whiteColor];
        autoRecordLabel.backgroundColor = [UIColor clearColor];
        autoRecordLabel.numberOfLines = 3;
        [self.replayContainerView addSubview:autoRecordLabel];
    }
    autoRecordLabel.text = [NSString stringWithFormat:@"AUTO\nRECORD\n%@",self.replayRedCircle.hidden ? @"OFF" : @"ON"];
    [autoRecordLabel sizeToFit];
    autoRecordLabel.frame = CGRectMake(60, 2, autoRecordLabel.frame.size.width, autoRecordLabel.frame.size.height);
}

-(void)animateReplayButtonSelect:(void(^)(void))completionBlock {
    [self animateFancySelectWithButton:self.replayButton ring1:self.replayRing0 ring2:self.replayRing1 ring3:self.replayRing2 ring4:nil andCompletion:completionBlock];
}

-(void)animateReplayButtonDeselect:(void(^)(void))completionBlock {
    [self animateFancyDeselectWithButton:self.replayButton ring1:self.replayRing0 ring2:self.replayRing1 ring3:self.replayRing2 ring4:nil andCompletion:completionBlock];
}

- (IBAction)replaySelect:(id)sender {
    [self animateReplayButtonSelect:nil];
}

- (IBAction)replayDeselect:(id)sender {
    [self animateReplayButtonDeselect:nil];
}

- (IBAction)replayTouchUpInside:(id)sender {
    [self animateReplayButtonDeselect:^{
        [ABIMSIMDefaults setBool:![ABIMSIMDefaults boolForKey:kAutoRecordingSetting] forKey:kAutoRecordingSetting];
        [ABIMSIMDefaults synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAutoRecordToggleChanged object:nil];
        
        if ([ABIMSIMDefaults boolForKey:kAutoRecordingSetting] && !settingUpRecordToggle && !((UIViewController*)self.delegate).presentedViewController) {
            UIAlertControllerStyle style = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;
        
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Auto Recording Enabled" message:@"Would you like to record with microphone enabled? (Toggle off and on to change preferences later.)" preferredStyle:style];
            [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ABIMSIMDefaults setBool:YES forKey:kAutoRecordingMicrophoneSetting];
                [ABIMSIMDefaults synchronize];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [ABIMSIMDefaults setBool:NO forKey:kAutoRecordingMicrophoneSetting];
                [ABIMSIMDefaults synchronize];
            }]];
            [((UIViewController*)self.delegate) presentViewController:alert animated:YES completion:nil];
        }
        settingUpRecordToggle = NO;
    }];
}

#pragma mark - Play

-(void)animatePlayButtonSelect:(void(^)(void))completionBlock {
    [self animateFancySelectWithButton:self.playButton ring1:self.playRing0 ring2:self.playRing1 ring3:self.playRing2 ring4:self.playRing3 andCompletion:completionBlock];
}

-(void)animatePlayButtonDeselect:(void(^)(void))completionBlock {
    [self animateFancyDeselectWithButton:self.playButton ring1:self.playRing0 ring2:self.playRing1 ring3:self.playRing2 ring4:self.playRing3 andCompletion:completionBlock];
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
        [self.delegate mainMenuViewDidSelectButtonType:MainMenuViewButtonTypePlay];
    }];
}

#pragma mark - High Scores


-(void)animateHighScoresButtonSelect:(void(^)(void))completionBlock {
    [self animateFancySelectWithButton:self.highScoreButton ring1:self.hsRing0 ring2:self.hsRing1 ring3:self.hsRing2 ring4:self.hsRing3 andCompletion:completionBlock];
}

-(void)animateHighScoresButtonDeselect:(void(^)(void))completionBlock {
    [self animateFancyDeselectWithButton:self.highScoreButton ring1:self.hsRing0 ring2:self.hsRing1 ring3:self.hsRing2 ring4:self.hsRing3 andCompletion:completionBlock];
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
        [self.delegate mainMenuViewDidSelectButtonType:MainMenuViewButtonTypeHighScores];
    }];
}

#pragma mark - Upgrades

-(void)animateUpgradesButtonSelect:(void(^)(void))completionBlock {
    [self animateFancySelectWithButton:self.upgradeButton ring1:self.upgradeRing0 ring2:self.upgradeRing1 ring3:self.upgradeRing2 ring4:self.upgradeRing3 andCompletion:completionBlock];
}

-(void)animateUpgradesButtonDeselect:(void(^)(void))completionBlock {
    [self animateFancyDeselectWithButton:self.upgradeButton ring1:self.upgradeRing0 ring2:self.upgradeRing1 ring3:self.upgradeRing2 ring4:self.upgradeRing3 andCompletion:completionBlock];
}

- (IBAction)upgradesSelect:(id)sender {
    [self animateUpgradesButtonSelect:nil];
}

- (IBAction)upgradesDeselect:(id)sender {
    [self animateUpgradesButtonDeselect:nil];
}

- (IBAction)upgradesTouchUpInside:(id)sender {
    [self animateUpgradesButtonDeselect:^{
        [self.delegate mainMenuViewDidSelectButtonType:MainMenuViewButtonTypeUpgrades];
    }];
}


#pragma mark - Settings

-(void)showSettings {
    [self.delegate showSettings];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.buttonContainerView.alpha = 0;
        self.replayContainerView.alpha = 0;
    } completion:^(BOOL finished) {
        ;
    }];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.settingsContainerTopAlignmentConstraint.constant = self.superview.frame.size.height - self.buttonContainerView.frame.origin.y - self.settingsContainerView.frame.size.height;
            self.settingsContainerTrailingConstraint.constant = self.superview.frame.size.width - self.settingsContainerView.frame.size.width;
            self.hamburgerBottomConstraint.constant = self.settingsContainerView.frame.size.height - self.hamburgerButton.frame.size.height * 1.5;
            self.hamburgerLeadingConstraint.constant = self.settingsContainerView.frame.size.width - 125;
        } else {
            self.settingsContainerTopAlignmentConstraint.constant = -1 * (self.superview.frame.size.height - self.buttonContainerView.frame.origin.y - self.settingsContainerView.frame.size.height);
            self.settingsContainerTrailingConstraint.constant = 0;
            self.hamburgerBottomConstraint.constant = self.settingsContainerView.frame.size.height - self.hamburgerButton.frame.size.height * 1.5;
            self.hamburgerLeadingConstraint.constant = self.settingsContainerView.frame.size.width - 125;// self.buttonContainerView.frame.origin.x + self.buttonContainerView.frame.size.width - 100;
        }
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        showingSettings = YES;
        [self configureButtonsEnabled:YES];
    }];
}

-(void)hideSettings {
    [self.delegate hideSettings];
    [UIView animateWithDuration:0.25 delay:0.3 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.buttonContainerView.alpha = 1;
        self.replayContainerView.alpha = 1;
    } completion:^(BOOL finished) {
        ;
    }];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.settingsContainerTrailingConstraint.constant = self.superview.frame.size.width;
        self.hamburgerBottomConstraint.constant = 10;
        self.hamburgerLeadingConstraint.constant = 10;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.settingsContainerTopAlignmentConstraint.constant = (self.superview.frame.size.height - self.buttonContainerView.frame.origin.y);
        } else {
            self.settingsContainerTopAlignmentConstraint.constant = -1* (self.superview.frame.size.height - self.buttonContainerView.frame.origin.y);
        }
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        showingSettings = NO;
        [self configureButtonsEnabled:YES];
    }];
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
    [self.hamburgerButton.imageView setAnimationDuration:0.5];
    [self.hamburgerButton.imageView setAnimationRepeatCount:1];
    [self.hamburgerButton.imageView startAnimating];
}

-(void)configureButtonsEnabled:(BOOL)enabled {
    self.playButton.userInteractionEnabled = self.highScoreButton.userInteractionEnabled = self.upgradeButton.userInteractionEnabled = self.hamburgerButton.userInteractionEnabled = enabled;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
