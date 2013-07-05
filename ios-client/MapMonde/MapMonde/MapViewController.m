//
//  MapViewController.m
//  MapMonde
//
//  Created by Amadour Griffais (MIA) on 05/07/13.
//  Copyright (c) 2013 Le Monde Interactif. All rights reserved.
//

#import "MapViewController.h"

#import "GameController.h"
#import "JoinViewController.h"

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet UILabel *questionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionCongratsLabel;

@end

@implementation MapViewController

//**************************************************************************
#pragma mark - init, dealloc

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [[GameController sharedInstance] addObserver:self
                                          forKeyPath:@"currentState"
                                             options:0
                                             context: (__bridge void*)[self class]];
    }
    return self;
}

- (void) dealloc
{
    [[GameController sharedInstance] removeObserver:self
                                         forKeyPath:@"currentState"
                                            context: (__bridge void*)[self class]];
}

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
    
    [self handleGameStateChange];
}

//**************************************************************************
#pragma mark - KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [GameController sharedInstance] && [keyPath isEqualToString:@"currentState"] && context == (__bridge void*)[self class])
    {
        [self handleGameStateChange];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

//**************************************************************************
#pragma mark - Game logic

- (void) handleGameStateChange
{
    switch ([[GameController sharedInstance] currentState]) {
        case GameStateRequireJoin: {
            [self showJoinViewController];
            return; }
        case GameStateJoining: {

            return; }
        case GameStateWaitingForQuestion: {
            [self hideJoinViewController];
            [self showResults];
            return; }
        case GameStateQuestionInProgress: {
            [self hideJoinViewController];
            [self showQuestion];
            return; }
        default:
            break;
    }
}

//**************************************************************************
#pragma mark - navigation

- (void) showJoinViewController
{
    if ([self.presentedViewController isKindOfClass:[JoinViewController class]])
        return;
    
    if (self.presentedViewController)
        [self dismissViewControllerAnimated:NO completion:nil];
    
    UIViewController* vc = [JoinViewController new];
    vc.modalPresentationStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?UIModalPresentationFormSheet:UIModalPresentationCurrentContext;
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) hideJoinViewController
{
    if (![self.presentedViewController isKindOfClass:[JoinViewController class]])
        return;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


//**************************************************************************
#pragma mark - game layout

- (void) showQuestion
{
    NSString* questionTitle = [NSString stringWithFormat:@"QUESTION %d :", [[GameController sharedInstance] questionIdentifier]];
    NSString* questionText = [[GameController sharedInstance] question];
    self.questionTitleLabel.text = questionTitle;
    self.questionTextLabel.text = questionText;
    self.questionCongratsLabel.text = nil;
}

- (void) showResults
{
    NSString* questionTitle = [NSString stringWithFormat:@"RÉPONSE QUESTION %d :", [[GameController sharedInstance] questionIdentifier]];
    NSString* questionText = @"Hello";
    self.questionTitleLabel.text = questionTitle;
    self.questionTextLabel.text = questionText;
    self.questionCongratsLabel.text = @"Bravo";
}

@end
