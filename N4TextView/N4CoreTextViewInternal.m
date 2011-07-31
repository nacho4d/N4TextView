//
//  N4CoreTextViewInternal.m
//  N4TextView
//
//  Created by Ignacio Enriquez Gutierrez on 7/5/10.
//  Copyright 2010 Nacho4D. All rights reserved.
//


#import <CoreText/CoreText.h>

#import "N4CoreTextViewInternal.h"
#import "N4TextPosition.h"
#import "N4TextRange.h"
#import "NSRangeEntensions.h"
#import "CALayer+helpers.h"
//#import "UIWindow+responder.h"

//Interaction
#import "N4TextPositionHandleView.h"
#import "N4LoupeView.h"


#define INITIAL_HORIZ_OFFSET 3
#define INITIAL_VERT_OFFSET 5

@implementation N4CoreTextViewInternal

@synthesize autocapitalizationType, autocorrectionType;//CORRECTION
@synthesize enablesReturnKeyAutomatically, keyboardAppearance, keyboardType,returnKeyType, secureTextEntry; //KEYBOARD
@synthesize selectedTextRange, markedTextRange; //TEXT ranges
@synthesize markedTextStyle, selectedTextStyle, textStyle; //TEXT  styles
@synthesize tokenizer, inputDelegate, textInputView; //MISC
@synthesize textStorage; //STORAGE

@synthesize parentScrollView = _parentScrollView;

#pragma mark -
#pragma mark Debug

//#define DEBUG

#ifdef DEBUG
//#define DebugLog( s, ... ) NSLog( @"<%s : (%d)> log: %@",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define DebugLog( s, ... ) NSLog( @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog( s, ... ) 
#endif
#define cENDL "\n"
#define TouchesLog( s, ... ) NSLog( @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__] )


#define CGPointUIKit2CT(p) CGPointMake(((p).x) - INITIAL_HORIZ_OFFSET, self.bounds.size.height - ((p).y) - INITIAL_VERT_OFFSET)
#define CGPointCT2UIKit(p) CGPointMake(((p).x) + INITIAL_HORIZ_OFFSET, self.bounds.size.height - ((p).y) - INITIAL_VERT_OFFSET)

- (NSString *)space
{
	NSMutableString *res = [NSMutableString string];
	for (int i = 0; i < spaceNumber; i++) {
		[res appendString:@"    "];
	}
	return res;
}

- (NSString *)pushSpace
{
	spaceNumber++;
	NSMutableString *res = [NSMutableString string];
	for (int i = 0; i < spaceNumber; i++) {
		[res appendString:@"    "];
	}
	return res;
}

- (NSString *)popSpace
{
	NSMutableString *res = [NSMutableString string];
	for (int i = 0; i < spaceNumber; i++) {
		[res appendString:@"    "];
	}
	spaceNumber--;
	return res;
}

#pragma mark -
#pragma mark Not synthesized properties

- (void) setTextStyle:(NSDictionary *)newTextStyle
{
	if (textStyle != newTextStyle) {
		[textStyle release];
		textStyle = [newTextStyle copy];
		
		//update font metrics:
		CTFontRef ctfont = (CTFontRef) [newTextStyle objectForKey:(NSString *) kCTFontAttributeName];
		if (ctfont) {

			_fontAscent = CTFontGetAscent(ctfont);
			_fontDescent = CTFontGetDescent(ctfont);
			_fontLeading = CTFontGetLeading(ctfont);
			_fontHeight = _fontAscent + _fontDescent + _fontLeading;
		}else {
			UIFont *uifont = (UIFont *)[newTextStyle objectForKey:UITextInputTextFontKey];
			if (uifont) {
				_fontAscent = uifont.ascender;
				_fontDescent = uifont.descender;
				_fontLeading = uifont.leading;
				_fontHeight = _fontAscent + _fontDescent + _fontLeading;
			}
		}
		[self setNeedsDisplay];
	}
}

- (void) setSelectedTextStyle:(NSDictionary *)newSelectedStyle
{
	if (selectedTextStyle != newSelectedStyle) {
		
		[selectedTextStyle release];
		if ([newSelectedStyle objectForKey:UITextInputTextFontKey] || 
			[newSelectedStyle objectForKey:(NSString *)kCTFontAttributeName] ) {
			//In this implementation text size has to be the same for the hole text
			NSMutableDictionary *mnewSelectedStyle = [newSelectedStyle mutableCopy];
			[mnewSelectedStyle removeObjectForKey:UITextInputTextFontKey];
			[mnewSelectedStyle removeObjectForKey:(NSString *)kCTFontAttributeName];
			selectedTextStyle = mnewSelectedStyle;
			
		}else {
			selectedTextStyle = [newSelectedStyle copy];
		}
		[self setNeedsDisplay];
	}
}

- (NSString *) text
{
	return  [NSString stringWithString:(NSString *)textStorage];
}

- (void) setText:(NSString *)newText
{
	textStorage = [newText mutableCopy];
	[self setNeedsDisplay];
}


#pragma mark -
#pragma mark Helpers

+ (NSDictionary *) normalTextDefaultAttributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[UIColor whiteColor], UITextInputTextBackgroundColorKey,
			[UIColor blueColor], UITextInputTextColorKey,
			//[UIFont fontWithName:@"Trebuchet MS" size:14], UITextInputTextFontKey,
			CTFontCreateWithName(CFSTR("Trebuchet MS"), 14, NULL), (NSString *)kCTFontAttributeName,
			[UIColor blueColor].CGColor, (NSString *)kCTForegroundColorAttributeName,
			nil];
}

+ (NSDictionary *) selectedTextDefaultAttributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[UIColor yellowColor], UITextInputTextBackgroundColorKey,
			[UIColor blackColor], UITextInputTextColorKey,
			//[UIFont fontWithName:@"Trebuchet MS" size:14], UITextInputTextFontKey,
			//[UIFont systemFontOfSize:14], UITextInputTextFontKey,
			CTFontCreateWithName(CFSTR("Trebuchet MS"), 14, NULL), (NSString *)kCTFontAttributeName,
			nil];
}

+ (NSDictionary *) markedTextDefaultAttributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[UIColor cyanColor], UITextInputTextBackgroundColorKey,
			[UIColor blueColor], UITextInputTextColorKey,
			
			//[UIFont fontWithName:@"Trebuchet MS" size:14], UITextInputTextFontKey,
			//[UIColor yellowColor], UITextInputTextBackgroundColorKey,
			//[UIColor redColor], UITextInputTextColorKey,
			CTFontCreateWithName(CFSTR("Trebuchet MS"), 14, NULL), (NSString *)kCTFontAttributeName,
			//[UIColor redColor].CGColor, (NSString *)kCTForegroundColorAttributeName,
			//(id)([UIColor blueColor].CGColor), (NSString *)kCTUnderlineColorAttributeName,
			//kCTUnderlinePatternSolid, (NSString *)kCTUnderlineStyleAttributeName,
			//[UIColor redColor].CGColor, (NSString *)kCTForegroundColorAttributeName,
			nil];
}

#pragma mark -
#pragma mark Privates

- (CTLineRef) _getCTLineContainingPosition:(NSUInteger)position 
								   inRange:(NSRange)range
								 lineIndex:(NSUInteger *)lineIndex{
	
	CFArrayRef lines = CTFrameGetLines(_frameRef);
	CTLineRef line = NULL;
	uint j = range.location;
	for (; j < range.location + range.length; j++) {
		line = CFArrayGetValueAtIndex(lines, j);
		CFRange lineRange = CTLineGetStringRange(line);
		if (lineRange.location <= position && position <= lineRange.location + lineRange.length)
			break;
	}
	if (lineIndex != NULL) *lineIndex = j;
	
	return line;
}



#pragma mark -
#pragma mark User Interaction : Helpers & Selection

