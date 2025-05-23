//
//  GameOverView.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/23/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import "GameOverView.h"
#import "GameScene.h"
#import "UIView+Fancy.h"

@implementation GameOverView {
    BOOL killAnimations, showingGameOver, pulsatingUpgrade;
    UILabel *incrementingLabel;
    int totalPointDifferential, currentIncrementingLabelPoints, targetPoints, currentPoints;
    BOOL showingButtons;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

-(void)applicationDidBecomeActive {
    if (showingGameOver) {
    
        if (![self.superview viewWithTag:kBlurBackgroundViewTag]) {
            UIImageView *blurredBackgroundImageView = ({
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.superview.bounds];
                imageView.contentMode = UIViewContentModeBottom;
                imageView.clipsToBounds = YES;
                imageView.backgroundColor = [UIColor clearColor];
                imageView;
            });
            blurredBackgroundImageView.tag = kBlurBackgroundViewTag;
            blurredBackgroundImageView.frame = CGRectMake(blurredBackgroundImageView.frame.origin.x, 0, blurredBackgroundImageView.frame.size.width, blurredBackgroundImageView.frame.size.height);
            blurredBackgroundImageView.alpha = 1;
            UIImage *screenShot = [self.superview imageFromScreenShot];
            
            UIColor *blurTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
            float blurSaturationDeltaFactor = 0.6;
            float blurRadius = 5;
            
            blurredBackgroundImageView.image = [screenShot applyBlurWithRadius:blurRadius tintColor:blurTintColor saturationDeltaFactor:blurSaturationDeltaFactor maskImage:nil];
            
            [self.superview insertSubview:blurredBackgroundImageView belowSubview:self];
        }
        killAnimations = YES;
        [self.superview.layer removeAllAnimations];
        [self showGameOverButtons];
    }
}

-(void)didMoveToSuperview {
    self.ggPlayButton.exclusiveTouch = self.ggUpgradeButton.exclusiveTouch = self.ggMainMenuButton.exclusiveTouch = YES;
    self.bonusLabelOne.layer.borderColor = self.bonusLabelTwo.layer.borderColor = self.bonusLabelThree.layer.borderColor = self.bonusLabelFour.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5].CGColor;
    self.bonusLabelOne.layer.borderWidth = self.bonusLabelTwo.layer.borderWidth = self.bonusLabelThree.layer.borderWidth = self.bonusLabelFour.layer.borderWidth = 0.5;
    self.gameOverLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.gameOverLabel.layer.shadowRadius = 10;
    self.gameOverLabel.layer.shadowOpacity = 0.25;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.rectangleImageWidthConstraint.constant = self.frame.size.width/2;
        self.rectangleSocialImageWidthConstraint.constant = (self.frame.size.width/2) / (320.f/75.f);
        self.smallParsecsLabelHorizonalConstraint.constant = self.smallXPLabelHorizonalConstraint.constant = (self.frame.size.width/2) / (320.f/60.f);
    } else {
        self.rectangleImageWidthConstraint.constant = self.frame.size.width;
        self.rectangleSocialImageWidthConstraint.constant = 75;
        self.rectangleImageYConstraint.constant = self.frame.size.height / 3.64;
        if (self.frame.size.height <= 480) {
            self.gameOverLabelTopConstraint.constant = 10;
            self.gameOverContainerYAlignConstraint.constant = 120;
            self.buttonContainerTopConstraint.constant = 5;
        }
    }
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle.lineHeightMultiple= 1;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 0;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    self.ggUpgradeButton.titleLabel.numberOfLines = 0;
    [self.ggUpgradeButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"UPGRADES" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura-CondensedMedium" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 43 : 25],
                                                                                                                    NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                                    NSParagraphStyleAttributeName: paragraphStyle}] forState:UIControlStateNormal];
    [self.upgradesAvailableLabel setAttributedText:[[NSAttributedString alloc] initWithString:@"UPGRADES" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura-CondensedMedium" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 43 : 25],
                                                                                                                 NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                                 NSParagraphStyleAttributeName: paragraphStyle}] ];
    self.upgradesAvailableLabel.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.upgradesAvailableLabel.layer.shadowRadius = 10.0f;
    self.upgradesAvailableLabel.layer.shadowOpacity = 1.0f;
    self.upgradesAvailableLabel.layer.shadowOffset = CGSizeMake(0, 0);


    NSMutableParagraphStyle *paragraphStyle2 = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle2.lineHeightMultiple= 1;
    paragraphStyle2.alignment = NSTextAlignmentCenter;
    paragraphStyle2.lineSpacing = 0;
    paragraphStyle2.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle2.maximumLineHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 43 : 25;
    self.ggMainMenuButton.titleLabel.numberOfLines = 0;
    [self.ggMainMenuButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"HIGH\nSCORE" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura-CondensedMedium" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 43 : 25],
                                                                                                                  NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                                  NSParagraphStyleAttributeName: paragraphStyle2}] forState:UIControlStateNormal];
    self.ggPlayButton.titleLabel.numberOfLines = 0;
    [self.ggPlayButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"PLAY" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Futura-CondensedMedium" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 93 : 50],
                                                                                                              NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                              NSParagraphStyleAttributeName: paragraphStyle}] forState:UIControlStateNormal];

