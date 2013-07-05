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

#import <MapKit/MapKit.h>

#define SUCCCESS_COLOR [UIColor colorWithRed:0. green:192./255. blue:228./255. alpha:1.]
#define FAILURE_COLOR [UIColor colorWithRed:239./255. green:75./255. blue:115./255. alpha:1.]
#define QUESTION_COLOR [UIColor colorWithRed:0./255. green:89./255. blue:104./255. alpha:1.]

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *questionCongratsLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) NSTimer* 		timerRefreshTimer;
@property (strong, nonatomic) GameLocation* answer;

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
        self.answer = [GameLocation new];
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

    [self resetMapRegionAnimated:NO];
    
    //setup the tap gesture to play
    UITapGestureRecognizer* gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMapTap:)];
    [self.mapView addGestureRecognizer:gr];
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
            self.timerRefreshTimer = nil;
            return; }
        case GameStateJoining: {
            self.timerRefreshTimer = nil;
            return; }
        case GameStateWaitingForQuestion: {
            [self hideJoinViewController];
            [self showResults];
            [self showCorrectAnswer];
            self.timerRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(refreshTimer) userInfo:nil repeats:YES];
            return; }
        case GameStateQuestionInProgress: {
            [self hideJoinViewController];
            [self showQuestion];
            [self resetMap];
            self.timerRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(refreshTimer) userInfo:nil repeats:YES];
            return; }
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
    NSString* questionText = [[GameController sharedInstance] success]?nil:[NSString stringWithFormat:@"Tu est à %d km de la bonne réponse", (int)([[GameController sharedInstance] correctAnswerDistance]/1000)];
    self.questionTitleLabel.text = questionTitle;
    self.questionTextLabel.text = questionText;
    self.questionTextLabel.textColor = [[GameController sharedInstance] success]?SUCCCESS_COLOR:FAILURE_COLOR;
    self.questionCongratsLabel.text = [[GameController sharedInstance] success]?@"BRAVO !":@"DOMMAGE !";
    self.questionCongratsLabel.textColor = [[GameController sharedInstance] success]?SUCCCESS_COLOR:FAILURE_COLOR;
}

- (void) resetMapRegionAnimated:(BOOL)animated
{
    //make the map display the whole world
    MKCoordinateRegion worldRegion;
    worldRegion.center.latitude = 48.856578;
    worldRegion.center.longitude = 2.351828;
    worldRegion.span.latitudeDelta = 180;
    worldRegion.span.longitudeDelta = 360;
    [self.mapView setRegion:worldRegion animated:animated];
}

- (void) showAnswer
{
    [self.mapView removeAnnotation:self.answer];
    [self.mapView addAnnotation:self.answer];
}

- (void) showCorrectAnswer
{
    if (![[GameController sharedInstance] correctAnswer])
        return;
    
    [self.mapView addAnnotation:[[GameController sharedInstance] correctAnswer]];
}

- (void) resetMap
{
    [self resetMapRegionAnimated:YES];
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void) refreshTimer
{
    NSTimeInterval timeLeft = [[GameController sharedInstance] timeLeftInCurrentState];
    self.timerLabel.hidden = timeLeft <= 0;
    self.timerLabel.text = [NSString stringWithFormat:@"%.0f", ceil(timeLeft)];
}

- (void) setTimerRefreshTimer:(NSTimer *)timerRefreshTimer
{
    [_timerRefreshTimer invalidate];
    _timerRefreshTimer = timerRefreshTimer;
}

//**************************************************************************
#pragma mark - actions

- (IBAction)handleMapTap:(UITapGestureRecognizer*)gestureRecognizer
{
    //do nothing if the current game state is not a question
    if ([[GameController sharedInstance] currentState] != GameStateQuestionInProgress)
        return;
    
    self.answer.coordinate = [self.mapView convertPoint:[gestureRecognizer locationInView:self.mapView] toCoordinateFromView:self.mapView];
    [[GameController sharedInstance] answerQuestion:self.answer];
    
    //display on the map
    [self showAnswer];
}

- (void)viewDidUnload {
    [self setTimerLabel:nil];
    [super viewDidUnload];
}
@end
