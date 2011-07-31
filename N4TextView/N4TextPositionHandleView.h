//
//  N4TextPositionHandleView.h
//  N4TextView
//
//  Created by Ignacio Enriquez Gutierrez on 7/24/10.
//  Copyright 2010 Nacho4D. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    N4TextPositionHandleTypeStart = 0,
    N4TextPositionHandleTypeEnd,
} N4TextPositionHandleType;

@interface N4TextPositionHandleView : UIImageView {
	N4TextPositionHandleType type;
}

@property (nonatomic) N4TextPositionHandleType type;

- (id) initWithType:(N4TextPositionHandleType)aType;

- (void) showInCaretRect:(CGRect)rect;

@end