- (void) _initMarkedLayersIfNeeded{
	//BACKGROUND COLOR:
	//[UIColor colorWithRed:0.0078 green:0.3386987 blue:0.6502495 alpha:0.201572/2]
	//BORDER COLOR:
	//[UIColor colorWithRed:0.0078 green:0.3386987 blue:0.6502495 alpha:0.201572]
	
	if (!_markedFirstLineLayer) {
		_markedFirstLineLayer = [CALayer layer];
		[_markedFirstLineLayer setBackgroundColor:[UIColor colorWithRed:0.0078 green:0.3386987 blue:0.6502495 alpha:0.201572/2].CGColor];
		[_markedFirstLineLayer setBorderColor:[UIColor redColor].CGColor];
		//[_markedFirstLineLayer setBorderColor:[UIColor colorWithRed:0.0078 green:0.3386987 blue:0.6502495 alpha:0.201572].CGColor];
		[_markedFirstLineLayer setBorderWidth:1.0];
		[_markedFirstLineLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
		[_markedFirstLineLayer setPosition:CGPointZero];
		[_markedFirstLineLayer setFrame:CGRectMake(0, 0, 3, _fontHeight)];
		[self.layer addSublayer:_markedFirstLineLayer];
	}
	if (!_markedMiddleLinesLayer) {
		_markedMiddleLinesLayer = [CALayer layer];
		[_markedMiddleLinesLayer setBackgroundColor:[UIColor colorWithRed:0.0078 green:0.3386987 blue:0.6502495 alpha:0.201572/2].CGColor];
		[_markedMiddleLinesLayer setBorderColor:[UIColor colorWithRed:0.0078 green:0.3386987 blue:0.6502495 alpha:0.201572].CGColor];
		[_markedMiddleLinesLayer setBorderWidth:1.0];
		[_markedMiddleLinesLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
		[_markedMiddleLinesLayer setPosition:CGPointZero];
		[_markedMiddleLinesLayer setFrame:CGRectMake(0, 0, 3, _fontHeight)];
		[self.layer addSublayer:_markedMiddleLinesLayer];
	}
	if (!_markedLastLineLayer) {
		_markedLastLineLayer = [CALayer layer];
		[_markedLastLineLayer setBackgroundColor:[UIColor colorWithRed:0.0078 green:0.3386987 blue:0.6502495 alpha:0.201572/2].CGColor];
		[_markedLastLineLayer setBorderColor:[UIColor blackColor].CGColor];
		//[_markedLastLineLayer setBorderColor:[UIColor colorWithRed:0.0078 green:0.3386987 blue:0.6502495 alpha:0.201572].CGColor];
		[_markedLastLineLayer setBorderWidth:1.0];
		[_markedLastLineLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
		[_markedLastLineLayer setPosition:CGPointZero];
		[_markedLastLineLayer setFrame:CGRectMake(0, 0, 3, _fontHeight)];
		[self.layer addSublayer:_markedLastLineLayer];
	}
	
}

- (void) _initSelectionLayersIfNeeded{
	//SELECTED RANGE COLOR: ORIGINAL COLOR IN THE SIMULATOR: 
	//RGBA(0.0078, 0.3386987, 0.6502495, 0.201572) USE THIS!
	//or RGBA(2,86, 166, 20%)
	//alternative2: RGBA(0.0078, 0.29995329, 0.6110079, 0.201572)
	
	if (!_selectionFirstLineLayer) {
		_selectionFirstLineLayer = [CALayer layer];
		[_selectionFirstLineLayer setBackgroundColor:[UIColor colorWithRed:0.0078 green:0.3386987 blue:0.6502495 alpha:0.201572].CGColor];
		[_selectionFirstLineLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
		[_selectionFirstLineLayer setPosition:CGPointZero];
		[_selectionFirstLineLayer setFrame:CGRectMake(0, 0, 3, _fontHeight)];
		[self.layer addSublayer:_selectionFirstLineLayer];
	}
	if (!_selectionLastLineLayer) {
		_selectionLastLineLayer = [CALayer layer];
		[_selectionLastLineLayer setBackgroundColor:[UIColor colorWithRed:0.0078 green:0.3386987 blue:0.6502495 alpha:0.201572].CGColor];
		[_selectionLastLineLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
		[_selectionLastLineLayer setPosition:CGPointZero];
		[_selectionLastLineLayer setFrame:CGRectMake(0, 0, 3, _fontHeight)];
		[self.layer addSublayer:_selectionLastLineLayer];
	}
	if (!_selectionMiddleLinesLayer) {
		_selectionMiddleLinesLayer = [CALayer layer];
		[_selectionMiddleLinesLayer setBackgroundColor:[UIColor colorWithRed:0.0078 green:0.3386987 blue:0.6502495 alpha:0.201572].CGColor];
		[_selectionMiddleLinesLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
		[_selectionMiddleLinesLayer setPosition:CGPointZero];
		[_selectionMiddleLinesLayer setFrame:CGRectMake(0, 0, 3, _fontHeight)];
		[self.layer addSublayer:_selectionMiddleLinesLayer];
	}
	if (!_selectionHandlerStartView) {
		_selectionHandlerStartView = [[N4TextPositionHandleView alloc] initWithType:N4TextPositionHandleTypeStart];
		UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_dragHandler:)];
		[_selectionHandlerStartView addGestureRecognizer:recognizer];
		[recognizer release];
		[self addSubview:_selectionHandlerStartView];
		
	}
	if (!_selectionHandlerEndView) {
		_selectionHandlerEndView = [[N4TextPositionHandleView alloc] initWithType:N4TextPositionHandleTypeEnd];
		UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_dragHandler:)];
		[_selectionHandlerEndView addGestureRecognizer:recognizer];
		[recognizer release];
		[self addSubview:_selectionHandlerEndView];
	}
	
}

- (void) _initCaretLayerIfNeeded{
	if (!_caretLayer){
		_caretLayer = [CALayer layer];
		//THIS IS THE COLOR OF THE ORIGINAL CARET IN THE SIMULATOR
		//RGBA(0.25882, 0.4196078, 0.9490196, 1.0)
		//or RGB(66, 107, 242, 100%)
		UIColor *caretColor = [UIColor colorWithRed:0.25882 green:0.4196078 blue:0.9490196 alpha:1.0];
		[_caretLayer setBackgroundColor:caretColor.CGColor];
		[_caretLayer setAnchorPoint:CGPointMake(0.0, 0.0)];
		[_caretLayer setPosition:CGPointZero];
		[_caretLayer setFrame:CGRectMake(0,0,3, _fontHeight)];
		[self.layer addSublayer:_caretLayer];
	}
}

- (void) _hideSelectionRange{
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);
	
	//Hide caret:
	[_caretLayer hideAndStopTiltAnimation];
	
	
	//Hide selected range:
	[CATransaction begin]; 
	[CATransaction setValue: (id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	[_selectionFirstLineLayer setFrame:CGRectZero];
	[_selectionMiddleLinesLayer setFrame:CGRectZero];
	[_selectionLastLineLayer setFrame:CGRectZero];
	
	[_selectionHandlerStartView setFrame:CGRectZero];
	[_selectionHandlerEndView setFrame:CGRectZero];
	
	[CATransaction commit];
	
	DebugLog(@"%@%s - ends", [self popSpace], _cmd);
}

- (void) _drawSelectionRange{
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);
	if (self.selectedTextRange.isEmpty) {	

		//Draw caret:
		[self _initCaretLayerIfNeeded];
		CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.start];
		[_caretLayer showAndStartTiltAnimationInPosition:caretRect.origin];
		
		//Hide selected range:
		[CATransaction begin]; 
		[CATransaction setValue: (id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		[_selectionFirstLineLayer setFrame:CGRectZero];
		[_selectionMiddleLinesLayer setFrame:CGRectZero];
		[_selectionLastLineLayer setFrame:CGRectZero];
		
		[_selectionHandlerStartView setFrame:CGRectZero];
		[_selectionHandlerEndView setFrame:CGRectZero];
		
		[CATransaction commit];
		
		[self.parentScrollView scrollRectToVisible:caretRect
										  animated:YES];
		
		
	}else {
		DebugLog(@"%@ - drawing range", [self space]);
		//calculate selected range
		[self _initSelectionLayersIfNeeded];
		CGRect startRect = [self caretRectForPosition:self.selectedTextRange.start];
		CGRect endRect = [self caretRectForPosition:self.selectedTextRange.end];
		
		CGRect firstLineRect;
		CGRect middleLinesRect;
		CGRect lastLineRect;
		if (startRect.origin.y == endRect.origin.y ) {
			
			// The selection is single line.
			firstLineRect = CGRectMake(startRect.origin.x , // + startRect.size.width
									  startRect.origin.y,
									  endRect.origin.x  - startRect.origin.x, //-startRect.size.width
									  startRect.size.height);
			middleLinesRect = CGRectZero;
			lastLineRect = CGRectZero;
				
		} else {
			
			// The selection is multiline
			firstLineRect = CGRectMake(startRect.origin.x , //+ startRect.size.width
										 startRect.origin.y,
										 self.bounds.size.width - startRect.origin.x , //- startRect.size.width
										 startRect.size.height );
			middleLinesRect = CGRectMake(0,
									   startRect.origin.y + startRect.size.height,
									   self.bounds.size.width,
									   endRect.origin.y - (startRect.origin.y + startRect.size.height));
			lastLineRect = CGRectMake(0,
									  endRect.origin.y,
									  endRect.origin.x,
									  endRect.size.height);
			
	
		}

		//Hide caret
		[_caretLayer hideAndStopTiltAnimation];

		
		//Draw selected range
		[CATransaction begin]; 
		[CATransaction setValue: (id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		
		[_selectionFirstLineLayer setFrame:firstLineRect];
		[_selectionMiddleLinesLayer setFrame:middleLinesRect];
		[_selectionLastLineLayer setFrame:lastLineRect];
	
		[_selectionHandlerStartView showInCaretRect:startRect];
		[_selectionHandlerEndView showInCaretRect:endRect];
		
		[CATransaction commit];

		DebugLog(@"%@ - drawing range", [self space]);
		
	}
	DebugLog(@"%@%s - ends", [self popSpace], _cmd);
}

- (void) _hideMarkedRange{
	[CATransaction begin]; 
	[CATransaction setValue: (id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	[_markedFirstLineLayer setFrame:CGRectZero];
	[_markedMiddleLinesLayer setFrame:CGRectZero];
	[_markedLastLineLayer setFrame:CGRectZero];
	
	[CATransaction commit];
}

- (void) _drawMarkedRange{
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);
	if (self.markedTextRange) {
		
		//calculate selected range
		[self _initMarkedLayersIfNeeded];
		
		CGRect startRect = [self caretRectForPosition:self.markedTextRange.start];
		CGRect endRect = [self caretRectForPosition:self.markedTextRange.end];
		
		DebugLog(@"%@ - markedRange: %@",[self space], NSStringFromUITextRange(self.markedTextRange));
		DebugLog(@"%@ - markedRange, Start:%@ End:%@", [self space], NSStringFromUITextPosition(self.markedTextRange.start),
				 NSStringFromUITextPosition(self.markedTextRange.end));
		
		CGRect firstLineRect;
		CGRect middleLinesRect;
		CGRect lastLineRect;
		if (startRect.origin.y == endRect.origin.y ) {
			
			// The selection is single line.
			firstLineRect = CGRectMake(startRect.origin.x , // + startRect.size.width
									   startRect.origin.y,
									   endRect.origin.x  - startRect.origin.x, //-startRect.size.width
									   startRect.size.height);
			middleLinesRect = CGRectZero;
			lastLineRect = CGRectZero;
			
		} else {
			
			// The selection is multiline
			firstLineRect = CGRectMake(startRect.origin.x , //+ startRect.size.width
									   startRect.origin.y,
									   self.bounds.size.width - startRect.origin.x , //- startRect.size.width
									   startRect.size.height );
			middleLinesRect = CGRectMake(0,
										 startRect.origin.y + startRect.size.height,
										 self.bounds.size.width,
										 endRect.origin.y - (startRect.origin.y + startRect.size.height));
			lastLineRect = CGRectMake(0,
									  endRect.origin.y,
									  endRect.origin.x,
									  endRect.size.height);
			
			
		}
		
		//Draw selected range
		[CATransaction begin]; 
		[CATransaction setValue: (id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		
		[_markedFirstLineLayer setFrame:firstLineRect];
		[_markedMiddleLinesLayer setFrame:middleLinesRect];
		[_markedLastLineLayer setFrame:lastLineRect];
		
		[CATransaction commit];
		
	}
	DebugLog(@"%@%s - ends", [self popSpace], _cmd);
}


#pragma mark -
#pragma mark User Interaction : Touches

- (void) _dragHandler:(UIPanGestureRecognizer *)gestureRecognizer{
	TouchesLog(@"%@%s - starts", [self pushSpace], _cmd);
	
	N4TextPositionHandleView *handleView = (N4TextPositionHandleView *)[gestureRecognizer view];
    
	if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
		//hide copy/cut/past menu
		UIMenuController *menu = [UIMenuController sharedMenuController];
		[menu setMenuVisible:NO animated:NO];
		
	}else if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
		UITextPosition *newPosition;
		//newPosition = [self closestPositionToPoint:[gestureRecognizer locationInView:self]];
		
		
		if (handleView.type == N4TextPositionHandleTypeStart) {

			//correct point if neccessary
			CGPoint p = [gestureRecognizer locationInView:[gestureRecognizer view]];
			if ( p.y < (handleView.frame.size.height - (_fontHeight) ) ) {
				p.y = handleView.frame.size.height - (_fontHeight);
			}
			CGPoint touchPoint = [gestureRecognizer locationInView:self];
			touchPoint.y += p.y; 
			newPosition = [self closestPositionToPoint:touchPoint];
			
			
			//correct position if neccessary		
			if ([self comparePosition:newPosition toPosition:self.selectedTextRange.end] == NSOrderedDescending 
				&& [(N4TextPosition *)self.selectedTextRange.end index] > 0){
				newPosition = [self positionFromPosition:self.selectedTextRange.end offset:-1];
			}
				
			[self.inputDelegate selectionWillChange:self];
			self.selectedTextRange = [N4TextRange rangeFromPosition:newPosition 
														  toPosition:self.selectedTextRange.end];
			[self.inputDelegate selectionDidChange:self];
			
		}else if (handleView.type == N4TextPositionHandleTypeEnd) {
			//move end
			
			//correct position if neccessary
			CGPoint p = [gestureRecognizer locationInView:[gestureRecognizer view]];
			if ( p.y > (_fontHeight) ) {
				p.y = _fontHeight;
			}
			CGPoint touchPoint = [gestureRecognizer locationInView:self];
			touchPoint.y -= p.y; 
			newPosition = [self closestPositionToPoint:touchPoint];
			
			if ([self comparePosition:self.selectedTextRange.start toPosition:newPosition] == NSOrderedDescending 
				&& [(N4TextPosition *)self.selectedTextRange.start index] < [textStorage length])
				newPosition = [self positionFromPosition:self.selectedTextRange.start offset:1];
			
			//change position
			[self.inputDelegate selectionWillChange:self];
			self.selectedTextRange = [N4TextRange rangeFromPosition:self.selectedTextRange.start 
														  toPosition:newPosition];
			[self.inputDelegate selectionDidChange:self];
		
		}
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		//show copy/cut/paste menu
		UIMenuController *menu = [UIMenuController sharedMenuController];
		[menu setTargetRect:[_selectionFirstLineLayer frame] inView:self];
		[menu setMenuVisible:YES animated:YES];
	}
	
	TouchesLog(@"%@%s - ends", [self popSpace], _cmd);
}

- (void) _longPressHandler:(UILongPressGestureRecognizer *)touch{
	TouchesLog(@"%@%s - starts", [self pushSpace], _cmd);
	
	//if markedTextRange : show rectangle loupe & change insertion point (selectedRange)using:
	//- (UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range
	//else change selectedRange & show rounded loupe 

	if (touch.state == UIGestureRecognizerStateBegan || 
		touch.state == UIGestureRecognizerStateChanged) {
		
		CGPoint touchedPoint = [touch locationInView:self];
	
		if (self.markedTextRange) {
			
			UITextPosition * newPosition = [self closestPositionToPoint:touchedPoint 
															withinRange:self.markedTextRange];
			[self.inputDelegate selectionWillChange:self];
			self.selectedTextRange = [N4TextRange rangeWithNSRange:NSMakeRange([(N4TextPosition *)newPosition index], 0)];
			[self.inputDelegate selectionDidChange:self];
		
			if (CGRectContainsPoint(_markedFirstLineLayer.frame, touchedPoint) ||
				CGRectContainsPoint(_markedMiddleLinesLayer.frame, touchedPoint) ||
				CGRectContainsPoint(_markedLastLineLayer.frame, touchedPoint)){
				
			
				if(!_loupeView){
					_loupeView = [[N4LoupeView alloc] initWithMask:[UIImage imageNamed:@"RTKSelectionLoupeMask.png"] 
															overlay:[UIImage imageNamed:@"RTKSelectionLoupe.png"]];
					[_loupeView setMagnifyView:self];
					[_loupeView magnifyPoint:[touch locationInView:self]];
					
					//use:
					//[[_loupeView magnifyPoint:[touch locationInView:self]] inPosition:newPos];
					
					//CGRect b = [_loupeView bounds];
					//[_loupeView setBounds:CGRectOffset([_loupeView bounds], 0, 15)];
					
					//CGRect c = [self caretRectForPosition:newPosition];
					//[_loupeView setCenter:CGPointMake(touchPointWin.x, CGRectGetMaxY(c) - _loupeView.bounds.size.height/2)];
					
					[_loupeView release];
				}	
				
				[_loupeView magnifyPoint:[touch locationInView:self]];
				
			}
		    
		}else {
			
			UITextPosition * newPosition = [self closestPositionToPoint:touchedPoint]; 
			[self.inputDelegate selectionWillChange:self];
			self.selectedTextRange = [N4TextRange rangeWithNSRange:NSMakeRange([(N4TextPosition *)newPosition index], 0)];
			[self.inputDelegate selectionDidChange:self];
		
            if(!_loupeView){

				_loupeView = [[N4LoupeView alloc] initWithMask:[UIImage imageNamed:@"RTKCaretLoupeMask.png"] 
														overlay:[UIImage imageNamed:@"RTKCaretLoupe.png"]];
				[_loupeView setMagnifyView:self];
				[_loupeView magnifyPoint:[touch locationInView:self]];
				[_loupeView release];
				
			}
			[_loupeView magnifyPoint:[touch locationInView:self]];
		}
	
	}
	if (touch.state == UIGestureRecognizerStateRecognized) {
		
		[_loupeView remove];
		_loupeView = nil;
		if (![self isFirstResponder]) {
			[self _hideSelectionRange];
		}
		else {
			[[UIApplication sharedApplication].keyWindow becomeFirstResponder];
		}

		
		UIMenuItem *selectItem = [[UIMenuItem alloc] initWithTitle:@"Select" action:@selector(_select:)];
		UIMenuItem *selectAllItem = [[UIMenuItem alloc] initWithTitle:@"Select all" action:@selector(_selectAll:)];
		UIMenuController *menu = [UIMenuController sharedMenuController];
		[menu setMenuItems:[NSArray arrayWithObjects:selectItem, selectAllItem, nil]];
		[selectItem release];
		[selectAllItem release];
	
		CGPoint touchedPoint = [touch locationInView:self];
		UITextPosition * newPosition = [self closestPositionToPoint:touchedPoint];
		[menu setTargetRect:[self caretRectForPosition:newPosition]
					 inView:self];
		[menu setMenuVisible:YES animated:YES];
		NSLog(@"%@ %@", NSStringFromCGRect([self caretRectForPosition:newPosition]), 
			  NSStringFromCGRect([menu menuFrame]));
		
		
		
	}
	
	TouchesLog(@"%@%s - ends", [self popSpace], _cmd);
}

- (void)_doubleTapHandler:(UITapGestureRecognizer *)touch{
	TouchesLog(@"%@%s - starts", [self pushSpace], _cmd);
	if (touch.state == UIGestureRecognizerStateRecognized) {

		
		//self.selectedTextRange = [self characterRangeByExtendingPosition:self.selectedTextRange.start 
		//																		  inDirection:UITextLayoutDirectionDown];
		
		
		//if inside markedTextRange : return
		//if ouside markedTextRange : unmarkText
		//else change selectedRange & return 
		
		UITextRange *newSelectedRange = [self characterRangeAtPoint:[touch locationInView:self]];
		
		if (self.markedTextRange){
			NSRange markedTextNSRange = [(N4TextRange *)self.markedTextRange range];
			NSRange newSelectedNSRange = [(N4TextRange *)newSelectedRange range];
			NSRange inter = NSIntersectionRange(markedTextNSRange, newSelectedNSRange);
			if (inter.length != 0) return;
			[self unmarkText];
		}
					
		[self.inputDelegate selectionWillChange:self];
		self.selectedTextRange = newSelectedRange;
		[self.inputDelegate selectionDidChange:self];
		
		UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(_copy:)];
		UIMenuController *menu = [UIMenuController sharedMenuController];
		[menu setMenuItems:[NSArray arrayWithObject:copyItem]];
		[copyItem release];
		[menu setTargetRect:[_selectionFirstLineLayer frame] //[self firstRectForRange:self.selectedTextRange]
					 inView:self];
		[menu setMenuVisible:YES animated:YES];

		
	}
	TouchesLog(@"%@%s - ends", [self popSpace], _cmd);
}

- (void)_singleTapHandler:(UITapGestureRecognizer *)touch{
	TouchesLog(@"%@%s - starts", [self pushSpace], _cmd);
	if (touch.state == UIGestureRecognizerStateRecognized) {	
		
		if (![self isFirstResponder]) [self becomeFirstResponder];
		
		//if inside markedTextRange : change selectedTextRange to somewhere inside markedTextRange & return
		//if ouside markedTextRange : unmarkText
		//else change selectedRange & return 
				
		UITextPosition *newPosition = [self closestPositionToPoint:[touch locationInView:self]];
		
		if (self.markedTextRange){
			if ([self comparePosition:self.markedTextRange.start toPosition:newPosition] < NSOrderedDescending &&
				[self comparePosition:newPosition toPosition:self.markedTextRange.end] < NSOrderedDescending) {
				//TODO: change insertion point inside marked range
				//TODO: changes need to be done inside setMarkedText. markedText range should not be completely replaced if insertion point is within its range
			}
			else {
				[self unmarkText];
			}

		}
		
		[self.inputDelegate selectionWillChange:self];
		self.selectedTextRange = [N4TextRange rangeWithNSRange:NSMakeRange([(N4TextPosition *)newPosition index], 0)];
		[self.inputDelegate selectionDidChange:self];
		
    }
	TouchesLog(@"%@%s - ends", [self popSpace], _cmd);
}

#pragma mark -

- (void)_initialize {
	
	spaceNumber = 0;
	
	[self setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
	self.contentMode = UIViewContentModeRedraw;
	
	//styles;
	self.textStyle = [[self class] normalTextDefaultAttributes];
	self.selectedTextStyle = [[self class] selectedTextDefaultAttributes];
	self.markedTextStyle = [[self class] markedTextDefaultAttributes];
	
	//text storage
	textStorage = [[NSMutableAttributedString alloc] initWithString:@"aAaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aAaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aAaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aAaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb aaaa.bbbb "
														 attributes:self.textStyle];
	
	// Init various UITextInput properties
	NSRange range = NSMakeRange([textStorage length], 0);
	
	// selection/insertion point info and marked text info
	selectedTextRange = [[N4TextRange alloc] initWithNSRange:range];
	markedTextRange = nil; 
	
	
	// tokenizer (we use the default UITextInputStringTokenizer implememtation)
	tokenizer = [[UITextInputStringTokenizer alloc] initWithTextInput:self];
	
	// Oddly, docs suggest that textInputView is the text drawing view (in this case, self),
	// rather than the inputView usually represented by the keyboard view.
	textInputView = self;
	
	// draw caret when being first responder
	isEditing = FALSE;
	
	UITapGestureRecognizer *recognizer1;
	recognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self 
														 action:@selector(_singleTapHandler:)];
	[recognizer1 setNumberOfTapsRequired:1];
	[self addGestureRecognizer:recognizer1];
	[recognizer1 release];
	
	UITapGestureRecognizer *recognizer2;
	recognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self 
														 action:@selector(_doubleTapHandler:)];
	[recognizer2 setNumberOfTapsRequired:2];
	[self addGestureRecognizer:recognizer2];
	[recognizer2 release];
	
	UILongPressGestureRecognizer *recognizer3;
	recognizer3 = [[UILongPressGestureRecognizer alloc] initWithTarget:self 
														  action:@selector(_longPressHandler:)];
	[self addGestureRecognizer:recognizer3];
	[recognizer3 release];
	
	
	
}

#pragma mark -
#pragma mark UIView methods

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self _initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
		[self _initialize];
	}
    return self;
}

- (void)dealloc {
	[selectedTextRange release];
	[markedTextRange release];
	[markedTextStyle release];
	[(UITextInputStringTokenizer*)tokenizer release];
	inputDelegate = nil;
	textInputView = nil;
	[textStorage release];
	CFRelease(_frameRef);
	
	[_selectionHandlerEndView release];
	[_selectionHandlerStartView release];
	
    [super dealloc];
}

- (NSString *)description {
	return @"CoreTextView";
}

- (void)drawRect:(CGRect)rect {
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);

	//white background
	[[UIColor whiteColor] set];
	UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:self.bounds];
	[bezierPath fill];
	
	//marked text modification:
	[textStorage setAttributes:self.textStyle range:NSMakeRange(0, [textStorage length])];
	if (self.markedTextRange)
		[textStorage setAttributes:self.markedTextStyle range:[(N4TextRange *)self.markedTextRange range]];
	
	//text storage
	CFAttributedStringRef attrString = (CFAttributedStringRef)textStorage;

	//context to render to   
	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, self.frame.size.height);
    CGContextConcatCTM(context, flipVertical);
	
	//path for the framesetter
	CGMutablePathRef path = CGPathCreateMutable();
	CGRect textBounds = CGRectInset(self.bounds, INITIAL_HORIZ_OFFSET, INITIAL_VERT_OFFSET);
	int falseHeight = 0; // 5000 px = 280 lines aprox
	textBounds.size.height = textBounds.size.height + falseHeight;
	CGPathAddRect(path, NULL, textBounds);
	
	//framesetter
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
	CFRange currentRange = CFRangeMake(0, 0);
	if (_frameRef) CFRelease(_frameRef);
	_frameRef = CTFramesetterCreateFrame(framesetter, currentRange, path, NULL);
	
	CFRelease(path); path = NULL;
	
	// Iterate over CTLineDraw.
	CGPoint penPosition;
	penPosition.y = textBounds.origin.y + textBounds.size.height;
	
	// grab the lines and font metrics
	CFArrayRef lineArray = CTFrameGetLines(_frameRef);
	CFIndex j = 0, lineCount = CFArrayGetCount(lineArray);
	
	self.parentScrollView.contentSize = CGSizeMake(self.parentScrollView.contentSize.width, 
												   (lineCount + 1)*_fontHeight);
		
	for ( ; j < lineCount; j++ )
	{
		CTLineRef currentLine = (CTLineRef)CFArrayGetValueAtIndex(lineArray, j);
		
		double penOffset = CTLineGetPenOffsetForFlush(currentLine, 0, textBounds.size.width);
		penPosition.x = textBounds.origin.x + penOffset;
		penPosition.y -= _fontAscent;
		
		//[[UIColor redColor] set];
		//UIRectFrame(CGRectMake(penPosition.x, penPosition.y, 10, 1));
		
		CGContextSetTextPosition(context, penPosition.x, penPosition.y - falseHeight);
		CTLineDraw(currentLine, context);			
		
		penPosition.y -= ( _fontDescent + _fontLeading );
	}
	
	CFRelease(framesetter);

	if (isEditing) 
		[self _drawSelectionRange];
	else
		[self _hideSelectionRange];
	
	[[UIColor blueColor] set];
	UIRectFrame(self.bounds);
	//UIRectFrame(textBounds);
	DebugLog(@"%@%s - ends", [self popSpace], _cmd);
	DebugLog(@"***********************************************************");
	DebugLog(@" ");
	
	
}

