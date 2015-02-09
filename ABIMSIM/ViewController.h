//
//  ViewController.h
//  ABIMSIM
//

//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@class GameScene;
@class DCRoundSwitch;

@interface ViewController : UIViewController <GKGameCenterControllerDelegate, UIAlertViewDelegate>

#pragma mark - Main Menu

@property (weak, nonatomic) IBOutlet UIView *mainMenuView;
@property (weak, nonatomic) IBOutlet UIImageView *playRing0;
@property (weak, nonatomic) IBOutlet UIImageView *playRing1;
@property (weak, nonatomic) IBOutlet UIImageView *playRing2;
@property (weak, nonatomic) IBOutlet UIImageView *playRing3;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIImageView *hsRing0;
@property (weak, nonatomic) IBOutlet UIImageView *hsRing1;
@property (weak, nonatomic) IBOutlet UIImageView *hsRing2;
@property (weak, nonatomic) IBOutlet UIImageView *hsRing3;
@property (weak, nonatomic) IBOutlet UIButton *highScoreButton;

@property (weak, nonatomic) IBOutlet UIImageView *upgradeRing0;
@property (weak, nonatomic) IBOutlet UIImageView *upgradeRing1;
@property (weak, nonatomic) IBOutlet UIImageView *upgradeRing2;
@property (weak, nonatomic) IBOutlet UIImageView *upgradeRing3;
@property (weak, nonatomic) IBOutlet UIButton *upgradeButton;

@property (weak, nonatomic) IBOutlet UIButton *hamburgerButton;
@property (weak, nonatomic) IBOutlet UIButton *creditsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hamburgerLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hamburgerBottomConstraint;
@property (strong, nonatomic) GameScene *scene;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;

- (IBAction)playSelect:(id)sender;
- (IBAction)playDeselect:(id)sender;
- (IBAction)playTouchUpInside:(id)sender;

- (IBAction)highScoresSelect:(id)sender;
- (IBAction)highScoresDeselect:(id)sender;
- (IBAction)highScoresTouchUpInside:(id)sender;

- (IBAction)upgradesSelect:(id)sender;
- (IBAction)upgradesDeselect:(id)sender;
- (IBAction)upgradesTouchUpInside:(id)sender;

- (IBAction)hamburgerTapped:(id)sender;


#pragma mark - Settings
@property (weak, nonatomic) IBOutlet UIView *settingsContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsContainerTopAlignmentConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsContainerTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsLeadngConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *settingsTopConstraint;
@property (weak, nonatomic) IBOutlet DCRoundSwitch *musicSettingsToggle;
@property (weak, nonatomic) IBOutlet DCRoundSwitch *sfxSettingsToggle;

- (IBAction)twitterTapped:(id)sender;
- (IBAction)facebookTapped:(id)sender;
- (IBAction)resetTapped:(id)sender;

#pragma mark - Paused
@property (weak, nonatomic) IBOutlet UIView *pausedView;
@property (weak, nonatomic) IBOutlet UIImageView *playPausedRing0;
@property (weak, nonatomic) IBOutlet UIImageView *playPausedRing1;
@property (weak, nonatomic) IBOutlet UIImageView *playPausedRing2;
@property (weak, nonatomic) IBOutlet UIImageView *playPausedRing3;
@property (weak, nonatomic) IBOutlet UIButton *playPausedButton;

@property (weak, nonatomic) IBOutlet UIImageView *mmRing0;
@property (weak, nonatomic) IBOutlet UIImageView *mmRing1;
@property (weak, nonatomic) IBOutlet UIImageView *mmRing2;
@property (weak, nonatomic) IBOutlet UIImageView *mmRing3;
@property (weak, nonatomic) IBOutlet UIButton *mainMenuButton;

@property (weak, nonatomic) IBOutlet DCRoundSwitch *musicPausedSwitch;
@property (weak, nonatomic) IBOutlet DCRoundSwitch *sfxPausedSwitch;

- (IBAction)playPausedSelect:(id)sender;
- (IBAction)playPausedDeselect:(id)sender;
- (IBAction)playPausedTouchUpInside:(id)sender;

