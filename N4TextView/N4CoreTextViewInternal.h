//
//  N4CoreTextViewInternal.h
//  N4TextView
//
//  Created by Ignacio Enriquez Gutierrez on 7/5/10.
//  Copyright 2010 Nacho4D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
@class N4TextPositionHandleView;
@class N4LoupeView;

@interface N4CoreTextViewInternal : UIView <UITextInput, UITextInputTraits> {
	
@private
	// For UITextInputTraits
	UITextAutocapitalizationType autocapitalizationType;	
	UITextAutocorrectionType autocorrectionType;
	BOOL enablesReturnKeyAutomatically;
	UIKeyboardAppearance keyboardAppearance;
	UIKeyboardType keyboardType;
	UIReturnKeyType returnKeyType;
	BOOL secureTextEntry;
	
	// For UITextInput
	UITextRange *selectedTextRange;
	UITextRange *markedTextRange;
	NSDictionary *markedTextStyle;
	id<UITextInputTokenizer> tokenizer;
	id<UITextInputDelegate> inputDelegate;
	UIView *textInputView;
	
	// Our "text storage"
	NSMutableAttributedString *textStorage;

	CTFrameRef _frameRef;
	CGFloat _fontAscent;
	CGFloat _fontDescent;
	CGFloat _fontLeading;
	CGFloat _fontHeight;
	
	//Interaction:
	BOOL isEditing;
	CALayer *_caretLayer;
	CALayer *_selectionFirstLineLayer;
	CALayer *_selectionMiddleLinesLayer;
	CALayer *_selectionLastLineLayer;
	
	CALayer *_markedFirstLineLayer;
	CALayer *_markedMiddleLinesLayer;
	CALayer *_markedLastLineLayer;
	
	N4TextPositionHandleView * _selectionHandlerStartView;
	N4TextPositionHandleView * _selectionHandlerEndView;
	N4LoupeView *_loupeView;
	
	UIScrollView *_parentScrollView;
	
	//debug
	NSInteger spaceNumber;
	
	
}
//debug
- (NSString *)pushSpace;
- (NSString *)popSpace;

// For UITextInputTraits
@property(nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property(nonatomic) UITextAutocorrectionType autocorrectionType;
@property(nonatomic) BOOL enablesReturnKeyAutomatically;
@property(nonatomic) UIKeyboardAppearance keyboardAppearance;
@property(nonatomic) UIKeyboardType keyboardType;
@property(nonatomic) UIReturnKeyType returnKeyType;
@property(nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;

// For UITextInput
@property(readwrite, copy) UITextRange *selectedTextRange;
@property(nonatomic, readonly) UITextRange *markedTextRange;

@property(nonatomic, copy) NSDictionary *markedTextStyle;

@property(nonatomic, readonly) id<UITextInputTokenizer> tokenizer;
@property(nonatomic, assign) id<UITextInputDelegate> inputDelegate;

@property(nonatomic, readonly) UITextPosition *beginningOfDocument;
@property(nonatomic, readonly) UITextPosition *endOfDocument;
@property(nonatomic, readonly) UIView *textInputView;

//For storage
@property(nonatomic, retain) NSMutableAttributedString *textStorage;

//for convenience
@property(nonatomic, copy) NSDictionary *selectedTextStyle;
@property(nonatomic, copy) NSDictionary *textStyle;

//for Scrolling:
@property(nonatomic, assign) UIScrollView *parentScrollView;

- (NSString *) text;
- (void) setText:(NSString *)newText;

@end







