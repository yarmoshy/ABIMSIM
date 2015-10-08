//
//  SMActivityFeedViewCell.m
//  SessionM
//
//  Copyright (c) 2015 SessionM. All rights reserved.
//

#import "SMActivityFeedViewCell.h"

@interface SMActivityFeedViewCell()
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) NSLayoutConstraint *containerViewTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *containerViewBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *containerViewLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *containerViewRightConstraint;

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) NSLayoutConstraint *iconViewTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *iconViewLeadingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *iconViewHeightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *iconViewWidthConstraint;


@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) NSLayoutConstraint *imageViewLeadingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *imageViewTrailingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *imageViewBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *imageViewHeightConstraint;


@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) NSLayoutConstraint *headerLabelTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *headerLabelLeadingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *headerLabelTrailingConstraint;


@property (strong, nonatomic) UILabel *subheaderLabel;
@property (strong, nonatomic) NSLayoutConstraint *subheaderLabelTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *subheaderLabelLeadingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *subheaderLabelTrailingConstraint;


@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) NSLayoutConstraint *descriptionLabelTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *descriptionLabelLeadingConstraint;
@property (strong, nonatomic) NSLayoutConstraint *descriptionLabelTrailingConstraint;


@end


@implementation SMActivityFeedViewCell

@synthesize messageData;
@synthesize iconView;
@synthesize imageView;

static NSMutableDictionary *imageData;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        if (!imageData) {
            imageData = @{}.mutableCopy;
        }
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.containerView = [[UIView alloc] init];
        self.containerView.backgroundColor = CONTAINER_BACKGROUND_COLOR;
        self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.containerView];
        
        self.headerLabel = [UILabel new];
        self.headerLabel.font = [UIFont boldSystemFontOfSize:14];
        self.headerLabel.textColor = HEADER_LABEL_COLOR;
        self.headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.headerLabel];
        
        self.subheaderLabel = [UILabel new];
        self.subheaderLabel.font = [UIFont systemFontOfSize:12];
        self.subheaderLabel.textColor = SUBHEADER_LABEL_COLOR;
        self.subheaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.subheaderLabel];
        
        self.descriptionLabel = [UILabel new];
        self.descriptionLabel.font = [UIFont systemFontOfSize:14];
        self.headerLabel.textColor = DESCRIPTION_LABEL_COLOR;
        self.descriptionLabel.numberOfLines = 0;
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.descriptionLabel];
        
        self.iconView = [UIImageView new];
        self.iconView.backgroundColor = [UIColor clearColor];
        self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.iconView];
        
        self.imageView = [UIImageView new];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.imageView];
        
        [self addConstraints];
        
    }

    return self;
}

-(void)addConstraints {
    self.containerViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.containerView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:CONTAINER_MARGIN];
    self.containerViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.containerView
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:CONTAINER_MARGIN];
    self.containerViewLeftConstraint = [NSLayoutConstraint constraintWithItem:self.containerView
                                                                    attribute:NSLayoutAttributeLeft
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.contentView
                                                                    attribute:NSLayoutAttributeLeft
                                                                   multiplier:1
                                                                     constant:0];
    self.containerViewRightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.containerView
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:0];
    
    self.iconViewTopConstraint = [NSLayoutConstraint constraintWithItem:self.iconView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.contentView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:TILE_MARGIN_TOP + ICON_MARGIN_TOP];
    self.iconViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.iconView
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1
                                                                   constant:TILE_MARGIN_LEFT];
    self.iconViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.iconView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1
                                                                  constant:ICON_LENGTH];
    self.iconViewWidthConstraint = [NSLayoutConstraint constraintWithItem:self.iconView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1
                                                                 constant:ICON_LENGTH];
    
    self.imageViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1
                                                                    constant:TILE_MARGIN_LEFT];
    self.imageViewTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.imageView
                                                                    attribute:NSLayoutAttributeTrailing
                                                                   multiplier:1
                                                                     constant:TILE_MARGIN_RIGHT];
    self.imageViewBottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.imageView
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:TILE_MARGIN_BOTTOM];
    self.imageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.imageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:0];
    
    self.headerLabelTopConstraint = [NSLayoutConstraint constraintWithItem:self.headerLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1
                                                                  constant:TILE_MARGIN_TOP + ICON_MARGIN_TOP];
    self.headerLabelLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.headerLabel
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.iconView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1
                                                                      constant:ICON_MARGIN_RIGHT];
    self.headerLabelTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                      attribute:NSLayoutAttributeTrailing
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.headerLabel
                                                                      attribute:NSLayoutAttributeTrailing
                                                                     multiplier:1
                                                                       constant:TILE_MARGIN_RIGHT];
    
    self.subheaderLabelTopConstraint = [NSLayoutConstraint constraintWithItem:self.subheaderLabel
                                                                    attribute:NSLayoutAttributeTop
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.headerLabel
                                                                    attribute:NSLayoutAttributeBottom
                                                                   multiplier:1
                                                                     constant:HEADER_MARGIN_BOTTOM];
    self.subheaderLabelLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.subheaderLabel
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.headerLabel
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1
                                                                         constant:0];
    self.subheaderLabelTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.headerLabel
                                                                         attribute:NSLayoutAttributeTrailing
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.subheaderLabel
                                                                         attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1
                                                                          constant:0];
    
    self.descriptionLabelTopConstraint = [NSLayoutConstraint constraintWithItem:self.descriptionLabel
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.contentView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:0];
    self.descriptionLabelLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.descriptionLabel
                                                                          attribute:NSLayoutAttributeLeading
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.iconView
                                                                          attribute:NSLayoutAttributeLeading
                                                                         multiplier:1
                                                                           constant:0];
    self.descriptionLabelTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.headerLabel
                                                                           attribute:NSLayoutAttributeTrailing
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.descriptionLabel
                                                                           attribute:NSLayoutAttributeTrailing
                                                                          multiplier:1
                                                                            constant:0];
    
    [self.contentView addConstraints:@[self.containerViewTopConstraint,
                                       self.containerViewLeftConstraint,
                                       self.containerViewRightConstraint,
                                       self.containerViewBottomConstraint,
                                       self.iconViewHeightConstraint,
                                       self.iconViewLeadingConstraint,
                                       self.iconViewTopConstraint,
                                       self.iconViewWidthConstraint,
                                       self.imageViewBottomConstraint,
                                       self.imageViewLeadingConstraint,
                                       self.imageViewTrailingConstraint,
                                       self.imageViewHeightConstraint,
                                       self.headerLabelLeadingConstraint,
                                       self.headerLabelTopConstraint,
                                       self.headerLabelTrailingConstraint,
                                       self.subheaderLabelLeadingConstraint,
                                       self.subheaderLabelTopConstraint,
                                       self.subheaderLabelTrailingConstraint,
                                       self.descriptionLabelLeadingConstraint,
                                       self.descriptionLabelTopConstraint,
                                       self.descriptionLabelTrailingConstraint]];

}

