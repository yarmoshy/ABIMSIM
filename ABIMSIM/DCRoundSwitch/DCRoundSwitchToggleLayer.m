//
//  DCRoundSwitchToggleLayer.m
//
//  Created by Patrick Richards on 29/06/11.
//  MIT License.
//
//  http://twitter.com/patr
//  http://domesticcat.com.au/projects
//  http://github.com/domesticcatsoftware/DCRoundSwitch
//

#import "DCRoundSwitchToggleLayer.h"

@implementation DCRoundSwitchToggleLayer
@synthesize onString, offString, onTintColor;
@synthesize drawOnTint;
@synthesize clip;
@synthesize labelFont;

- (id)initWithOnString:(NSString *)anOnString offString:(NSString *)anOffString onTintColor:(UIColor *)anOnTintColor
{
	if ((self = [super init]))
	{
		self.onString = anOnString;
		self.offString = anOffString;
		self.onTintColor = anOnTintColor;
	}

	return self;
}

- (UIFont *)labelFont
{
    return [UIFont fontWithName:@"Voltaire" size:17];
}

- (void)drawInContext:(CGContextRef)context
{
	CGFloat knobRadius = self.bounds.size.height - 2.0;
	CGFloat knobCenter = self.bounds.size.width / 2.0;

	if (self.clip)
	{
		UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(-self.frame.origin.x + 0.5, 0, self.bounds.size.width / 2.0 + self.bounds.size.height / 2.0 - 1.5, self.bounds.size.height) cornerRadius:self.bounds.size.height / 2.0];
		CGContextAddPath(context, bezierPath.CGPath);
		CGContextClip(context);
	}

	// on tint color
	if (self.drawOnTint)
	{
		CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
		CGContextFillRect(context, CGRectMake(0, 0, knobCenter, self.bounds.size.height));
	}

	// off tint color (white)
	CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
	CGContextFillRect(context, CGRectMake(knobCenter, 0, self.bounds.size.width - knobCenter, self.bounds.size.height));

	// strings
	CGFloat textSpaceWidth = (self.bounds.size.width / 2) - (knobRadius / 2);

	UIGraphicsPushContext(context);

	// 'ON' state label (self.onString)
//	CGSize onTextSize = [self.onString sizeWithFont:self.labelFont];
    CGSize onTextSize = [self.onString sizeWithAttributes:@{NSFontAttributeName:self.labelFont}];
	CGPoint onTextPoint = CGPointMake((textSpaceWidth - onTextSize.width) / 2.0 + knobRadius * .15, floorf((self.bounds.size.height - onTextSize.height) / 2.0) + 1.0);
    UIColor *color = [UIColor colorWithWhite:1 alpha:1.0];

	[color set]; // .2 & .4
//	[self.onString drawAtPoint:CGPointMake(onTextPoint.x, onTextPoint.y - 1.0) withFont:self.labelFont];
    [self.onString drawAtPoint:CGPointMake(onTextPoint.x, onTextPoint.y - 1.0) withAttributes:@{NSFontAttributeName:self.labelFont, NSForegroundColorAttributeName:color}];

	[color set];
//	[self.onString drawAtPoint:onTextPoint withFont:self.labelFont];
    [self.onString drawAtPoint:onTextPoint withAttributes:@{NSFontAttributeName:self.labelFont, NSForegroundColorAttributeName:color}];


    color = [UIColor colorWithRed:0.329 green:0.314 blue:0.816 alpha:1];
	// 'OFF' state label (self.offString)
//	CGSize offTextSize = [self.offString sizeWithFont:self.labelFont];
    CGSize offTextSize = [self.offString sizeWithAttributes:@{NSFontAttributeName:self.labelFont}];

	CGPoint offTextPoint = CGPointMake(textSpaceWidth + (textSpaceWidth - offTextSize.width) / 2.0 + knobRadius * .86, floorf((self.bounds.size.height - offTextSize.height) / 2.0) + 1.0);
	[color set];
//	[self.offString drawAtPoint:CGPointMake(offTextPoint.x, offTextPoint.y + 1.0) withFont:self.labelFont];
    [self.offString drawAtPoint:CGPointMake(offTextPoint.x, offTextPoint.y + 1.0) withAttributes:@{NSFontAttributeName:self.labelFont, NSForegroundColorAttributeName:color}];

	[color set];
//	[self.offString drawAtPoint:offTextPoint withFont:self.labelFont];
    [self.offString drawAtPoint:offTextPoint withAttributes:@{NSFontAttributeName:self.labelFont, NSForegroundColorAttributeName:color}];


	UIGraphicsPopContext();
}

@end