- (IBAction)mainMenuSelect:(id)sender;
- (IBAction)mainMenuDeselect:(id)sender;
- (IBAction)mainMenuTouchUpInside:(id)sender;

#pragma mark - Game Over
@property (weak, nonatomic) IBOutlet UIView *gameOverView;
@property (weak, nonatomic) IBOutlet UILabel *largeParsecsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *largeParsecsLabelYAlignmentConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *largeParsecsImage;

@property (weak, nonatomic) IBOutlet UILabel *largeXPLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *largeXPLabelYAlignmentConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *largeXPImage;

@property (weak, nonatomic) IBOutlet UIImageView *bonusImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bonusImageTopConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *bonusBubbleOne;
@property (weak, nonatomic) IBOutlet UILabel *bonusLabelOne;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bonusBubbleOneTopConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *bonusBubbleTwo;
@property (weak, nonatomic) IBOutlet UILabel *bonusLabelTwo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bonusBubbleTwoTopConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *bonusBubbleThree;
@property (weak, nonatomic) IBOutlet UILabel *bonusLabelThree;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bonusBubbleThreeTopConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *bonusBubbleFour;
@property (weak, nonatomic) IBOutlet UILabel *bonusLabelFour;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bonusBubbleFourTopConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *rectangleImage;
@property (weak, nonatomic) IBOutlet UILabel *smallParsecsLabel;
@property (weak, nonatomic) IBOutlet UILabel *smallXPLabel;

@property (weak, nonatomic) IBOutlet UIView *gameOverButtonContainer;

@property (weak, nonatomic) IBOutlet UIButton *ggPlayButton;
@property (weak, nonatomic) IBOutlet UIImageView *ggPlayRing0;
@property (weak, nonatomic) IBOutlet UIImageView *ggPlayRing1;
@property (weak, nonatomic) IBOutlet UIImageView *ggPlayRing2;
@property (weak, nonatomic) IBOutlet UIImageView *ggPlayRing3;

@property (weak, nonatomic) IBOutlet UIButton *ggMainMenuButton;
@property (weak, nonatomic) IBOutlet UIImageView *ggMMRing0;
@property (weak, nonatomic) IBOutlet UIImageView *ggMMRing1;
@property (weak, nonatomic) IBOutlet UIImageView *ggMMRing2;
@property (weak, nonatomic) IBOutlet UIImageView *ggMMRing3;

@property (weak, nonatomic) IBOutlet UIButton *ggUpgradeButton;
@property (weak, nonatomic) IBOutlet UIImageView *ggUpgradeRing0;
@property (weak, nonatomic) IBOutlet UIImageView *ggUpgradeRing1;
@property (weak, nonatomic) IBOutlet UIImageView *ggUpgradeRing2;
@property (weak, nonatomic) IBOutlet UIImageView *ggUpgradeRing3;

- (IBAction)ggPlaySelect:(id)sender;
- (IBAction)ggPlayDeselect:(id)sender;
- (IBAction)ggPlayTouchUpInside:(id)sender;

- (IBAction)ggMainMenuSelect:(id)sender;
- (IBAction)ggMainMenuDeselect:(id)sender;
- (IBAction)ggMainMenuTouchUpInside:(id)sender;

- (IBAction)ggUpgradeSelect:(id)sender;
- (IBAction)ggUpgradeDeselect:(id)sender;
- (IBAction)ggUpgradeTouchUpInside:(id)sender;

#pragma mark - Game Play
- (IBAction)pauseButtonTapped:(id)sender;

-(void)showGameOverView;
-(void)showPausedView;
@end

@import Accelerate;
#import <float.h>

@implementation UIImage (Effects)

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}


@end

@implementation UIView (ScreenShot)

- (UIImage *)imageFromScreenShot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        if (self.bounds.size.height != 0 && self.bounds.size.width != 0) {
            [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
        } else {
            NSLog(@"BOUNDS ARE ZERO %@", self);
        }
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

