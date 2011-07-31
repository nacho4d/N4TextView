//
//  N4CoreTextView.h
//  N4TextView
//
//  Created by Guillermo Ignacio Enriquez Gutierrez on 8/18/10.
//  Copyright 2010 Nacho4d. All rights reserved.
//

#import <Foundation/Foundation.h>
@class N4CoreTextViewInternal;

@interface N4CoreTextView : UIScrollView {

@private
	N4CoreTextViewInternal *_textView;

}
@property (nonatomic, retain) NSString *text;

- (id) initWithFrame:(CGRect)aFrame;

@end