#pragma mark -
#pragma mark UIResponder Protocol Methods

- (BOOL)canBecomeFirstResponder{
	return YES;
}

- (BOOL)becomeFirstResponder {
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);
	isEditing = [super becomeFirstResponder];
	if (isEditing) [self _drawSelectionRange];
	DebugLog(@"%@%s - ends", [self popSpace], _cmd);
	return isEditing;
}

- (BOOL)resignFirstResponder {
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);
	isEditing = ![super resignFirstResponder];
	if (!isEditing) [self _hideSelectionRange];
	DebugLog(@"%@%s - ends", [self popSpace], _cmd);
	return !isEditing;
}

#pragma mark -
#pragma mark UIKeyInput Protocol Methods

- (BOOL) hasText {
	return ([textStorage length] > 0);
}

- (void) insertText:(NSString *)text {
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);
	
	NSRange selectedRange = selectedTextRange ? 
		[(N4TextRange *)selectedTextRange range] : NSMakeRange(NSNotFound, 0);
	NSRange markedRange = markedTextRange ? 
		[(N4TextRange *)markedTextRange range] : NSMakeRange(NSNotFound, 0);
	
	if (markedRange.location != NSNotFound) {
		[textStorage replaceCharactersInRange:markedRange withString:text];
		selectedRange.location = markedRange.location + text.length;
		selectedRange.length = 0;
		markedRange = NSMakeRange(NSNotFound, 0);
	}else if (selectedRange.length > 0) {
		[textStorage replaceCharactersInRange:selectedRange withString:text];
		selectedRange.length = 0;
		selectedRange.location += text.length;
	}else {
		[textStorage replaceCharactersInRange:NSMakeRange(selectedRange.location, 0) withString:text];
		selectedRange.location += text.length;
	}
	[(N4TextRange *)self.selectedTextRange setRange:selectedRange];
	[(N4TextRange *)self.markedTextRange setRange:markedRange];
	
	[self setNeedsDisplay];

	//[self.parentScrollView scrollRectToVisible:[self caretRectForPosition:self.selectedTextRange.start]
	//								  animated:YES];

	DebugLog(@"%@%s - ends", [self popSpace], _cmd);
}