//    self.largeParsecsImage.layer.shadowColor = self.largeParsecsImage.textColor.CGColor;
//    self.largeParsecsImage.layer.shadowRadius = 10;
//    self.largeParsecsImage.layer.shadowOpacity = 0.25;
    
}
#pragma mark - Game Over Play Button

-(void)animateGGPlayButtonSelect:(void(^)(void))completionBlock {
    [self animateFancySelectWithButton:self.ggPlayButton ring1:self.ggPlayRing0 ring2:self.ggPlayRing1 ring3:self.ggPlayRing2 ring4:self.ggPlayRing3 andCompletion:completionBlock];
}

-(void)animateGGPlayButtonDeselect:(void(^)(void))completionBlock {
    [self animateFancyDeselectWithButton:self.ggPlayButton ring1:self.ggPlayRing0 ring2:self.ggPlayRing1 ring3:self.ggPlayRing2 ring4:self.ggPlayRing3 andCompletion:completionBlock];
}

- (IBAction)ggPlaySelect:(id)sender {
    [self animateGGPlayButtonSelect:nil];
}

- (IBAction)ggPlayDeselect:(id)sender {
    [self animateGGPlayButtonDeselect:nil];
}

- (IBAction)ggPlayTouchUpInside:(id)sender {
    [self configureButtonsEnabled:NO];
    [self animateGGPlayButtonDeselect:^{
        [self.delegate gameOverViewDidSelectButtonType:GameOverViewButtonTypePlay];
    }];
}

#pragma mark High Scores Main Menu Button

-(void)animateGGMainMenuButtonSelect:(void(^)(void))completionBlock {
    [self animateFancySelectWithButton:self.ggMainMenuButton ring1:self.ggMMRing0 ring2:self.ggMMRing1 ring3:self.ggMMRing2 ring4:self.ggMMRing3 andCompletion:completionBlock];
}

-(void)animateGGMainMenuButtonDeselect:(void(^)(void))completionBlock {
    [self animateFancyDeselectWithButton:self.ggMainMenuButton ring1:self.ggMMRing0 ring2:self.ggMMRing1 ring3:self.ggMMRing2 ring4:self.ggMMRing3 andCompletion:completionBlock];
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
        [self.delegate gameOverViewDidSelectButtonType:GameOverViewButtonTypeHighScores];
    }];
}

#pragma mark Game Over Upgrade Button

-(void)animateGGUpgradesButtonSelect:(void(^)(void))completionBlock {
    [self animateFancySelectWithButton:self.ggUpgradeButton ring1:self.ggUpgradeRing0 ring2:self.ggUpgradeRing1 ring3:self.ggUpgradeRing2 ring4:self.ggUpgradeRing3 andCompletion:completionBlock];
}

-(void)animateGGUpgradesButtonDeselect:(void(^)(void))completionBlock {
    [self animateFancyDeselectWithButton:self.ggUpgradeButton ring1:self.ggUpgradeRing0 ring2:self.ggUpgradeRing1 ring3:self.ggUpgradeRing2 ring4:self.ggUpgradeRing3 andCompletion:completionBlock];
}

- (IBAction)ggUpgradeSelect:(id)sender {
    [self animateGGUpgradesButtonSelect:nil];
}