- (void)setMessageData:(SMFeedMessageData *)data {
    messageData = data;
    [self configureView];
}

- (void)configureView {
    self.headerLabel.text = self.messageData.header;
    self.subheaderLabel.text = self.messageData.subheader;
    self.descriptionLabel.text = self.messageData.descriptionText;
    [self.headerLabel sizeToFit];
    [self.subheaderLabel sizeToFit];
    [self.descriptionLabel sizeToFit];
    
    float minHeight = self.iconViewTopConstraint.constant + self.iconViewHeightConstraint.constant + ICON_MARGIN_BOTTOM;
    float otherHeight = self.headerLabelTopConstraint.constant + self.headerLabel.frame.size.height + (self.subheaderLabel.frame.size.height > 0 ? self.subheaderLabelTopConstraint.constant + self.subheaderLabel.frame.size.height : 0) + ICON_MARGIN_BOTTOM;
    self.descriptionLabelTopConstraint.constant = fmaxf(minHeight, otherHeight);
    
    if ([imageData valueForKey:self.messageData.iconURL]) {
        [self.iconView setImage:imageData[self.messageData.iconURL]];
    } else {
        if (self.messageData.iconURL && !self.isSizingCell) {
            [self.iconView setImage:nil];
            __block NSString *bImageURL = self.messageData.iconURL;
            __block UIImageView *bIconView = self.iconView;
            __weak SMActivityFeedViewCell *weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:bImageURL]]];
                if (image) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [imageData setObject:image forKey:bImageURL];
                        [bIconView setImage:imageData[bImageURL]];
                        [weakSelf setNeedsLayout];
                    });
                }
            });
        } else {
            [self.iconView setImage:nil];
        }
    }
    
    if ([imageData valueForKey:self.messageData.imageURL]) {
        [self.imageView setImage:imageData[self.messageData.imageURL]];
    } else {
        if (self.messageData.imageURL && !self.isSizingCell) {
            [self.imageView setImage:nil];
            __block NSString *bImageURL = self.messageData.imageURL;
            __weak SMActivityFeedViewCell *weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:bImageURL]]];
                if (image) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [imageData setObject:image forKey:bImageURL];
                        [weakSelf.delegate reloadCellForFeedMessageData:weakSelf.messageData];
                    });
                }
            });
        } else {
            [self.imageView setImage:nil];
        }
    }
    if (self.imageView.image) {
        self.imageViewHeightConstraint.constant = self.imageView.image.size.height / (self.imageView.image.size.width/([UIScreen mainScreen].applicationFrame.size.width - TILE_MARGIN_RIGHT - TILE_MARGIN_LEFT));
    } else if (self.messageData.imageURL.length) {
        self.imageViewHeightConstraint.constant = 200 / (600/([UIScreen mainScreen].applicationFrame.size.width - TILE_MARGIN_RIGHT - TILE_MARGIN_LEFT));
    } else {
        self.imageViewHeightConstraint.constant = 0;
    }
}

-(CGFloat)heightForCell {
    float topHalf;
    if (self.descriptionLabel.text.length) {
        topHalf = self.descriptionLabelTopConstraint.constant + [self.descriptionLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].applicationFrame.size.width - TILE_MARGIN_RIGHT - TILE_MARGIN_LEFT, MAXFLOAT)].height + DESCRIPTION_MARGIN_BOTTOM;
    } else {
        topHalf = self.iconViewTopConstraint.constant + self.iconViewHeightConstraint.constant;
    }
    float bottomHalf;
    if (self.messageData.imageURL.length) {
        bottomHalf = self.imageViewBottomConstraint.constant + self.imageViewHeightConstraint.constant;
    } else {
        bottomHalf = DESCRIPTION_MARGIN_BOTTOM;
    }
    return topHalf + bottomHalf;
}

-(void)seedMessages:(NSArray *)messageList {
    if (!imageData) {
        imageData = @{}.mutableCopy;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (SMFeedMessageData *message in messageList) {
            if (message.imageURL) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:message.imageURL]]];
                if (image) [imageData setObject:image forKey:message.imageURL];
            }
            if (message.iconURL) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:message.iconURL]]];
                if (image) [imageData setObject:image forKey:message.iconURL];
            }
        }
    });
}
@end