- (void) deleteBackward {
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);
	
	NSUInteger textStorageLength = [textStorage string].length;
	NSRange workRange = [(N4TextRange *)selectedTextRange range];	
		
	if ( NSUIntegerContainsNSRange(textStorageLength, workRange) ){
		
		DebugLog(@"%@Deleting:...", [self space]);	
		
		if ([selectedTextRange isEmpty]){	// In case there is no selected text, there is an insertion point only
			if (workRange.location > 0) {	//prepare to remove left char to the caret
				workRange.location = workRange.location - 1;
				workRange.length = MIN([textStorage string].length, 1);	//redundant?
			}		
			else {
				//remove right char to the caret: in order to test this long touch should be implemented
				workRange.location = 0;
				workRange.length = MIN([textStorage string].length, 1); //redundand? , should be one always?
			}
		}
		
		DebugLog(@"%@delete characters in range: %@", [self space], NSStringFromRange(workRange));
		[textStorage deleteCharactersInRange:workRange];
		
		[(N4TextRange *)selectedTextRange setRange:NSMakeRange(workRange.location, 0)];
		
		[self setNeedsDisplay];	
		DebugLog(@"%@Finishing Deleting...", [self space]);
	}
	else{
		DebugLog(@"%@%s::: range error what went wrong?::::::::::::::::::::::::::::::::", [self space], _cmd);
	}
	DebugLog(@"%@%s - ends", [self popSpace], _cmd);

}


