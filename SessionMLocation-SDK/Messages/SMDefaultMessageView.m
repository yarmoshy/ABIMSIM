//
//  SMDefaultMessageView.m
//  SessionM
//
//  Copyright (c) 2015 SessionM. All rights reserved.
//

#import "SMDefaultMessageView.h"

#define SM_CLOSE_BUTTON_BASE64_STRING @"iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAMAAABHPGVmAAAAIVBMVEUAAAChoaGZmZmioqKgoKCfn5+hoaGioqKjo6OgoKCioqJv3CNwAAAACnRSTlMA+SMkZGP6YV/6iIxYDwAAAPRJREFUeNrt1UEOwjAUA9E0QNrm/gdmGWAkkD6aVT0XeJI3bimllFJK6Todvf2sH/8Zj7lBgbHNx3/GpEJjLqVmUKGxlJpBhQaUggEFRl055qRCY3UUkNsG5aux3Zqg0BAUGIICQ1BgCAoMQYEhKDAEBYagwBAUGIJyDhiCIhhLEQwohkHFMKjQEJTz1RiK0fp4Q7pifM7VHQOKYFAxDCqGQUUyxhAU/Af+RTDwL4oBRTAEBYagwBAUGIICQ1BgCAoMQYFhKDuMH8reCt1hfFXurdUUGlRgFBSMDQVGQYEBZRlVhQaVZdTaaVDZW0oppZRSukxPOEok8ZVE7P0AAAAASUVORK5CYII="


@interface SMDefaultMessageView()

@property(nonatomic, strong) UIButton *dismissButton;
@property(nonatomic, strong) NSTimer *dismissTimer;
@property(nonatomic, strong) UIViewController *presentingController;
@property(nonatomic, strong) NSMutableArray *constraintsToAdd;
@property(nonatomic) BOOL presentFromTop;
@property(nonatomic) BOOL isFirstLayout;
@property(nonatomic) BOOL shouldPresent;
@property(nonatomic) BOOL shouldDismiss;

@end


@implementation SMDefaultMessageView

- (id)initWithMessageData:(SMMessageData *)data {
    if (self = [super initWithMessageData:data]) {
        self.shouldPresent = YES;
        self.shouldDismiss = NO;

        // Style configuration
        self.presentFromTop = YES;
        self.backgroundColor = [UIColor blackColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        // Initialize subviews
        UIImage *dismissButtonImage = [UIImage imageWithData:[[NSData alloc] initWithBase64Encoding:SM_CLOSE_BUTTON_BASE64_STRING]];
        self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.dismissButton setBackgroundImage:dismissButtonImage forState:UIControlStateNormal];
        [self.dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        self.dismissButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.dismissButton];
        UIImage *iconImage = [UIImage imageNamed: [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIcons"] objectForKey:@"CFBundlePrimaryIcon"] objectForKey:@"CFBundleIconFiles"] lastObject]];
        UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        iconImageView.backgroundColor = [UIColor clearColor];
        iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:iconImageView];

        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = self.messageData.header;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:14];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.numberOfLines = 1;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.minimumScaleFactor = 0.5;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:titleLabel];

        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.text = self.messageData.descriptionText;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont systemFontOfSize:12];
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.numberOfLines = 2;
        messageLabel.adjustsFontSizeToFitWidth = YES;
        messageLabel.minimumScaleFactor = 0.5;
        messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:messageLabel];

        // Horizontal placement constraints
        self.constraintsToAdd = [NSMutableArray array];
        [self.constraintsToAdd addObject:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[iconImageView(>=20,<=40)]-[messageLabel]->=33-|"
                                                                                 options:nil
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(iconImageView, messageLabel)]];
        [self.constraintsToAdd addObject:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[iconImageView]-[titleLabel]"
                                                                                 options:nil
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(iconImageView, titleLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_dismissButton(==25)]-8-|"
                                                                     options:nil
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_dismissButton)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:messageLabel
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];

        // Vertical placement constraints
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[titleLabel]"
                                                                     options:nil
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(titleLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[messageLabel]-8-|"
                                                                     options:nil
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(messageLabel)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_dismissButton(==25)]"
                                                                     options:nil
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_dismissButton)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:iconImageView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0.0]];

        // Size constraints
        [iconImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [messageLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:iconImageView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:iconImageView
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0.0]];
    }

    return self;
}

