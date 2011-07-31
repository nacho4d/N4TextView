//
//  N4TextPosition.m
//  N4TextView
//
//  Created by Ignacio Enriquez Gutierrez on 7/6/10.
//  Copyright 2010 Nacho4D. All rights reserved.
//

#import "N4TextPosition.h"

@implementation N4TextPosition
@synthesize index = _index;

- (N4TextPosition *)initWithIndex:(NSUInteger)index
{
	self = [super init];
	if (self) {
		_index = index;
	}
	return self;
}

+ (N4TextPosition *)positionWithIndex:(NSUInteger)index
{
	N4TextPosition *pos = [[N4TextPosition alloc] initWithIndex:index];
	return [pos autorelease];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[N4TextPosition alloc] initWithIndex:[self index]];
}

@end

NSString *NSStringFromUITextPosition(UITextPosition *position){
	return [NSString stringWithFormat:@"{%ud}", [(N4TextPosition *)position index]];
}