#pragma mark -
#pragma mark UITextInput Protocol Methods
#pragma mark   Replacing and Returning Strings 

- (NSString *)textInRange:(UITextRange *)range{
	DebugLog(@"%@%s - starts: %@", [self pushSpace], _cmd, NSStringFromUITextRange(range));
	NSString *workStr = nil; //@"";
	NSUInteger textLength = [textStorage length];
	NSRange nsrange = [(N4TextRange*)range range];
	if (!range.empty && NSUIntegerContainsNSRange(textLength, nsrange)) {
		workStr = [[textStorage string] substringWithRange:nsrange];
	}
	DebugLog(@"%@%s - ends: %@", [self popSpace], _cmd, workStr);
	return workStr;
}

- (void)replaceRange:(UITextRange *)range withText:(NSString *)text{
	
	DebugLog(@"%@%s - starts: %@, %@", [self pushSpace], _cmd, NSStringFromUITextRange(range), text);
	
	NSRange r = [(N4TextRange *)range range];
	NSRange selectedNSRange = self.selectedTextRange? 
			[(N4TextRange *)self.selectedTextRange range] : 
			NSMakeRange(NSNotFound, 0);

    if ((r.location + r.length) <= selectedNSRange.location) { 
		
		//no intersection, (location is the same, location changes)
        selectedNSRange.location -= (r.length - text.length);
    
	}else{
		NSRange intersection = NSIntersectionRange(r, selectedNSRange);
		if (0 < intersection.length ) {
			
			if (intersection.location == selectedNSRange.location) {
				//selection will be right truncated (location and length will change accordingly)
				
				if (r.location + r.length > selectedNSRange.location + selectedNSRange.length) { 
					//if replaceRange covers selectedRange
					selectedNSRange.location = r.location + text.length;
					selectedNSRange.length = 0;
				}else {
					//if replaceRange is inside selection: divide it and select the left part.
					selectedNSRange.location += (text.length - r.length + intersection.length);
					selectedNSRange.length -= intersection.length;
				}
				
			}else{
				//selection will be left truncated (location is the same, length changes.)
				selectedNSRange.length = intersection.location - selectedNSRange.location;
			}
			
		}
	}
	
	[textStorage replaceCharactersInRange:r withString:text];
	if (!self.selectedTextRange)
		selectedTextRange = [[N4TextRange alloc] init];
	[(N4TextRange *)selectedTextRange setRange:selectedNSRange];
	
	[self setNeedsDisplay];

	DebugLog(@"%@%s - ends", [self popSpace], _cmd);

}

