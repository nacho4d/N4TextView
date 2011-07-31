//
//  N4TextRange.m
//  N4TextView
//
//  Created by Ignacio Enriquez Gutierrez on 7/6/10.
//  Copyright 2010 Nacho4D. All rights reserved.
//

#import "N4TextRange.h"
#import "N4TextPosition.h"

@implementation N4TextRange
@synthesize range = _range;

- (N4TextRange *)init
{
	return [self initWithNSRange:NSMakeRange(NSNotFound, 0)];
}

- (N4TextRange *)initWithNSRange:(NSRange)nsrange
{
	self = [super init];
	if (self) {
		_range = nsrange;
	}
	return self;
}

+ (N4TextRange *)rangeWithNSRange:(NSRange)nsrange
{
	N4TextRange *obj = [[N4TextRange alloc] initWithNSRange:nsrange];
	return [obj autorelease];
}

+ (N4TextRange *)rangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
	NSRange newRange = NSMakeRange([(N4TextPosition*)fromPosition index], 
								   [(N4TextPosition*)toPosition index] - [(N4TextPosition*)fromPosition index]);
	return [N4TextRange rangeWithNSRange:newRange];
}

- (UITextPosition *)start
{
	return [N4TextPosition positionWithIndex:_range.location];
}

- (UITextPosition *)end
{
	return [N4TextPosition positionWithIndex:_range.location + _range.length];
}

- (BOOL)isEmpty
{
	return (_range.length == 0);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	return [[N4TextRange alloc] initWithNSRange:_range];
}

@end

NSString * NSStringFromUITextRange(UITextRange *range)
{
	return NSStringFromRange([(N4TextRange *)range range]);
}