- (IBAction)ggUpgradeDeselect:(id)sender {
    [self animateGGUpgradesButtonDeselect:nil];
}

- (IBAction)ggUpgradeTouchUpInside:(id)sender {
    [self configureButtonsEnabled:NO];
    pulsatingUpgrade = NO;
    [self animateGGUpgradesButtonDeselect:^{
        [self.delegate gameOverViewDidSelectButtonType:GameOverViewButtonTypeUpgrades];
    }];
}

#pragma mark - Social

- (IBAction)facebookTapped:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeFacebook];
        NSString *text = [NSString stringWithFormat:@"I just travelled %@ parsecs through space! Think you can beat me? Check it out: http://bit.ly/parsecs", self.smallParsecsLabel.text];
        [composeController setInitialText:text];
        [composeController addURL: [NSURL URLWithString:
                                    @"http://bit.ly/parsecs"]];
        
        [self.delegate presentViewController:composeController
                                    animated:YES completion:nil];
    } else {
        UIAlertView *alert;
        if ([UIDevice currentDevice].systemVersion.integerValue >= 8) {
            alert = [[UIAlertView alloc] initWithTitle:@"Facebook Unavailable" message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Settings", nil];
            
        } else {
            alert = [[UIAlertView alloc] initWithTitle:@"Facebook Unavailable" message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        }
        [alert show];
    }
}

- (IBAction)twitterTapped:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *composeController = [SLComposeViewController
                                                      composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *text = [NSString stringWithFormat:@"I just travelled %@ parsecs through space! Think you can beat me? Check it out!", self.smallParsecsLabel.text];
        [composeController setInitialText:text];
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

#pragma mark - Game Over

- (IBAction)quitTapped:(id)sender {
    showingGameOver = NO;
    pulsatingUpgrade = NO;
    [self configureButtonsEnabled:NO];
    [self.delegate gameOverViewDidSelectButtonType:GameOverViewButtonTypeMainMenu];
}

-(void)show {
    if (showingGameOver) {
        return;
    }
    showingButtons = NO;
    [self configureButtonsEnabled:NO];
    showingGameOver = YES;
    killAnimations = NO;
    self.rectangleImage.alpha = 0;
    self.rectangleSocialImage.alpha = 0;
    self.smallParsecsLabel.alpha = 0;
    self.smallParsecsImage.alpha = 0;
    self.smallXPLabel.alpha = 0;
    self.smallXPImage.alpha = 0;
    self.verticalDivider.alpha = 0;
    self.horizontalDivider.alpha = 0;
    self.facebookButton.alpha = 0;
    self.twitterButton.alpha = 0;
    self.quitButton.alpha = 0;
    self.gameOverButtonContainer.alpha = 0;
    self.gameOverLabelHorizonalConstraint.constant = 0;
    while ([self.superview viewWithTag:kBlurBackgroundViewTag]) {
        [[self.superview viewWithTag:kBlurBackgroundViewTag] removeFromSuperview];
    }
    UIImageView *blurredBackgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.superview.bounds];
        imageView.contentMode = UIViewContentModeBottom;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor clearColor];
        imageView;
    });
    blurredBackgroundImageView.tag = kBlurBackgroundViewTag;
    blurredBackgroundImageView.frame = CGRectMake(blurredBackgroundImageView.frame.origin.x, 0, blurredBackgroundImageView.frame.size.width, blurredBackgroundImageView.frame.size.height);
    blurredBackgroundImageView.alpha = 0;
    UIImage *screenShot = [self.superview imageFromScreenShot];
    
    UIColor *blurTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    float blurSaturationDeltaFactor = 0.6;
    float blurRadius = 5;
    
    blurredBackgroundImageView.image = [screenShot applyBlurWithRadius:blurRadius tintColor:blurTintColor saturationDeltaFactor:blurSaturationDeltaFactor maskImage:nil];
    
    if (self.gestureRecognizers.count == 0) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
    }
    [self.superview insertSubview:blurredBackgroundImageView belowSubview:self];
    self.backgroundColor = [UIColor clearColor];
    self.largeParsecsLabelYAlignmentConstraint.constant = -30;
    self.largeParsecsLabel.text = @"0";
    [self.largeParsecsLabel sizeToFit];
    
    self.largeXPLabel.text = [NSString stringWithFormat:@"%d",self.delegate.scene.currentLevel];
    self.largeXPLabelYAlignmentConstraint.constant = 40;
    currentPoints = targetPoints = currentIncrementingLabelPoints = totalPointDifferential = 0;
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        self.alpha = 1;
        blurredBackgroundImageView.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished && !killAnimations) {
            [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
                self.largeParsecsImage.alpha = 1;
                self.largeParsecsLabel.alpha = 1;
                self.largeParsecsLabelYAlignmentConstraint.constant = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 40 : 30;
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (finished && !killAnimations) {
                    [self animatePointDifference:self.delegate.scene.currentLevel withIncrementingLabel:self.largeParsecsLabel andCompletionBlock:^{
                        if (!killAnimations) {
                            [UIView animateWithDuration:0.5 delay:0.5 options:0 animations:^{
                                self.largeParsecsImage.alpha = 0;
                                self.largeParsecsLabel.alpha = 0;
                                self.largeParsecsLabelYAlignmentConstraint.constant = -30;
                                [self layoutIfNeeded];
                            } completion:^(BOOL finished) {
                                if (finished && !killAnimations) {
                                    [self animateBonuses];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];
}

-(void)animateBonuses {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self animateBonuses];
        });
        return;
    }

    NSMutableArray *bonusStrings = [NSMutableArray array];
    NSMutableArray *bonusAmounts = [NSMutableArray array];
    NSMutableArray *bonusLengthsToDash = [NSMutableArray array];
    UIFont *boldFont = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 23 :  18];
    UIFont *regularFont = [UIFont fontWithName:@"Futura-CondensedMedium" size:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 23 : 18];
    NSArray *labels = @[self.bonusLabelOne, self.bonusLabelTwo, self.bonusLabelThree, self.bonusLabelFour];
    for (UILabel *label in labels) {
        for (UIView *subview in label.subviews) {
            [subview removeFromSuperview];
        }
    }
//    self.delegate.scene.currentLevel = 3;
//    self.delegate.scene.blackHolesSurvived = 3;
//    self.delegate.scene.bubblesPopped = 3;
//    self.delegate.scene.sunsSurvived = 3;
    if (self.delegate.scene.currentLevel / 10 > 0) {
        [bonusAmounts addObject:@(self.delegate.scene.currentLevel / 10)];
        NSMutableAttributedString *bonusString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"   +%d    %d PARSECS TRAVELLED   ", self.delegate.scene.currentLevel / 10, self.delegate.scene.currentLevel]];
        NSRange rangeToDash;
        rangeToDash.location = 0;
        rangeToDash.length = [bonusString.string rangeOfString:[NSString stringWithFormat:@"   +%d  ", self.delegate.scene.currentLevel / 10]].length;
        
        NSRange remainingRange;
        remainingRange.location = rangeToDash.length;
        remainingRange.length = bonusString.string.length - rangeToDash.length;
        
        [bonusString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:rangeToDash];
        [bonusString addAttribute:NSFontAttributeName value:boldFont range:rangeToDash];
        [bonusString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:211.f/255.f green:12.f/255.f blue:95.f/255.f alpha:1] range:remainingRange];
        [bonusString addAttribute:NSFontAttributeName value:regularFont range:remainingRange];
        
        [bonusStrings addObject:bonusString];
        [bonusLengthsToDash addObject:@(rangeToDash.length)];
    }
    if (self.delegate.scene.bubblesPopped > 0) {
        [bonusAmounts addObject:@(self.delegate.scene.bubblesPopped * 5)];
        NSMutableAttributedString *bonusString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"   +%d    %d ASTEROID BUBBLE POPS SURVIVED   ", self.delegate.scene.bubblesPopped * 5, self.delegate.scene.bubblesPopped]];
        NSRange rangeToDash;
        rangeToDash.location = 0;
        rangeToDash.length = [bonusString.string rangeOfString:[NSString stringWithFormat:@"   +%d  ", self.delegate.scene.bubblesPopped * 5]].length;
        NSRange remainingRange;
        remainingRange.location = rangeToDash.length;
        remainingRange.length = bonusString.string.length - rangeToDash.length;
        
        [bonusString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:rangeToDash];
        [bonusString addAttribute:NSFontAttributeName value:boldFont range:rangeToDash];
        [bonusString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:211.f/255.f green:12.f/255.f blue:95.f/255.f alpha:1] range:remainingRange];
        [bonusString addAttribute:NSFontAttributeName value:regularFont range:remainingRange];
        
        [bonusStrings addObject:bonusString];
        [bonusLengthsToDash addObject:@(rangeToDash.length)];
    }
    if (self.delegate.scene.blackHolesSurvived > 0) {
        [bonusAmounts addObject:@(self.delegate.scene.blackHolesSurvived * 4)];
        NSMutableAttributedString *bonusString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"   +%d    %d BLACK HOLES SURVIVED   ", self.delegate.scene.blackHolesSurvived * 4, self.delegate.scene.blackHolesSurvived]];
        NSRange rangeToDash;
        rangeToDash.location = 0;
        rangeToDash.length = [bonusString.string rangeOfString:[NSString stringWithFormat:@"   +%d  ", self.delegate.scene.blackHolesSurvived * 4]].length;
        NSRange remainingRange;
        remainingRange.location = rangeToDash.length;
        remainingRange.length = bonusString.string.length - rangeToDash.length;
        
        [bonusString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:rangeToDash];
        [bonusString addAttribute:NSFontAttributeName value:boldFont range:rangeToDash];
        [bonusString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:211.f/255.f green:12.f/255.f blue:95.f/255.f alpha:1] range:remainingRange];
        [bonusString addAttribute:NSFontAttributeName value:regularFont range:remainingRange];
        
        [bonusStrings addObject:bonusString];
        [bonusLengthsToDash addObject:@(rangeToDash.length)];
    }
    if (self.delegate.scene.sunsSurvived > 0) {
        [bonusAmounts addObject:@(self.delegate.scene.sunsSurvived * 3)];
        NSMutableAttributedString *bonusString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"   +%d    %d SUNS SURVIVED   ", self.delegate.scene.sunsSurvived * 3, self.delegate.scene.sunsSurvived]];
        NSRange rangeToDash;
        rangeToDash.location = 0;
        rangeToDash.length = [bonusString.string rangeOfString:[NSString stringWithFormat:@"   +%d  ", self.delegate.scene.sunsSurvived * 3]].length;
        NSRange remainingRange;
        remainingRange.location = rangeToDash.length;
        remainingRange.length = bonusString.string.length - rangeToDash.length;
        
        [bonusString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:rangeToDash];
        [bonusString addAttribute:NSFontAttributeName value:boldFont range:rangeToDash];
        [bonusString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:211.f/255.f green:12.f/255.f blue:95.f/255.f alpha:1] range:remainingRange];
        [bonusString addAttribute:NSFontAttributeName value:regularFont range:remainingRange];
        
        [bonusStrings addObject:bonusString];
        [bonusLengthsToDash addObject:@(rangeToDash.length)];
    }
    
    if (bonusAmounts.count) {
        self.bonusBubbleOneTopConstraint.constant = 40;
        self.bonusLabelOne.attributedText = bonusStrings[0];
        [self.bonusLabelOne sizeToFit];
        NSRange rangeToDash;
        rangeToDash.location = 0;
        rangeToDash.length = [bonusLengthsToDash[0] integerValue];
        NSAttributedString *widthString = [bonusStrings[0] attributedSubstringFromRange:rangeToDash];
        CGFloat width = [widthString size].width;
        CGFloat height =[widthString size].height;
        UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(width - 1, 2, 0.5, height-4)];
        divider.backgroundColor =  [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        [self.bonusLabelOne addSubview:divider];
        if (bonusAmounts.count > 1) {
            self.bonusBubbleTwoTopConstraint.constant = 35;
            self.bonusLabelTwo.attributedText = bonusStrings[1];
            [self.bonusLabelTwo sizeToFit];
            NSRange rangeToDash;
            rangeToDash.location = 0;
            rangeToDash.length = [bonusLengthsToDash[1] integerValue];
            NSAttributedString *widthString = [bonusStrings[1] attributedSubstringFromRange:rangeToDash];
            CGFloat width = [widthString size].width;
            CGFloat height =[widthString size].height;
            UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(width - 1, 2, 0.5, height-4)];
            divider.backgroundColor =  [[UIColor whiteColor] colorWithAlphaComponent:0.5];
            [self.bonusLabelTwo addSubview:divider];
            if (bonusAmounts.count > 2) {
                self.bonusBubbleThreeTopConstraint.constant = 35;
                self.bonusLabelThree.attributedText = bonusStrings[2];
                [self.bonusLabelThree sizeToFit];
                NSRange rangeToDash;
                rangeToDash.location = 0;
                rangeToDash.length = [bonusLengthsToDash[2] integerValue];
                NSAttributedString *widthString = [bonusStrings[2] attributedSubstringFromRange:rangeToDash];
                CGFloat width = [widthString size].width;
                CGFloat height =[widthString size].height;
                UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(width - 1, 2, 0.5, height-4)];
                divider.backgroundColor =  [[UIColor whiteColor] colorWithAlphaComponent:0.5];
                [self.bonusLabelThree addSubview:divider];
                if (bonusAmounts.count > 3) {
                    self.bonusBubbleFourTopConstraint.constant = 35;
                    self.bonusLabelFour.attributedText = bonusStrings[3];
                    [self.bonusLabelFour sizeToFit];
                    NSRange rangeToDash;
                    rangeToDash.location = 0;
                    rangeToDash.length = [bonusLengthsToDash[3] integerValue];
                    NSAttributedString *widthString = [bonusStrings[3] attributedSubstringFromRange:rangeToDash];
                    CGFloat width = [widthString size].width;
                    CGFloat height =[widthString size].height;
                    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(width - 1, 2, 0.5, height-4)];
                    divider.backgroundColor =  [[UIColor whiteColor] colorWithAlphaComponent:0.5];
                    [self.bonusLabelFour addSubview:divider];
                }
            }
        }
        self.bonusLabelOne.layer.cornerRadius = self.bonusLabelTwo.layer.cornerRadius = self.bonusLabelThree.layer.cornerRadius = self.bonusLabelFour.layer.cornerRadius = self.bonusLabelOne.frame.size.height/2;

        [self.superview layoutIfNeeded];
    }
    if (bonusAmounts.count && !killAnimations) {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            self.largeXPImage.alpha = 1;
            self.largeXPLabel.alpha = 1;
            self.largeXPLabelYAlignmentConstraint.constant = 100;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (finished && !killAnimations) {
                [UIView animateWithDuration:0.5 animations:^{
                    self.bonusImage.alpha = 1;
                } completion:^(BOOL finished) {
                    if (finished && !killAnimations) {
                        [UIView animateWithDuration:0.5 animations:^{
                            self.bonusLabelOne.alpha = 1;
                            self.bonusBubbleOneTopConstraint.constant = 2;
                            [self.superview layoutIfNeeded];
                            [self animatePointDifference:[bonusAmounts[0] intValue] withIncrementingLabel:self.largeXPLabel andCompletionBlock:^{
                                if (bonusAmounts.count > 1 && !killAnimations) {
                                    [UIView animateWithDuration:0.5 animations:^{
                                        self.bonusLabelTwo.alpha = 1;
                                        self.bonusBubbleTwoTopConstraint.constant = 5;
                                        [self.superview layoutIfNeeded];
                                        [self animatePointDifference:[bonusAmounts[1] intValue] withIncrementingLabel:self.largeXPLabel andCompletionBlock:^{
                                            if (bonusAmounts.count > 2 && !killAnimations) {
                                                [UIView animateWithDuration:0.5 animations:^{
                                                    self.bonusLabelThree.alpha = 1;
                                                    self.bonusBubbleThreeTopConstraint.constant = 5;
                                                    [self.superview layoutIfNeeded];
                                                    [self animatePointDifference:[bonusAmounts[2] intValue] withIncrementingLabel:self.largeXPLabel andCompletionBlock:^{
                                                        if (bonusAmounts.count > 3 && !killAnimations) {
                                                            [UIView animateWithDuration:0.5 animations:^{
                                                                self.bonusLabelFour.alpha = 1;
                                                                self.bonusBubbleFourTopConstraint.constant = 5;
                                                                [self.superview layoutIfNeeded];
                                                                [self animatePointDifference:[bonusAmounts[3] intValue] withIncrementingLabel:self.largeXPLabel andCompletionBlock:^{
                                                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                        [self showGameOverButtons];
                                                                    });
                                                                }];
                                                            }];
                                                        } else {
                                                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                                [self showGameOverButtons];
                                                            });
                                                        }
                                                    }];
                                                }];
                                            } else {
                                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                    [self showGameOverButtons];
                                                });
                                            }
                                        }];
                                    }];
                                } else {
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [self showGameOverButtons];
                                    });
                                }
                            }];
                        }];
                    }
                }];
            }
        }];
    } else {
        [self showGameOverButtons];
    }
}