#pragma mark  Working with Marked and Selected Text

- (void) setSelectedTextRange:(UITextRange *)textRange {
	DebugLog(@"%@%s - starts: %@", [self pushSpace], _cmd, NSStringFromUITextRange(textRange));
	if (textRange && selectedTextRange != textRange) {
		
		// Sanity check is neccesary, some methods of UITextInput might return nil.
		// Checking the value here is the best approach
		NSRange nsrange = [(N4TextRange *)textRange range];
		if (nsrange.location > [textStorage length]) {
			nsrange.location = [textStorage length];
		}
		if (nsrange.location + nsrange.length > [textStorage length]) {
			nsrange.length = [textStorage length] - nsrange.location;
		}
		
		[selectedTextRange release];
		selectedTextRange = [[N4TextRange alloc] initWithNSRange:nsrange];
		
		[self _drawSelectionRange];	
	}
	DebugLog(@"%@%s - ends", [self popSpace], _cmd);
}

- (void) setMarkedTextStyle:(NSDictionary *)newMarkedTextStyle {
	
	if (markedTextStyle != newMarkedTextStyle) {
	
		[markedTextStyle release];
		if ([newMarkedTextStyle objectForKey:UITextInputTextFontKey] || 
			[newMarkedTextStyle objectForKey:(NSString *)kCTFontAttributeName] ) {
			//In this implementation text size has to be the same for the hole text
			NSMutableDictionary *mnewMarkedTextStyle = [newMarkedTextStyle mutableCopy];
			[mnewMarkedTextStyle removeObjectForKey:UITextInputTextFontKey];
			[mnewMarkedTextStyle removeObjectForKey:(NSString *)kCTFontAttributeName];
			markedTextStyle = mnewMarkedTextStyle;
		}else {
			markedTextStyle = [newMarkedTextStyle copy];
		}
		[self setNeedsDisplay];
	}
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange{
	DebugLog(@"%@%s - starts: %@, %@", [self pushSpace], _cmd, markedText, NSStringFromRange(selectedRange));
	
	// markedText:The text to be marked, replace other marked text or selection.
	// selectedRange: A range within markedText that indicates the current selection. 
	// This range is always relative to markedText.
	
	DebugLog(@"%@%s selectedTextRange: %@ markedTextRange:%@ ", [self space], _cmd, NSStringFromUITextRange(self.selectedTextRange), NSStringFromUITextRange(self.markedTextRange));
	if(1){
        
        NSRange curMarkedRange = self.markedTextRange? 
        [(N4TextRange *)self.markedTextRange range] : NSMakeRange(NSNotFound, 0);
        NSRange curSelectedRange = self.selectedTextRange? 
        [(N4TextRange *)self.selectedTextRange range] : NSMakeRange(NSNotFound, 0);
        
        if (!markedText) markedText = @"";//is this neccesary?
        
        if (curMarkedRange.location != NSNotFound) {
            //if there is a marked range replace it
            [textStorage replaceCharactersInRange:curMarkedRange withString:markedText];
            curMarkedRange.length = markedText.length;
            
        }else if (curSelectedRange.length > 0) {
            //otherwse, if there is a selection replace it
            [textStorage replaceCharactersInRange:curSelectedRange withString:markedText];
            curMarkedRange.location = selectedRange.location;
            curMarkedRange.length = markedText.length;
            
        }else {
            //otherwise if there is just an insertion point, insert it
            [textStorage replaceCharactersInRange:curSelectedRange
                                       withString:markedText];
            curMarkedRange.location = curSelectedRange.location;
            curMarkedRange.length = curMarkedRange.length + markedText.length; //curMarkedRange.length is always cero then only markedText.length;
            
        }
        
        curSelectedRange = NSMakeRange(curMarkedRange.location + selectedRange.location, 
                                       selectedRange.length);
        
        //update markedTextRange and selecteTextRange objects
        if (!self.markedTextRange) 
            markedTextRange = [[N4TextRange alloc] init];
        
        
        [(N4TextRange *) markedTextRange setRange:curMarkedRange];
        [(N4TextRange *) selectedTextRange setRange:curSelectedRange];	
        
    }else{
               
        if (!markedText) markedText = @"";//sanity check
        NSRange newSelectedTextRange;
        NSRange newMarkedTextRange;
        NSRange curMarkedTextRange = [(N4TextRange *)self.markedTextRange range];
        NSRange curSelectedTextRange = [(N4TextRange *)self.selectedTextRange range];
        
        if (!self.markedTextRange){
            //if there is no marked text
            [textStorage replaceCharactersInRange:curSelectedTextRange withString:markedText];
            newMarkedTextRange = NSMakeRange(selectedRange.location, markedText.length);
        
            markedTextRange = [[N4TextRange alloc] init];
        
        }else{
            //if there is marked text
       
            [textStorage replaceCharactersInRange:curMarkedTextRange withString:markedText];
            curMarkedTextRange.length = markedText.length;
        }
        newSelectedTextRange = NSMakeRange(curMarkedTextRange.location + selectedRange.location, 
                                                      selectedRange.length);
        [(N4TextRange *) markedTextRange setRange:newMarkedTextRange];
        [(N4TextRange *) selectedTextRange setRange:newSelectedTextRange];	
	}
	[self _drawMarkedRange];
	
	DebugLog(@"%@%s selectedTextRange: %@ markedTextRange:%@ ", [self space], _cmd, NSStringFromUITextRange(self.selectedTextRange), NSStringFromUITextRange(self.markedTextRange));
    
    [self setNeedsDisplay];	
	
	DebugLog(@"%@%s - ends", [self popSpace], _cmd);
}

- (void)unmarkText {
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);
	[markedTextRange release];
	markedTextRange = nil;
	//[self setNeedsDisplay]; //NOTE: setNeedsDisplay is only neccessary if marketTextStyle is different from normalTextStyle
	[self _hideMarkedRange];
	DebugLog(@"%@%s - ends", [self popSpace], _cmd);
}

#pragma mark Computing Text Ranges and Text Positions

- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition 
							toPosition:(UITextPosition *)toPosition{
	//__DebugLog(@"%@%s - starts: %@, %@", [self pushSpace], _cmd, NSStringFromUITextPosition(fromPosition), NSStringFromUITextPosition(toPosition));
	N4TextPosition *from = (N4TextPosition *)fromPosition;
	N4TextPosition *to = (N4TextPosition *)toPosition;
	N4TextRange *range = [N4TextRange rangeWithNSRange:NSMakeRange(MIN(from.index, to.index), ABS((int)to.index - (int)from.index))];
	
	//__DebugLog(@"%@%s - ends: %@", [self popSpace], _cmd, NSStringFromUITextRange(range));
	
	return range;
	
}

- (UITextPosition *)positionFromPosition:(UITextPosition *)position 
								  offset:(NSInteger)offset{
	//__DebugLog(@"%@%s - starts: %@, %i", [self pushSpace], _cmd, NSStringFromUITextPosition(position), offset);

	N4TextPosition *newPosition = nil;
	NSUInteger pos = [(N4TextPosition *)position index]; 
	NSInteger newIndex = pos + offset;
	if (0 <= newIndex && newIndex <= [textStorage length])
		newPosition = [N4TextPosition positionWithIndex:newIndex];
	
	//__DebugLog(@"%@%s - ends: %@", [self popSpace], _cmd, NSStringFromUITextPosition(newPosition));
	return newPosition;
}

