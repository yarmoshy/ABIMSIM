//
//  AppDelegate.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/10/14.
//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Crashlytics startWithAPIKey:@"066787c672b57a8fd2a11bcf1e72df26be8cbed5"];
    
    [ABIMSIMDefaults registerDefaults:@{kMusicSetting:@(YES),kSFXSetting:@(YES)}];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *loginVC, NSError *error) {
        if ([GKLocalPlayer localPlayer].authenticated) {
            //enable game center
            NSLog(@"authenticated!");
//            [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
//             {
//                 if (error != nil) {
//                     // handle the error.
//                }
//             }];
        } else if (loginVC) {
            NSLog(@"show loginVC");
            [self.window.rootViewController presentViewController:loginVC animated:YES completion:^{
                ;
            }];
            // pause game and present loginVC
        } else {
            NSLog(@"Error: %@", error);
            // disableGameCenter
        }
    };

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
