//
//  N4LoupeView.m
//  N4TextView
//
//  Created by Ignacio Enriquez Gutierrez on 7/6/10.
//  Copyright 2010 Nacho4D. All rights reserved.
//

#import "N4LoupeView.h"
#import <QuartzCore/QuartzCore.h>

@implementation N4LoupeView

- (void)magnifyPoint:(CGPoint)point
{
	CGPoint p = [_magnifyView convertPoint:point toView:nil];
	[self magnifyPoint:point inPosition:p];
}

- (void)magnifyPoint:(CGPoint)point inPosition:(CGPoint)position
{
	_touchPoint = point;
	self.layer.position = position; //window coordinates
	
	[self setNeedsDisplay];
	
	if (!_animated) {
		_animated = YES;

		[[[UIApplication sharedApplication] keyWindow] addSubview:self];
		
		CABasicAnimation *basicAni = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
		[basicAni setDuration:0.1];
		[basicAni setFromValue:[NSValue valueWithCGSize:CGSizeZero]];
		[basicAni setToValue:[NSValue valueWithCGSize:self.layer.bounds.size]];
		[self.layer addAnimation:basicAni forKey:@"sizeAnimation"];
	}
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	[self removeFromSuperview];
}

- (void)remove
{
	
	CABasicAnimation *basicAni = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
	[basicAni setDuration:0.1];
	[basicAni setToValue:[NSValue valueWithCGSize:CGSizeZero]];
	[basicAni setFromValue:[NSValue valueWithCGSize:self.layer.bounds.size]];
	[basicAni setDelegate:self];
	[self.layer addAnimation:basicAni forKey:@"sizeAnimation2"];
	self.layer.bounds = CGRectMake(self.layer.bounds.origin.x, self.layer.bounds.origin.y, 0, 0);
}

- (id)init
{
	self = [self initWithFrame:CGRectZero];
	if (self) {
		_animated = NO;
	}
	return self;
}

- (id)initWithMask:(UIImage *)maskImage overlay:(UIImage *)overlayImage
{
	if (self = [super initWithFrame:CGRectMake(0.0f, 0.0f, maskImage.size.width, maskImage.size.height)]) {
		self.backgroundColor = [UIColor clearColor];
		_maskImage = [maskImage retain];
		_overlayImage = [overlayImage retain];
		self.layer.anchorPoint = CGPointMake(0.5, 1.0);
	}
	return self;
}

- (void) setMagnifyView:(UIView *)magnifyView
{
	_magnifyView = magnifyView;
}

- (void)dealloc
{
	NSLog(@"dealocating Loupe");
	_cache = nil;
	[_maskImage release];
	[_overlayImage release];
	_magnifyView = nil;
	[super dealloc];
}

- (void)drawRect:(CGRect)rect
{
	/*
	 if(_cache == nil){
	 UIGraphicsBeginImageContext(self.bounds.size);
	 [self.magnifyView.layer renderInContext:UIGraphicsGetCurrentContext()];
	 _cache = [UIGraphicsGetImageFromCurrentImageContext() retain];
	 UIGraphicsEndImageContext();
	 }
	 */

	UIGraphicsBeginImageContext(_magnifyView.bounds.size);
	[_magnifyView.layer renderInContext:UIGraphicsGetCurrentContext()];
	_cache = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	CGImageRef imageRef = [_cache CGImage];
	CGImageRef maskRef = [_maskImage CGImage];
	CGImageRef overlay = [_overlayImage CGImage];
	CGImageRef mask = CGImageMaskCreate(
										CGImageGetWidth(maskRef), 
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef), 
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef), 
										CGImageGetDataProvider(maskRef), 
										NULL, 
										true);
	// Copy a portion of the image around the touch point.
	float scale = 2.0f;
	CGRect box = CGRectMake(
							_touchPoint.x - ( ( _maskImage.size.width / scale ) / 2 ), 
							_touchPoint.y - ( ( _maskImage.size.height / scale ) / 2 ), 
							( _maskImage.size.width / scale),
							( _maskImage.size.height / scale )
							);

	CGImageRef subImage = CGImageCreateWithImageInRect(imageRef, box);

	// Create Mask.
	CGImageRef xMaskedImage = CGImageCreateWithMask(subImage, mask);
	CGImageRelease(mask);
	CGImageRelease(subImage);

	// Draw the image
	// Retrieve the graphics context
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGAffineTransform xform = CGAffineTransformMake(
													1.0,  0.0,
													0.0, -1.0,
													0.0,  0.0);
	CGContextConcatCTM(context, xform);

	CGRect area = CGRectMake(0, 0, _maskImage.size.width, -_maskImage.size.height);

	CGContextDrawImage(context, area, xMaskedImage);
	CGContextDrawImage(context, area, overlay);
	CGImageRelease(xMaskedImage);
}

@end
