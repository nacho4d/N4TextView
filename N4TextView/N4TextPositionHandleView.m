//
//  N4TextPositionHandleView.m
//  N4TextView
//
//  Created by Ignacio Enriquez Gutierrez on 7/24/10.
//  Copyright 2010 Nacho4D. All rights reserved.
//

#import "N4TextPositionHandleView.h"
#import <QuartzCore/QuartzCore.h>

@implementation N4TextPositionHandleView

@synthesize type;

#pragma mark -
#pragma mark Non synthezised property

- (void) setType:(N4TextPositionHandleType)newType{
	
	if (type != newType) {
		type = newType;
		
		UIImage *img;
		if (type == N4TextPositionHandleTypeStart) 
			img = [UIImage imageNamed:@"RTKSelectionHandleStart.png"];
		else 
			img = [UIImage imageNamed:@"RTKSelectionHandleEnd.png"];
		
		[self setImage:img];
		[self setFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
	}
}

#pragma mark -
#pragma mark Initializer

- (id) initWithType:(N4TextPositionHandleType)aType{
	UIImage *img;
	type = aType;
	if (type == N4TextPositionHandleTypeStart) 
		img = [UIImage imageNamed:@"RTKSelectionHandleStart.png"];
	else 
		img = [UIImage imageNamed:@"RTKSelectionHandleEnd.png"];
	
	if (self = [super initWithImage:img]){
		self.bounds = CGRectMake(0, 0, img.size.width, img.size.height);
		self.userInteractionEnabled = YES;
	}
	//self.layer.borderColor = [UIColor redColor].CGColor;
	//self.layer.borderWidth = 1.0;
	return self;
	
}

#pragma mark -
#pragma mark Caret Movement/Animation Methods

- (void) hide{
	[self.layer setOpacity:0.0];
}

- (void) showInPosition:(CGPoint)newPosition{
	
	self.layer.borderColor = [UIColor redColor].CGColor;
	self.layer.borderWidth = 1.0;
	
	[CATransaction begin]; 
	[CATransaction setValue: (id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	self.layer.opacity = 1.0;
	self.layer.position = newPosition;
	
	[CATransaction commit];
}

- (void) setOnTopOfFrame:(CGRect)caretRect{
	//VALUES HERE ARE SET MANUALLY SINCE: frame become 0 when hiding it.
	[self.layer setFrame:CGRectMake(caretRect.origin.x - 19/2, 
							  caretRect.origin.y - caretRect.size.height + 2,
							  19,
							  31)];
}

- (void) setInBottomOfFrame:(CGRect)caretRect{
	[self.layer setFrame:CGRectMake(caretRect.origin.x - 19/2, 
							  caretRect.origin.y + caretRect.size.height - 17,
							  19,
							  37)];
}

- (void) showInCaretRect:(CGRect)rect{
	if (type == N4TextPositionHandleTypeStart) 
		[self setOnTopOfFrame:rect];
	else
		[self setInBottomOfFrame:rect];
}




@end
