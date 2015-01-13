//
//  DCRoundSwitchKnobLayer.m
//
//  Created by Patrick Richards on 29/06/11.
//  MIT License.
//
//  http://twitter.com/patr
//  http://domesticcat.com.au/projects
//  http://github.com/domesticcatsoftware/DCRoundSwitch
//

#import "DCRoundSwitchKnobLayer.h"

CGGradientRef CreateGradientRefWithColors(CGColorSpaceRef colorSpace, CGColorRef startColor, CGColorRef endColor);

@implementation DCRoundSwitchKnobLayer
@synthesize gripped;

- (void)drawInContext:(CGContextRef)context
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGRect knobRect = CGRectInset(self.bounds, 5, 5);
//	CGFloat knobRadius = self.bounds.size.height - 5;

	// knob outline (shadow is drawn in the toggle layer)
    UIColor *color;
    if (self.off) {
        color = [UIColor colorWithRed:0.329 green:0.314 blue:0.816 alpha:0.5];
    } else {
        color = [UIColor colorWithWhite:1 alpha:1.0];
    }

	CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetFillColorWithColor(context, color.CGColor);
	CGContextSetLineWidth(context, 2);
    CGContextFillEllipseInRect (context, knobRect);
//	CGContextStrokeEllipseInRect(context, knobRect);
//	CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 0, NULL);
    CGContextFillPath(context);

	// knob inner gradient
//	CGContextAddEllipseInRect(context, knobRect);
//	CGContextClip(context);
//	CGColorRef knobStartColor = [UIColor colorWithWhite:1 alpha:1.0].CGColor;
//	CGColorRef knobEndColor = (self.gripped) ? [UIColor colorWithWhite:1 alpha:1.0].CGColor : [UIColor colorWithWhite:1 alpha:1.0].CGColor;
//	CGPoint topPoint = CGPointMake(0, 0);
//	CGPoint bottomPoint = CGPointMake(0, knobRadius + 2);
//	CGGradientRef knobGradient = CreateGradientRefWithColors(colorSpace, knobStartColor, knobEndColor);
//	CGContextDrawLinearGradient(context, knobGradient, topPoint, bottomPoint, 0);
//	CGGradientRelease(knobGradient);
//
//	// knob inner highlight
//	CGContextAddEllipseInRect(context, CGRectInset(knobRect, 0.5, 0.5));
//	CGContextAddEllipseInRect(context, CGRectInset(knobRect, 1.5, 1.5));
//	CGContextEOClip(context);
//
//	CGGradientRef knobHighlightGradient = CreateGradientRefWithColors(colorSpace, [UIColor whiteColor].CGColor, [UIColor colorWithWhite:1.0 alpha:1].CGColor);
//	CGContextDrawLinearGradient(context, knobHighlightGradient, topPoint, bottomPoint, 0);
//	CGGradientRelease(knobHighlightGradient);

	CGColorSpaceRelease(colorSpace);
}

CGGradientRef CreateGradientRefWithColors(CGColorSpaceRef colorSpace, CGColorRef startColor, CGColorRef endColor)
{
	CGFloat colorStops[2] = {0.0, 1.0};
	CGColorRef colors[] = {startColor, endColor};
	CFArrayRef colorsArray = CFArrayCreate(NULL, (const void**)colors, sizeof(colors) / sizeof(CGColorRef), &kCFTypeArrayCallBacks);
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colorsArray, colorStops);
	CFRelease(colorsArray);
	return gradient;
}

- (void)setGripped:(BOOL)newGripped
{
	gripped = newGripped;
	[self setNeedsDisplay];
}

@end
