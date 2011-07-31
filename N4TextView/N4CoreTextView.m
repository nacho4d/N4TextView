//
//  N4CoreTextView.m
//  N4TextView
//
//  Created by Guillermo Ignacio Enriquez Gutierrez on 8/18/10.
//  Copyright 2010 Nacho4d. All rights reserved.
//

#import "N4CoreTextView.h"
#import "N4CoreTextViewInternal.h"

@interface N4CoreTextView()
@property (nonatomic, retain) N4CoreTextViewInternal *textView;
@end


@implementation N4CoreTextView
@synthesize textView = _textView;

- (void) _initialize{
	
	[self setAutoresizesSubviews:YES];
	[self setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)]; //unneeded?
	[self setMinimumZoomScale:1.0f];
	[self setMaximumZoomScale:1.0f];
	[self setScrollEnabled:YES];
	[self setClipsToBounds:YES];
	[self setBounces:YES];
	[self setBouncesZoom:NO];
	[self setContentSize:self.bounds.size];
	[self setScrollsToTop:YES];

	//_textView = [[N4CoreTextViewInternal alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	_textView = [[N4CoreTextViewInternal alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 10000)];
	[_textView setParentScrollView:self];
	[self addSubview:_textView];

}

#pragma mark -
#pragma mark Overrides:


- (BOOL) canBecomeFirstResponder{
	return [self.textView canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder{
	return [self.textView becomeFirstResponder];
}

- (BOOL) resignFirstResponder{
	return [self.textView resignFirstResponder];
}

- (id) initWithCoder:(NSCoder *)aDecoder{
	if (self = [super initWithCoder:aDecoder]) {
		[self _initialize];
	}
	return self;
}

- (id) initWithFrame:(CGRect)aFrame{
	if (self = [super initWithFrame:aFrame]) {
		[self _initialize];		
	}
	return self;
}

- (void) dealloc{
	[_textView release];
	[super dealloc];
}

#pragma mark -
#pragma mark -
//TODO: expose text property in N4CoreTextInternal so it can be edited from here.
- (void) setText:(NSString *)text{
	//self.textView.text = text;
}

- (NSString *) text{
	return nil;
	//return (NSString *)(self.textView.text);
}


@end
