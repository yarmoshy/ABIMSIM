//
//  AppDelegate.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/10/14.
//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#import "AppDelegate.h"
//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>
#import "MKStoreKit.h"
#ifndef TARGET_OS_TV
#import "Appirater.h"
#import "SessionM.h"
@interface AppDelegate () <SessionMDelegate>
#else
@interface AppDelegate ()
#endif

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
#ifndef TARGET_OS_TV
    [Appirater setAppId:@"876062426"];
    [Appirater setDaysUntilPrompt:-1];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
#endif
    
//    [Fabric with:@[CrashlyticsKit]];
#ifndef TARGET_OS_TV
    [SessionM sharedInstance].delegate = self;
//    [SessionM sharedInstance].logLevel = SMLogLevelDebug;
    SMStart(@"76a75bec6be6cd72ac61f90cc3ab22651f17641a")
#endif

    [ABIMSIMDefaults registerDefaults:@{kMusicSetting:@(YES),kSFXSetting:@(YES)}];
#ifndef TARGET_OS_TV
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
#endif
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

    [[MKStoreKit sharedKit] startProductRequest];

    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Products available: %@", [[MKStoreKit sharedKit] availableProducts]);
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Purchased/Subscribed to product with id: %@", [note object]);
                                                      if ([[note object] isEqualToString:@"200XP"]) {
                                                          [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets] + 200 forKey:kUserDuckets];
                                                      } else if ([[note object] isEqualToString:@"500XP"]) {
                                                          [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets] + 500 forKey:kUserDuckets];
                                                      } else if ([[note object] isEqualToString:@"750XP"]) {
                                                          [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets] + 750 forKey:kUserDuckets];
                                                      } else if ([[note object] isEqualToString:@"1500XP"]) {
                                                          [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets] + 1500 forKey:kUserDuckets];
                                                      } else if ([[note object] isEqualToString:@"4000XP"]) {
                                                          [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets] + 4000 forKey:kUserDuckets];
                                                      } else if ([[note object] isEqualToString:@"10000XP"]) {
                                                          [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets] + 10000 forKey:kUserDuckets];
                                                      } else if ([[note object] isEqualToString:@"25000XP"]) {
                                                          [ABIMSIMDefaults setInteger:[ABIMSIMDefaults integerForKey:kUserDuckets] + 25000 forKey:kUserDuckets];
                                                      }
                                                      [ABIMSIMDefaults synchronize];
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:kStoreKitPurchaseFinished object:nil];
                                                  }];

    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchaseFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Purchase failed with error: %@", [note object]);
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:kStoreKitPurchaseFinished object:nil];
                                                  }];
#ifndef TARGET_OS_TV
    [Appirater appLaunched:YES];
#endif
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
#ifndef TARGET_OS_TV
    [Appirater appEnteredForeground:YES];
#endif
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#ifndef TARGET_OS_TV
- (void)sessionM: (SessionM *)session didTransitionToState: (SessionMState)state {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSessionMStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSessionMToggleChanged object:nil];
}

-(void)sessionM:(SessionM *)sessionM didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSessionMErrored object:nil userInfo:@{@"error":error}];
}

-(void)sessionM:(SessionM *)sessionM didUpdateUser:(SMUser *)user {
    [[NSNotificationCenter defaultCenter] postNotificationName:kSessionMStateChanged object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSessionMToggleChanged object:nil];
}
#endif

@end