- (void)layoutSubviews {
    CGFloat frameY;
    CGFloat frameHeight = MAX(ceil(self.presentingController.view.bounds.size.height * 0.125), 72);
    CGFloat offset = 0;

    if (self.presentFromTop) {
        // If presenting from the top, present under the status bar
        if (![UIApplication sharedApplication].isStatusBarHidden) {
            CGRect rotatedStatusBarFrame = [self convertRect:[UIApplication sharedApplication].statusBarFrame fromView:[UIApplication sharedApplication].keyWindow];
            offset += rotatedStatusBarFrame.size.height;
        }

        // Also present under the navigation bar - check if presenting controller has a child navigation controller
        NSUInteger indexOfNavigationController = [self.presentingController.childViewControllers indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            UIViewController *controller = (UIViewController *)obj;
            return [controller isKindOfClass:[UINavigationController class]] && controller.isViewLoaded && controller.view.window && !controller.view.hidden;
        }];

        // Navigation controller was found
        if (indexOfNavigationController != NSNotFound) {
            UINavigationController *navigationController = [self.presentingController.childViewControllers objectAtIndex:indexOfNavigationController];

            // On iPhone devices with iOS 7, the navigation bar's frame is repositioned during rotations
            CGFloat navigationBarCorrection = 0;
            if (!self.isFirstLayout && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && [UIDevice currentDevice].systemVersion.floatValue < 8.0) {
                if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
                    navigationBarCorrection = -12;
                } else {
                    navigationBarCorrection = 12;
                }
            }

            offset += navigationController.navigationBar.bounds.size.height + navigationBarCorrection;
        }

        frameY = self.presentingController.view.bounds.origin.y + offset;
    } else {
        // If presenting from the bottom, present over the tab bar
        if ([self.presentingController isKindOfClass:[UITabBarController class]]) {
            offset += ((UITabBarController *)self.presentingController).tabBar.bounds.size.height;
        }

        frameY = self.presentingController.view.bounds.size.height - frameHeight - offset;
    }

    self.frame = CGRectMake(self.presentingController.view.bounds.origin.x, frameY, self.presentingController.view.bounds.size.width, frameHeight);

    // Only add constraints and animate presentation on the first layout
    if (self.isFirstLayout) {
        // Add any constraints that required frame to be set
        for (id obj in self.constraintsToAdd) {
            if ([obj isKindOfClass:[NSLayoutConstraint class]]) {
                NSLayoutConstraint *constraint = (NSLayoutConstraint *)obj;
                [self addConstraint:constraint];
            } else if ([obj isKindOfClass:[NSArray class]]) {
                NSArray *constraints = (NSArray *)obj;
                [self addConstraints:constraints];
            }
        }

        self.isFirstLayout = NO;
        [self animateForPresentation];
    }

    [super layoutSubviews];
}

- (void)present {
    @synchronized(self) {
        if (!self.shouldPresent) {
            return;
        }
        self.shouldPresent = NO;
    }

    UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (presentingController.presentedViewController) {
        presentingController = presentingController.presentedViewController;
    }

    self.presentingController = presentingController;
    [self.presentingController.view addSubview:self];

    self.isFirstLayout = YES;
    [self setNeedsLayout];
}

- (void)dismiss {
    @synchronized(self) {
        if (!self.shouldDismiss) {
            return;
        }
        self.shouldDismiss = NO;
    }

    [self.dismissTimer invalidate];
    self.dismissTimer = nil;

    [self animateForDismissal];
}

- (void)notifyTapped {
    @synchronized(self) {
        if (!self.shouldDismiss) {
            return;
        }

        [super notifyTapped];
        [self dismiss];
    }
}

- (void)animateForPresentation {
    // Animation: slide in with fade in
    CGFloat yOffscreen;
    if (self.presentFromTop) {
        yOffscreen = -self.frame.size.height;
    } else {
        yOffscreen = [UIScreen mainScreen].applicationFrame.size.height + self.frame.size.height;
    }

    CGRect startFrame = CGRectMake(0, yOffscreen, self.frame.size.width, self.frame.size.height);
    CGRect endFrame = self.frame;
    self.frame = startFrame;
    self.alpha = 0.0;

    [UIView animateWithDuration:0.5
                     animations:^{
                         self.frame = endFrame;
                         self.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self notifyPresented];
                         self.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
                         self.shouldDismiss = YES;
                     }];
}

- (void)animateForDismissal {
    // Animation: fade out in place
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