- (UITextPosition *)positionFromPosition:(UITextPosition *)position 
							 inDirection:(UITextLayoutDirection)direction 
								  offset:(NSInteger)offset{
	DebugLog(@"%@%s - starts: %@, %i, %i", [self pushSpace], _cmd, NSStringFromUITextPosition(position), direction, offset);
	
	N4TextPosition *newPosition = nil;
	NSUInteger pos = [(N4TextPosition *)position index];
	NSUInteger textStorageLength = [textStorage length];
	
	if (direction == UITextLayoutDirectionLeft && 
			(NSInteger)(pos - offset) >= 0) { 
		newPosition = [N4TextPosition positionWithIndex:pos - offset];
		
	}else if (direction == UITextLayoutDirectionRight && 
			  pos + offset <= textStorageLength) {
		newPosition = [N4TextPosition positionWithIndex:pos + offset];
	
	}else if (direction == UITextLayoutDirectionUp) {
		
			CFArrayRef lines = CTFrameGetLines(_frameRef);
			CTLineRef line = NULL;
			uint j = 0;
			for (; j < CFArrayGetCount(lines); j++) {
				line = CFArrayGetValueAtIndex(lines, j);
				CFRange lineRange = CTLineGetStringRange(line);
				if (lineRange.location <= pos && pos <= lineRange.location + lineRange.length) 
					break;
				line = NULL;
			}
			if ( line && (NSInteger)(j - offset) >= 0) {
				CGFloat xOffsetToPosition = CTLineGetOffsetForStringIndex(line, pos, NULL);
				NSInteger newIndex = 0;
				newIndex = CTLineGetStringIndexForPosition(CFArrayGetValueAtIndex(lines, j - offset), 
														   CGPointMake(xOffsetToPosition, 0.0f));
				newPosition = [N4TextPosition positionWithIndex:newIndex];
			}
	
	}else if (direction == UITextLayoutDirectionDown){ 
		
		CFArrayRef lines = CTFrameGetLines(_frameRef);
		CTLineRef line = NULL;
		uint j = 0;
		for (; j < CFArrayGetCount(lines); j++) {
			line = CFArrayGetValueAtIndex(lines, j);
			CFRange lineRange = CTLineGetStringRange(line);
			if (lineRange.location <= pos && pos <= lineRange.location + lineRange.length) 
				break;
			line = NULL;
		}
		if (line && j + offset < CFArrayGetCount(lines)) { //textStorageLength
			CGFloat xOffsetToPosition = CTLineGetOffsetForStringIndex(line, pos, NULL);
			NSInteger newIndex = 0;
			newIndex = CTLineGetStringIndexForPosition(CFArrayGetValueAtIndex(lines, j + offset), 
													   CGPointMake(xOffsetToPosition, 0.0f));
			newPosition = [N4TextPosition positionWithIndex:newIndex];
		}
	}
	DebugLog(@"%@%s - ends: %@", [self popSpace], _cmd, NSStringFromUITextPosition(newPosition));
	return newPosition;
}

- (UITextPosition *)beginningOfDocument {
	return [N4TextPosition positionWithIndex:0];
}
- (UITextPosition *)endOfDocument {
	return [N4TextPosition positionWithIndex:[textStorage length]];
}

#pragma mark Evaluating Text Positions
- (NSComparisonResult)comparePosition:(UITextPosition *)position 
						   toPosition:(UITextPosition *)other{
	
	if ([(N4TextPosition *)position index] < [(N4TextPosition *)other index])
		return NSOrderedAscending;
	if ([(N4TextPosition *)position index] > [(N4TextPosition *)other index])
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}

- (NSInteger)offsetFromPosition:(UITextPosition *)fromPosition 
					 toPosition:(UITextPosition *)toPosition{
	//__DebugLog(@"%@%s - starts: %@, %@", [self pushSpace], _cmd, NSStringFromUITextPosition(fromPosition), NSStringFromUITextPosition(toPosition));
	
	NSUInteger from  = [(N4TextPosition *)fromPosition index];
	NSUInteger to = [(N4TextPosition *)toPosition index];
	
	//__DebugLog(@"%@%s - ends: %i", [self popSpace], _cmd, to-from);
	return to - from;
}

#pragma mark Determining Layout and Writing Direction

- (UITextPosition *)positionWithinRange:(UITextRange *)range 
					farthestInDirection:(UITextLayoutDirection)direction{
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);

	UITextPosition *resultPosition = nil;
	if (direction == UITextLayoutDirectionUp) {
		resultPosition = range.start;
		
	}else if (direction == UITextLayoutDirectionDown) {
		resultPosition = range.end;
		
	}else if (direction == UITextLayoutDirectionLeft) {
		UITextRange *firstLineRange = [self characterRangeByExtendingPosition:range.end inDirection:UITextLayoutDirectionLeft];
		resultPosition = firstLineRange.start;
		
	}else if (direction == UITextLayoutDirectionRight) {
		UITextRange *lastLineRange = [self characterRangeByExtendingPosition:range.start inDirection:UITextLayoutDirectionRight];
		resultPosition = lastLineRange.end;
	}
	
	DebugLog(@"%@%s - ends : %@", [self popSpace], _cmd, NSStringFromUITextPosition(resultPosition));
	return resultPosition;
}


- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position 
									   inDirection:(UITextLayoutDirection)direction{
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);
	
	UITextRange *resultRange = nil;
	
	NSUInteger pos = [(N4TextPosition *)position index];
	CFArrayRef lines = CTFrameGetLines(_frameRef);
	CTLineRef line = NULL;
	uint j = 0;
	for (; j < CFArrayGetCount(lines); j++) {
		line = CFArrayGetValueAtIndex(lines, j);
		CFRange lineRange = CTLineGetStringRange(line);
		if (lineRange.location <= pos && pos <= lineRange.location + lineRange.length) 
			break;
		line = NULL;
	}
	
	if(line){
		DebugLog(@"lineNumber: %i", j);
		if (direction == UITextLayoutDirectionLeft) {
			// NOTE: If here we have tp create a range that's "negative" with respect to textStorage "direction"
			// this will not be possible with current IndexedRange Class. Maybe Dan's implementation is better?
			CFRange lineRange = CTLineGetStringRange(line);
			resultRange = [N4TextRange rangeWithNSRange:NSMakeRange(pos, lineRange.location + lineRange.length - pos)];
			
		}else if (direction == UITextLayoutDirectionRight) {
			CFRange lineRange = CTLineGetStringRange(line);
			resultRange = [N4TextRange rangeWithNSRange:NSMakeRange(lineRange.location, pos - lineRange.location)];
			
		} else if (direction == UITextLayoutDirectionUp) {
			// NOTE: If here we have tp create a range that's "negative" with respect to textStorage "direction"
			// this will not be possible with current IndexedRange Class. Maybe Dan's implementation is better?
			CGFloat xOffsetToPosition = CTLineGetOffsetForStringIndex(line, pos, NULL);
			NSInteger posAtFirstLine = CTLineGetStringIndexForPosition(CFArrayGetValueAtIndex(lines, 0),
																 CGPointMake(xOffsetToPosition, 0.0f));
			resultRange = [N4TextRange rangeWithNSRange:NSMakeRange( posAtFirstLine , pos - posAtFirstLine )];
			
			
		}else if (direction == UITextLayoutDirectionDown){
			CGFloat xOffsetToPosition = CTLineGetOffsetForStringIndex(line, pos, NULL);
			NSInteger posAtLastLine = CTLineGetStringIndexForPosition(CFArrayGetValueAtIndex(lines, CFArrayGetCount(lines) - 1),
																	   CGPointMake(xOffsetToPosition, 0.0f));
			resultRange = [N4TextRange rangeWithNSRange:NSMakeRange( pos , posAtLastLine - pos )];
			
		}
	}
	
	DebugLog(@"%@%s - ends:%@", [self popSpace], _cmd, NSStringFromUITextRange(resultRange));
	return resultRange;	
}

- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position 
											  inDirection:(UITextStorageDirection)direction{
	return UITextWritingDirectionLeftToRight;
}

- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection 
					   forRange:(UITextRange *)range{
	// If we are using only one direction (Left to Right) then 
	// there is no need to change anything in the renderer (CoreText frame setter, etc)
}

#pragma mark Geometry and Hit-Testing Methods

