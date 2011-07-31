/*
 *  NSRangeEntensions.m
 *  N4TextView
 *
 *  Created by Enriquez Gutierrez Guillermo Ignacio on 7/2/10.
 *  Copyright 2010 Nacho4D. All rights reserved.
 *
 */

#import "NSRangeEntensions.h"

#pragma mark -
#pragma mark NSRange helpers

NSUInteger NSRangeGetMin(NSRange range){
	return range.location;
}
NSUInteger NSRangeGetMax(NSRange range){
	return range.location + range.length;
}
BOOL NSRangeContainsNSUInteger(NSRange range, NSUInteger integer){
	BOOL res = (range.location != NSNotFound) && (range.location <= integer) && (integer <= range.location + range.length);
	if (!res) {
		NSLog(@"::::::::::ERROR:::::::::: NSRange does not contains integer :%@, %u", NSStringFromRange(range), integer);
	}
	return res;
}
#pragma mark -

BOOL NSUIntegerContainsNSRange(NSUInteger integer, NSRange range){
	//return ( 0 <= NSRangeGetMin(range) ) && ( NSRangeGetMax(range) <= integer );
	NSUInteger min = NSRangeGetMin(range);
	NSUInteger max = NSRangeGetMax(range);
	BOOL res = ( 0 <= min ) && ( max <= integer ) && (range.location != NSNotFound);
	if (!res) {
		NSLog(@"::::::::::ERROR:::::::::: NSUInteger does not contain NSRange :%u, %@", integer, NSStringFromRange(range));
	}
	return res;
}
BOOL NSUIntegerContainsTwoNSUIntegers(NSUInteger integer, NSUInteger from, NSUInteger to){
	//return ( 0 <= from ) && ( to <= integer );
	BOOL res = ( 0 <= from ) && ( to <= integer );
	if (!res) {
		NSLog(@"::::::::::ERROR:::::::::: NSUInteger does not contain 2 uints :%u, {%u %u}", integer, from, to);
	}
	return res;
}
BOOL NSUIntegerContainsNSUInteger(NSUInteger integer, NSUInteger num){
	BOOL res = ( num <= integer );
	if (!res) {
		NSLog(@"::::::::::ERROR:::::::::: NSUInteger does not contain uint :%u, {%u}", integer, num);
	}
	return res;
}

#pragma mark -

BOOL NSUIntegerContainsTwoNSIntegers(NSUInteger integer, NSInteger from, NSInteger to){
	//return ( 0 <= from ) && ( to <= 0 ) && (from <= integer ) && ( to <= integer );
	BOOL res = ( 0 <= from ) && ( 0 <= to ) && (from <= integer ) && ( to <= integer );
	if (!res) {
		NSLog(@"::::::::::ERROR:::::::::: NSUInteger does not contain 2 ints :%u, {%i %i}", integer, from, to);
	}
	return res;
}
BOOL NSUIntegerContainsNSInteger(NSUInteger integer, NSInteger num){
	BOOL res = ( 0 <= num ) && ( num <= integer );
	if (!res) {
		NSLog(@"::::::::::ERROR:::::::::: NSUInteger does not contain int :%u, {%i}", integer, num);
	}
	return res;
}
