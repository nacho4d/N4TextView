//
//  N4TextRange.h
//  N4TextView
//
//  Created by Ignacio Enriquez Gutierrez on 7/6/10.
//  Copyright 2010 Nacho4D. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface N4TextRange : UITextRange <NSCopying>
{
	NSRange _range;
}
@property (nonatomic) NSRange range;
@property(nonatomic, readonly, getter=isEmpty) BOOL empty;

- (N4TextRange *)init;
- (N4TextRange *)initWithNSRange:(NSRange)nsrange;
+ (N4TextRange *)rangeWithNSRange:(NSRange)nsrange;
+ (N4TextRange *)rangeFromPosition:(UITextPosition *)fromPosition
						toPosition:(UITextPosition *)toPosition;

@end

NSString *NSStringFromUITextRange(UITextRange *range);