//
//  N4LoupeView.h
//  N4TextView
//
//  Created by Ignacio Enriquez Gutierrez on 7/6/10.
//  Copyright 2010 Nacho4D. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface N4LoupeView : UIView
{
@private
	UIView *_magnifyView;
	CGPoint _touchPoint;

	UIImage *_cache;
	UIImage *_maskImage;
	UIImage *_overlayImage;

	bool _animated;
}

- (id)initWithMask:(UIImage *)maskImage overlay:(UIImage *)overlayImage;
- (void)setMagnifyView:(UIView *)magnifyView;

- (void)magnifyPoint:(CGPoint)point;
- (void)magnifyPoint:(CGPoint)point inPosition:(CGPoint)position;
- (void)remove;
@end