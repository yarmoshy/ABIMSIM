//
//  UpgradesView.h
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 4/2/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpgradeTableViewCell.h"

@class GameScene;


@protocol UpgradesViewDelegate

@property (strong, nonatomic) GameScene *scene;

-(void)upgradesViewDidSelectBackButton;

@end

@interface UpgradesView : UIView <UITableViewDataSource, UITableViewDelegate, UpgradeTableViewCellDelegate>
@property (weak, nonatomic) id<UpgradesViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)backButtonTapped:(id)sender;
@end
