//
//  IAPView.h
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 6/8/15.
//  Copyright (c) 2015 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UpgradeTableViewCell.h"

@interface IAPView : UIView <UpgradeTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *loaderView;
@property (weak, nonatomic) UIViewController *presentingViewController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)backButtonTapped:(id)sender;

@end
