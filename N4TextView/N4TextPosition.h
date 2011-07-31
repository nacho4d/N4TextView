//
//  N4TextPosition.h
//  N4TextView
//
//  Created by Ignacio Enriquez Gutierrez on 7/6/10.
//  Copyright 2010 Nacho4D. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface N4TextPosition : UITextPosition <NSCopying>
{
	NSUInteger _index;
}
@property (nonatomic) NSUInteger index;
- (N4TextPosition *)initWithIndex:(NSUInteger)index;
+ (N4TextPosition *)positionWithIndex:(NSUInteger)index;

@end

NSString *NSStringFromUITextPosition(UITextPosition *position);