//
//  SettingsView.h
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/25/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCRoundSwitch, GameScene;

@protocol SettingsViewDelegate

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^)(void))completion;
- (void)settingsDidReset;

@end


@interface SettingsView : UIView
@property (weak, nonatomic) id<SettingsViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLeadngConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTopConstraint;
@property (weak, nonatomic) IBOutlet DCRoundSwitch *musicSettingsToggle;
@property (weak, nonatomic) IBOutlet DCRoundSwitch *sfxSettingsToggle;

- (IBAction)twitterTapped:(id)sender;
- (IBAction)facebookTapped:(id)sender;
- (IBAction)resetTapped:(id)sender;

-(void)showSettings;
-(void)hideSettings;
@end