-(void)showGameOverButtons {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showGameOverButtons];
        });
        return;
    }
    if (showingButtons) {
        return;
    }
    showingButtons = YES;
    int pointsEarned = self.delegate.scene.currentLevel;
    pointsEarned += self.delegate.scene.currentLevel / 10;
    pointsEarned += self.delegate.scene.bubblesPopped * 5;
    pointsEarned += self.delegate.scene.blackHolesSurvived * 4;
    pointsEarned += self.delegate.scene.sunsSurvived * 3;
    
    self.smallXPLabel.text = [NSString stringWithFormat:@"%d",pointsEarned];
    [self.smallXPLabel sizeToFit];
    self.smallParsecsLabel.text = [NSString stringWithFormat:@"%d",self.delegate.scene.currentLevel];
    [self.smallParsecsLabel sizeToFit];
    self.largeParsecsLabelYAlignmentConstraint.constant = -30;
    self.largeXPLabelYAlignmentConstraint.constant = 40;

    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.largeParsecsImage.alpha = 0;
        self.largeParsecsLabel.alpha = 0;
        self.largeXPImage.alpha = 0;
        self.largeXPLabel.alpha = 0;
        self.bonusImage.alpha = 0;
        self.bonusLabelOne.alpha = 0;
        self.bonusLabelTwo.alpha = 0;
        self.bonusLabelThree.alpha = 0;
        self.bonusLabelFour.alpha = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.gameOverLabelHorizonalConstraint.constant = self.frame.size.width/4.f;
            self.rectangleImageHorizontalConstraint.constant = self.frame.size.width/-4.f;
        }
        [self.superview viewWithTag:kBlurBackgroundViewTag].alpha = 1;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.rectangleImage.alpha = 1;
                self.rectangleSocialImage.alpha = 1;
                self.smallParsecsLabel.alpha = 1;
                self.smallParsecsImage.alpha = 1;
                self.smallXPLabel.alpha = 1;
                self.smallXPImage.alpha = 1;
                self.verticalDivider.alpha = 1;
                self.horizontalDivider.alpha = 1;
                self.facebookButton.alpha = 1;
                self.twitterButton.alpha = 1;
                self.quitButton.alpha = 1;
                self.gameOverButtonContainer.alpha = 1;
            } completion:^(BOOL finished) {
                if (finished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.delegate.scene.reset = YES;
                        self.delegate.scene.view.paused = NO;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            self.delegate.scene.view.paused = YES;
                        });
                        [self pulsateUpgradeIfApplicable];
                        [self configureButtonsEnabled:YES];
                    });
                }
            }];
        }
    }];
}

