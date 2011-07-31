//
//  N4TextViewViewController.m
//  N4TextView
//
//  Created by Enriquez Guillermo on 7/31/11.
//  Copyright 2011 nacho4d. All rights reserved.
//

#import "N4TextViewController.h"
#import "N4CoreTextView.h"

@implementation N4TextViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	N4CoreTextView *textView = [[N4CoreTextView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 250)];
	[self.view addSubview:textView];
	[textView release];

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
