//
//  IAPView.h
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 6/8/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAPView : UIView
@property (weak, nonatomic) IBOutlet UIView *loaderView;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)xp200Tapped:(id)sender;
- (IBAction)xp500Tapped:(id)sender;
- (IBAction)xp750Tapped:(id)sender;
- (IBAction)xp1500Tapped:(id)sender;
- (IBAction)xp4000Tapped:(id)sender;
- (IBAction)xp10000Tapped:(id)sender;
- (IBAction)xp50000Tapped:(id)sender;

@end