-(void)pulsateUpgradeIfApplicable {
    if ([self upgradeAvailable]) {
        pulsatingUpgrade = YES;
        [self pulsateUpgrade];
    } else {
        pulsatingUpgrade = NO;
    }
}

-(void)pulsateUpgrade {
    __block GameOverView* weakSelf = self;
    if (pulsatingUpgrade) {
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.upgradesAvailableLabel.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.75 animations:^{
                    weakSelf.upgradesAvailableLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    if (finished) {
                        [weakSelf pulsateUpgrade];
                    }
                }];
            }
        }];
    }
}

-(void)stopPulsatingUpgrade {
    pulsatingUpgrade = NO;
}

-(BOOL)upgradeAvailable {
    NSInteger shieldOccurance = [ABIMSIMDefaults integerForKey:kShieldOccuranceLevel];
    NSInteger shieldDurability = [ABIMSIMDefaults integerForKey:kShieldDurabilityLevel];
    NSInteger shieldOnStart = [ABIMSIMDefaults integerForKey:kShieldOnStart];
    NSInteger mineOccurance = [ABIMSIMDefaults integerForKey:kMineOccuranceLevel];
    NSInteger mineBlastSpeed = [ABIMSIMDefaults integerForKey:kMineBlastSpeedLevel];
    NSInteger armoryCapacity = [ABIMSIMDefaults integerForKey:kHolsterCapacity];
    NSInteger armoryCount = [ABIMSIMDefaults integerForKey:kHolsterNukes];
    NSInteger spaceDuckets = [ABIMSIMDefaults integerForKey:kUserDuckets];
    
    if ((mineOccurance == 0 || shieldOccurance == 0) && spaceDuckets >= 10) {
        return true;
    }
    
    if (shieldOnStart == 0 && spaceDuckets >= 100) {
        return true;
    }

    
    if (shieldOccurance < 10 && spaceDuckets >= (shieldOccurance+1)*10) {
        return true;
    }

    
    int shipShieldStrengthCost = (int)(shieldDurability+1)*100;
    switch (shipShieldStrengthCost) {
        case 600:
            shipShieldStrengthCost = 1000;
            break;
        case 700:
            shipShieldStrengthCost = 2000;
            break;
        case 800:
            shipShieldStrengthCost = 3000;
            break;
        case 900:
            shipShieldStrengthCost = 4000;
            break;
        case 1000:
            shipShieldStrengthCost = 5000;
            break;
        default:
            break;
    }
    if (shieldDurability < 10 && spaceDuckets >= shipShieldStrengthCost) {
        return YES;
    }
    
    if (mineOccurance < 10 && spaceDuckets >= (mineOccurance+1)*10) {
        return YES;
    }
    
    if (mineBlastSpeed < 5 && spaceDuckets >= (mineBlastSpeed+1)*20) {
        return YES;
    }
    
    if (armoryCapacity < 10 && spaceDuckets >= (armoryCapacity+1)*100) {
        return YES;
    }
    
    if (armoryCount < armoryCapacity && spaceDuckets >= 5) {
        return YES;
    }
    return false;
}