- (CGRect)firstRectForRange:(UITextRange *)range{
	DebugLog(@"%@%s - starts: %@", [self pushSpace], _cmd, NSStringFromUITextRange(range));
	
	NSRange nsrange = [(N4TextRange *)range range];
	CTLineRef line = NULL;
	CFArrayRef lines = CTFrameGetLines(_frameRef);
	
	//find line that contains position
	uint j = 0;
	for (; j < CFArrayGetCount(lines); j++) {
		line = CFArrayGetValueAtIndex(lines, j);
		CFRange lineRange = CTLineGetStringRange(line);
		if (lineRange.location <= nsrange.location && nsrange.location <= lineRange.location + lineRange.length)
			break; //current line is found.
	}
	
	CGFloat x = CTLineGetOffsetForStringIndex(line, nsrange.location, NULL);
	
	CFRange lineRange = CTLineGetStringRange(line);
	uint charIndex = nsrange.location+nsrange.length < lineRange.location + lineRange.length ? 
				nsrange.location+nsrange.length : 
				lineRange.location + lineRange.length;
	CGFloat width = CTLineGetOffsetForStringIndex(line, charIndex, NULL) - x;
	
	
	CGFloat height = _fontHeight;
    
    CGFloat y = j*(_fontHeight);
	
	CGRect resultRect = CGRectMake(INITIAL_HORIZ_OFFSET + x, 
								   INITIAL_VERT_OFFSET + y, 
                                   width, height);
	
    
	DebugLog(@"%@%s - ends: %@", [self popSpace], _cmd, NSStringFromCGRect(resultRect));
	return resultRect;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position{
	DebugLog(@"%@%s - starts: %@", [self pushSpace], _cmd, NSStringFromUITextPosition(position));
	
	NSUInteger pos = [(N4TextPosition *)position index];
	//TODO: sanity check: when selectiong with Shift+Arrows app will crash
	CTLineRef line = NULL;
	CFRange lineRange;
	int j;
	
	CFArrayRef lines = CTFrameGetLines(_frameRef);
	CFIndex linesCount = CFArrayGetCount(lines);
	
	//find the line that contains the caret
	for (j = 0; j < linesCount ; j++) {
		line = CFArrayGetValueAtIndex(lines, j);
		lineRange = CTLineGetStringRange(line);
		if(lineRange.location <= pos && pos <= lineRange.location + lineRange.length) //<= && <= or <= && < ???
			break;
	}
	
	CGFloat widthToCaret = INITIAL_HORIZ_OFFSET + CTLineGetOffsetForStringIndex(line, pos, NULL);
	CGFloat heightToCaret = INITIAL_VERT_OFFSET + j*(_fontHeight);
	//last check for spaces at the end of the paragraph: Because sometimes is not visible
	if (widthToCaret > (self.bounds.size.width - 2 *INITIAL_HORIZ_OFFSET)) {  
		widthToCaret = (self.bounds.size.width - 2 *INITIAL_HORIZ_OFFSET);
	}
	
	CGRect caretRect = CGRectMake(widthToCaret, heightToCaret, 3, _fontHeight);
	
	//caretRect is in CoreText Coordinates.
	DebugLog(@"%@%s - ends: %@", [self popSpace], _cmd, NSStringFromCGRect(caretRect));
	return caretRect;
}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point{	
	//__DebugLog(@"%@%s - starts", [self pushSpace], _cmd);
	
	N4TextPosition *position;
	
	NSArray *lines = (NSArray *)CTFrameGetLines(_frameRef);
	NSUInteger linesCount = lines.count;
	
	NSInteger pointedLineIndex = (point.y - INITIAL_VERT_OFFSET)/(_fontHeight);
	if (pointedLineIndex < 0) {
		//pointed before first line
		position = [N4TextPosition positionWithIndex:0];
		
	}else if (pointedLineIndex >= linesCount) {
		//pointed after last line
		position = [N4TextPosition positionWithIndex:[textStorage length]];
		
	}else {
		//pointed some line: find the index.
		CGPoint ctPoint = CGPointUIKit2CT(point);
		CGPoint pointInLine;
		CTFrameGetLineOrigins(_frameRef, CFRangeMake(pointedLineIndex, 1), &pointInLine);
		pointInLine.x = ctPoint.x;
		pointInLine.y = ctPoint.y - pointInLine.y; // or 0
		
		CTLineRef line = (CTLineRef)[lines objectAtIndex:pointedLineIndex];
		NSUInteger index = CTLineGetStringIndexForPosition(line, pointInLine);
		
		position = [N4TextPosition positionWithIndex:index];
	}
	
	//__DebugLog(@"%@%s - ends: %@", [self popSpace], _cmd, NSStringFromUITextPosition(position));
	return position;

}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range{
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);
	
	UITextPosition *closestPosition = [self closestPositionToPoint:point];
	NSUInteger pos = [(N4TextPosition *)closestPosition index];
	
	NSRange nsrange = [(N4TextRange *)range range];
	if (pos < nsrange.location)
		closestPosition = [[range.start copy] autorelease];
	if (nsrange.location+nsrange.length < pos)
		closestPosition = [[range.end copy] autorelease];
	
	DebugLog(@"%@%s - ends: %@", [self popSpace], _cmd, NSStringFromUITextPosition(closestPosition));
	return closestPosition;
}

- (UITextRange *)characterRangeAtPoint:(CGPoint)point{
	DebugLog(@"%@%s - starts", [self pushSpace], _cmd);
	
	N4TextPosition *closestPosition = (N4TextPosition *)[self closestPositionToPoint:point];
	N4TextRange *enclosingRange = (N4TextRange *)[tokenizer rangeEnclosingPosition:closestPosition 
																	 withGranularity:UITextGranularityWord 
																		 inDirection:UITextLayoutDirectionRight];
	//direction can be UITextStorageDirection or UITextLayoutDirection , which one?
	
	DebugLog(@"%@%s - ends: %@", [self popSpace], _cmd, NSStringFromUITextRange(enclosingRange));
	return enclosingRange;
	
}

#pragma mark Returning Text Styling Information

- (NSDictionary *)textStylingAtPosition:(UITextPosition *)position 
							inDirection:(UITextStorageDirection)direction{
	DebugLog(@"%@%s - starts: %@, %i", [self pushSpace], _cmd, NSStringFromUITextPosition(position), direction);
	
	NSInteger workIndex = [(N4TextPosition *)position index];
	// You must sanity check the index
	if (workIndex < 0) workIndex = 0;
	if (workIndex >= [textStorage length]) workIndex = [textStorage length] - 1;
	NSDictionary *workDictionary = [textStorage attributesAtIndex:(NSUInteger)workIndex 
												   effectiveRange:NULL];
	
	DebugLog(@"%@%s - ends", [self popSpace], _cmd);
	return workDictionary;
}

#pragma mark Reconciling Text Position and Character Offset

// Optional
//- (UITextPosition *)positionWithinRange:(UITextRange *)range atCharacterOffset:(NSInteger)offset
//- (NSInteger)characterOffsetOfPosition:(UITextPosition *)position withinRange:(UITextRange *)range

#pragma mark -
#pragma mark UIResponderStandardEditActions informal protocol methods
//NOTE: changing the signature if _method:(id)sender to method:(id)sender will show all buttons in the sharedMenuController
- (void)_cut:(id)sender{
	if (![self.selectedTextRange isEmpty]) {
		NSRange range = [(N4TextRange *)self.selectedTextRange range];
		NSString *cutString = [textStorage.string substringWithRange:range];
		[self deleteBackward];
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		[pasteboard setString:cutString];
	}
}
- (void)_copy:(id)sender{
	if (![self.selectedTextRange isEmpty]) {
		NSRange range = [(N4TextRange *)self.selectedTextRange range];
		NSString *copyString = [textStorage.string substringWithRange:range];
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		[pasteboard setString:copyString];
	}
}
- (void)_paste:(id)sender {
	if (![self.selectedTextRange isEmpty]) {
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		[self insertText:[pasteboard string]];
	}
}
- (void)_select:(id)sender {
	if (![self.selectedTextRange isEmpty]) {
		[self unmarkText];
		self.selectedTextRange = [self characterRangeByExtendingPosition:self.selectedTextRange.start 
															  inDirection:UITextLayoutDirectionRight];
	}
}
- (void)_selectAll:(id)sender {
	[self unmarkText];
	self.selectedTextRange = [N4TextRange rangeFromPosition:self.beginningOfDocument 
												 toPosition:self.endOfDocument];
	/*
	UIMenuController *menu = [UIMenuController sharedMenuController];
	[menu setMenuVisible:NO animated:YES];
	
	UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(_copy:)];
	[menu setMenuItems:[NSArray arrayWithObject:copyItem]];
	NSLog(@"*****first rect: %@", NSStringFromCGRect([self firstRectForRange:self.selectedTextRange]));
	[menu setTargetRect:[self firstRectForRange:self.selectedTextRange]
				 inView:self];
	[menu setMenuVisible:YES];
	[menu update];

	 */
}
- (void)_delete:(id)sender {
	if (![self.selectedTextRange isEmpty]) {
		[self deleteBackward];
	}
}

//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
//	NSLog(@"%s %@ %@", _cmd, NSStringFromSelector(action), sender);/
//	return YES;
//}


@end // CoreTextView