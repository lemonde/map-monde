//
//  JoinViewController.m
//  MapMonde
//
//  Created by Amadour Griffais (MIA) on 05/07/13.
//  Copyright (c) 2013 Le Monde Interactif. All rights reserved.
//

#import "JoinViewController.h"

#import "GameController.h"

@interface JoinViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;

@end

@implementation JoinViewController

//**************************************************************************
#pragma mark - view lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.nicknameTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"MapMondePreviousNickname"];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.nicknameTextField becomeFirstResponder];
}


//**************************************************************************
#pragma mark - actions

- (IBAction)joinGame:(id)sender {
    if ([[self.nicknameTextField text] length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"Veuillez indiquer votre pseudo", nil)
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    
    [[GameController sharedInstance] joinGameWithNickname:self.nicknameTextField.text];
    [[NSUserDefaults standardUserDefaults] setObject:self.nicknameTextField.text forKey:@"MapMondePreviousNickname"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.nicknameTextField resignFirstResponder];
}

@end
