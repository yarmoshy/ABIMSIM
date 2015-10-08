//
//  SMActivityFeedViewController.m
//  SessionM
//
//  Copyright (c) 2015 SessionM. All rights reserved.
//

#import "SMActivityFeedViewController.h"
#import "SMActivityFeedViewCell.h"
#import "SessionM.h"
#import "SMActivityFeedViewCell.h"

#define CELL_IDENTIFIER @"SMActivityFeedCellIdentifier"

@interface SMActivityFeedViewController() <SMActivityFeedViewCellDelegate>

@end

@implementation SMActivityFeedViewController {
    int scale;
}

- (id)initWithFrame:(CGRect)frame andStyle:(UITableViewStyle)style {
    self = [super init];
    if (self) {
        scale = [UIScreen mainScreen].scale;
        self.view.frame = frame;
        CGRect tableRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        self.tableView = [[UITableView alloc] initWithFrame:tableRect style:style];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = TABLEVIEW_BACKGROUND_COLOR;

        [self.view addSubview:self.tableView];
        self.navigationItem.title = @"Activity Feed";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUpdateMessages) name:SMSessionMDidUpdateMessagesNotification object:nil];
        [self.tableView registerClass:[SMActivityFeedViewCell class] forCellReuseIdentifier:CELL_IDENTIFIER];        
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleUpdateMessages {
    if (!sizingCell) {
        sizingCell = [[SMActivityFeedViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SizingCell"];
        sizingCell.isSizingCell = YES;
    }
    [sizingCell seedMessages:[SessionM sharedInstance].messagesList.copy];
    [self.tableView reloadData];
}

#pragma mark - UIContentContainer

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    SMActivityFeedViewController __weak *weakSelf = self;
    void(^transitionBlock)(id<UIViewControllerTransitionCoordinatorContext>) = ^(id<UIViewControllerTransitionCoordinatorContext> context) {
        weakSelf.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, size.width, size.height);
        [weakSelf.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationNone];
    };
    [coordinator animateAlongsideTransition:transitionBlock completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SessionM sharedInstance].messagesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMActivityFeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    cell.messageData = [self messageDataAtIndexPath:indexPath];
    [cell.messageData notifyPresented];
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = scale;
    cell.delegate = self;
    return cell;
}

static SMActivityFeedViewCell *sizingCell;
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMFeedMessageData *messageData = [self messageDataAtIndexPath:indexPath];
    if (!sizingCell) {
        sizingCell = [[SMActivityFeedViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SizingCell"];
        sizingCell.isSizingCell = YES;
    }
    sizingCell.messageData = messageData;
    return [sizingCell heightForCell];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {    
    SMFeedMessageData *messageData = [self messageDataAtIndexPath:indexPath];
    if (!sizingCell) {
        sizingCell = [[SMActivityFeedViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SizingCell"];
        sizingCell.isSizingCell = YES;
    }
    sizingCell.messageData = messageData;
    return [sizingCell heightForCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SMFeedMessageData *messageData = [self messageDataAtIndexPath:indexPath];
    [messageData notifyTapped];
    [[SessionM sharedInstance] executeMessageAction:messageData];
    [self.tableView reloadData];
}

- (SMFeedMessageData *)messageDataAtIndexPath:(NSIndexPath *)indexPath {
    return [[SessionM sharedInstance].messagesList objectAtIndex:indexPath.row];
}

#pragma mark - SMActivityFeedCellViewDelegate
-(void)reloadCellForFeedMessageData:(SMFeedMessageData *)messageData {
    NSIndexPath *index = [NSIndexPath indexPathForItem:[[SessionM sharedInstance].messagesList indexOfObject:messageData] inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationAutomatic];
}
@end
