//
//  MapViewController.m
//  MapMonde
//
//  Created by Amadour Griffais (MIA) on 05/07/13.
//  Copyright (c) 2013 Le Monde Interactif. All rights reserved.
//

#import "MapViewController.h"

#import "JoinViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

//**************************************************************************
#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self presentViewController:[[JoinViewController alloc] init] animated:YES completion:nil];
}

@end