- (void)animatePointDifference:(int)pointDifference withIncrementingLabel:(UILabel*)label andCompletionBlock:(void (^)(void))completionBlock {
    incrementingLabel = label;
    totalPointDifferential = pointDifference/10.f/3.f;
    if (totalPointDifferential < 1) {
        totalPointDifferential = 1;
    }
    targetPoints = currentPoints + pointDifference;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animatePointChangeWithCompletionBlock:completionBlock];
    });
    
}

- (void)animatePointChangeWithCompletionBlock:(void (^)(void))completionBlock {
    if (killAnimations) {
        return;
    }
    currentPoints+=totalPointDifferential;
    if (currentPoints > targetPoints) {
        currentPoints = targetPoints;
        currentIncrementingLabelPoints = 0;
    }
    incrementingLabel.text = [NSString stringWithFormat:@"%d",currentPoints];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (targetPoints != currentPoints) {
            [self animatePointChangeWithCompletionBlock:completionBlock];
        } else {
            if (completionBlock && !killAnimations) {
                completionBlock();
            }
        }
    });
}

-(void)hide {
    showingGameOver = NO;
    pulsatingUpgrade = NO;
    self.delegate.scene.view.paused = YES;
    [self.delegate.scene configureGestureRecognizers:YES];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
        [self.superview viewWithTag:kBlurBackgroundViewTag].alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self configureButtonsEnabled:YES];
            [[self.superview viewWithTag:kBlurBackgroundViewTag] removeFromSuperview];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate.scene startShipVelocity];
                self.delegate.scene.view.paused = NO;
                self.delegate.scene.gameOver = NO;
            });
        }
    }];
}

-(void)handleTap:(UITapGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized && !killAnimations) {
        killAnimations = YES;
        [self.superview.layer removeAllAnimations];
        [self showGameOverButtons];
    }
}

#pragma mark - UI Helpers

-(void)configureButtonsEnabled:(BOOL)enabled {
    self.ggPlayButton.userInteractionEnabled = self.ggMainMenuButton.userInteractionEnabled = self.ggUpgradeButton.userInteractionEnabled = self.quitButton.enabled = enabled;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
