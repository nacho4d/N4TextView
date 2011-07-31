//
//  CALayer+helpers.h
//  N4TextView
//
//  Created by Ignacio Enriquez Gutierrez on 7/7/10.
//  Copyright 2010 Nacho4D. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer(helpers)

- (void)hideAndStopTiltAnimation;
- (void)showAndStartTiltAnimationInPosition:(CGPoint)newPosition;

@end
