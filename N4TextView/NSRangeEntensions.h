/*
 *  NSRangeEntensions.h
 *  N4TextView
 *
 *  Created by Enriquez Gutierrez Guillermo Ignacio on 7/2/10.
 *  Copyright 2010 Nacho4D. All rights reserved.
 *
 */

#import <Foundation/Foundation.h>

#pragma mark -

NSUInteger NSRangeGetMin(NSRange range);
NSUInteger NSRangeGetMax(NSRange range);
BOOL NSRangeContainsNSUInteger(NSRange range, NSUInteger integer);

#pragma mark -
#pragma mark UNSIGNED INTS within UNSIGNED INTS

BOOL NSUIntegerContainsNSRange(NSUInteger integer, NSRange range);
BOOL NSUIntegerContainsTwoNSUIntegers(NSUInteger integer, NSUInteger from, NSUInteger to);
BOOL NSUIntegerContainsNSUInteger(NSUInteger integer, NSUInteger num);

#pragma mark -
#pragma mark SIGNED INTS within UNSIGNED INTS

BOOL NSUIntegerContainsTwoNSIntegers(NSUInteger integer, NSInteger from, NSInteger to);
BOOL NSUIntegerContainsNSInteger(NSUInteger integer, NSInteger num);

