//
//  N4TextViewAppDelegate.h
//  N4TextView
//
//  Created by Enriquez Guillermo on 7/31/11.
//  Copyright 2011 nacho4d. All rights reserved.
//

#import <UIKit/UIKit.h>

@class N4TextViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet N4TextViewController *viewController;

@end
