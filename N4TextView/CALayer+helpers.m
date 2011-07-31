//
//  CALayer+helpers.m
//  N4TextView
//
//  Created by Ignacio Enriquez Gutierrez on 7/7/10.
//  Copyright 2010 Nacho4D. All rights reserved.
//

#import "CALayer+helpers.h"

@implementation CALayer (helpers)

#define kTILT @"tilt"

#pragma mark -
#pragma mark Caret Movement/Animation

- (void)hideAndStopTiltAnimation
{
	[self setOpacity:0.0];

	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self removeAllAnimations];
}

- (void)showAndStartTiltAnimationInPosition:(CGPoint)newPosition
{
	//remove perform request and animations if any
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self removeAllAnimations];
	
	//move
	[CATransaction begin]; 
	[CATransaction setValue: (id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	self.opacity = 1.0;
	self.position = newPosition;
	[CATransaction commit];
	
	//will start tilting
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(startAddTiltAnimation) withObject:nil afterDelay:0.5];
}

- (void)startAddTiltAnimation
{
	CABasicAnimation *tilt;
	tilt = [CABasicAnimation animationWithKeyPath:@"opacity"];
	tilt.duration = 1.0;
	tilt.repeatCount = 1e100f;
	tilt.autoreverses = YES;
	tilt.fromValue = [NSNumber numberWithFloat:1.0];
	tilt.toValue = [NSNumber numberWithFloat:0.0];
	tilt.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	tilt.removedOnCompletion = NO;
	[self addAnimation:tilt forKey:kTILT];
}

@end
