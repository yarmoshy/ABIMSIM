//
//  ViewController.m
//  ABIMSIM
//
//  Created by Kevin Yarmosh on 3/10/14.
//  Copyright (c) 2014 Kevin Yarmosh. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"

#define kBlurBackgroundViewTag 777

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
            [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
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


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = NO;
    
    // Create and configure the scene.
    self.scene = [GameScene sceneWithSize:skView.bounds.size];
    
    self.scene.size = skView.bounds.size;
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    self.scene.viewController = self;
    // Present the scene.
    [skView presentScene:self.scene];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Play Button

-(void)animatePlayButtonSelect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.playRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.12, 1.12)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.playRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.07, 1.07)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.playRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.playRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)animatePlayButtonDeselect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.playRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.playRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.playRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.playRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.96, 0.96)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.playRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }];
}

- (IBAction)playSelect:(id)sender {
    [self animatePlayButtonSelect:nil];
}

- (IBAction)playDeselect:(id)sender {
    [self animatePlayButtonDeselect:nil];
}

- (IBAction)playTouchUpInside:(id)sender {
    [self animatePlayButtonDeselect:^{
//        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
//            self.mainMenuView.alpha = 0;
//        } completion:^(BOOL finished) {
//            [self.scene transitionFromMainMenu];
//        }];
    }];
}

#pragma mark - High Scores

-(void)animateHighScoresButtonSelect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.hsRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.12, 1.12)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.hsRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.07, 1.07)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.hsRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:nil];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.hsRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.04, 1.04)];
    } completion:^(BOOL finished) {
        if (completionBlock) {
            completionBlock();
        }
    }];
}

-(void)animateHighScoresButtonDeselect:(void(^)(void))completionBlock {
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.hsRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.hsRing0 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.025 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.hsRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.hsRing1 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.05 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.hsRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.94, 0.95)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.hsRing2 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:nil];
        }
    }];
    [UIView animateWithDuration:0.1 delay:0.075 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseIn animations:^{
        [self.hsRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.96, 0.96)];
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                [self.hsRing3 setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)];
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock();
                }
            }];
        }
    }];
}


- (IBAction)highScoresSelect:(id)sender {
    [self animateHighScoresButtonSelect:nil];
}

- (IBAction)highScoresDeselect:(id)sender {
    [self animateHighScoresButtonDeselect:nil];
}

- (IBAction)highScoresTouchUpInside:(id)sender {
    [self animateHighScoresButtonDeselect:^{
        //        [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        //            self.mainMenuView.alpha = 0;
        //        } completion:^(BOOL finished) {
        //            [self.scene transitionFromMainMenu];
        //        }];
    }];
}

- (IBAction)upgradesTapped:(id)sender {
}

-(void)showGameOverView {
    
    UIImageView *blurredBackgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.contentMode = UIViewContentModeBottom;
        imageView.clipsToBounds = YES;
        imageView.backgroundColor = [UIColor clearColor];
        imageView;
    });
    blurredBackgroundImageView.tag = kBlurBackgroundViewTag;
    blurredBackgroundImageView.frame = CGRectMake(blurredBackgroundImageView.frame.origin.x, 0, blurredBackgroundImageView.frame.size.width, blurredBackgroundImageView.frame.size.height);
    UIImage *screenShot = [self.view imageFromScreenShot];
    
    UIColor *blurTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.3];
    float blurSaturationDeltaFactor = 0.6;
    float blurRadius = 5;
    
    blurredBackgroundImageView.image = [screenShot applyBlurWithRadius:blurRadius tintColor:blurTintColor saturationDeltaFactor:blurSaturationDeltaFactor maskImage:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.gameOverView addGestureRecognizer:tap];
    
    [self.gameOverView insertSubview:blurredBackgroundImageView atIndex:0];
    self.gameOverView.backgroundColor = [UIColor clearColor];
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        self.gameOverView.alpha = 1;
    } completion:^(BOOL finished) {
        ;
    }];
}

-(void)hideGameOverView {
    [UIView animateKeyframesWithDuration:0.5 delay:0 options:0 animations:^{
        self.gameOverView.alpha = 0;
        self.scene.reset = YES;
        self.scene.paused = NO;
    } completion:^(BOOL finished) {
        [[self.gameOverView viewWithTag:kBlurBackgroundViewTag] removeFromSuperview];
    }];

}

-(void)handleTap:(UITapGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self hideGameOverView];
    }
}
@end
