//
//  N4TextViewAppDelegate.h
//  N4TextView
//
//  Created by Enriquez Guillermo on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class N4TextViewViewController;

@interface N4TextViewAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet N4TextViewViewController *viewController;

@end
