//
//  DCRoundSwitchOutlineLayer.m
//
//  Created by Patrick Richards on 29/06/11.
//  MIT License.
//
//  http://twitter.com/patr
//  http://domesticcat.com.au/projects
//  http://github.com/domesticcatsoftware/DCRoundSwitch
//

#import "DCRoundSwitchOutlineLayer.h"

@implementation DCRoundSwitchOutlineLayer

- (void)drawInContext:(CGContextRef)context
{
	// calculate the outline clip
	CGContextSaveGState(context);
	UIBezierPath *switchOutline = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bounds.size.height / 2.0];
	CGContextAddPath(context, switchOutline.CGPath);
	CGContextClip(context);

	CGContextSetLineWidth(context, 1);
	UIBezierPath *outlinePath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 1, 1) cornerRadius:(self.bounds.size.height-2) / 2.0];
    UIColor *color;
    if (self.off) {
        color = [UIColor colorWithRed:0.329 green:0.314 blue:0.816 alpha:0.5];
    } else {
        color = [UIColor colorWithWhite:1 alpha:1.0]; // .2 & .4
    }

	CGContextSetStrokeColorWithColor(context, color.CGColor);

	CGContextAddPath(context, outlinePath.CGPath);
	CGContextStrokePath(context);
}

@end
