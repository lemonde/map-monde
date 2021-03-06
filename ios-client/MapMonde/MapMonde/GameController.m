//
//  GameController.m
//  MapMonde
//
//  Created by Amadour Griffais (MIA) on 05/07/13.
//  Copyright (c) 2013 Le Monde Interactif. All rights reserved.
//

#import "GameController.h"

#import "SocketIO.h"
#import "SocketIOPacket.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

//#define SERVER_HOSTNAME 	@"172.30.1.199"
//#define SERVER_PORT 		3000
#define SERVER_HOSTNAME 	@"localhost"
#define SERVER_PORT 		3000

#define SUCCESS_DISTANCE_METERS 1000.*1000.

NSString* GameControllerErrorNotification = @"GameControllerErrorNotification";

@interface  GameController() <SocketIODelegate>

@property (nonatomic, readwrite) 	GameState currentState;

@property (nonatomic, strong)		NSString* nickname;
@property (nonatomic, strong)		NSString* question;
@property (nonatomic)				NSInteger questionIdentifier;
@property (nonatomic)				GameLocation* answer;
@property (nonatomic)				NSDate* questionEndTime;

@property (nonatomic, strong) 		NSArray* results;
@property (nonatomic, readwrite) 	GameLocation* correctAnswer;
@property (nonatomic, readwrite) 	BOOL success;
@property (nonatomic, readwrite) 	CLLocationDistance correctAnswerDistance;
@property (nonatomic)				NSDate* resultsEndTime;

@end

@implementation GameController
{
    SocketIO* _gameSocket;
}

//**************************************************************************
#pragma mark - init, dealloc

+ (id)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.currentState = GameStateRequireJoin;
    }
    return self;
}

- (void) dealloc
{
    [self quitGame];
}

//**************************************************************************
#pragma mark - joining game

- (void) joinGameWithNickname:(NSString*)nickname
{
    if (self.currentState != GameStateRequireJoin)
        return;
    
    _gameSocket = [[SocketIO alloc] initWithDelegate:self];
    [_gameSocket connectToHost:SERVER_HOSTNAME onPort:SERVER_PORT];
    
    //set the current game nickname
    self.nickname = nickname;
    
    [self sendJoinEvent];
    
    self.currentState = GameStateJoining;
}

- (void) quitGame
{
    [_gameSocket disconnect];
    _gameSocket = nil;
    
    self.currentState = GameStateRequireJoin;
}

//**************************************************************************
#pragma mark - answering

- (void) answerQuestion:(GameLocation*)answer;
{
    if (self.currentState != GameStateQuestionInProgress)
        return;
    
    self.answer = answer;
    
    [self sendAnswerEvent];
}

//**************************************************************************
#pragma mark - timer management

- (NSTimeInterval) timeLeftInCurrentState
{
    NSDate* endDate = nil;
    if (self.currentState == GameStateWaitingForQuestion)
        endDate = self.resultsEndTime;
    if (self.currentState == GameStateQuestionInProgress)
        endDate = self.questionEndTime;
    
    if (!endDate)
        return -1;
    
    return [endDate timeIntervalSinceNow];
}



//**************************************************************************
#pragma mark - event sending

- (void) sendJoinEvent
{
    if (!self.nickname)
        return;
    NSDictionary* joinArguments = @{@"nickname":self.nickname};
    [_gameSocket sendEvent:@"join" withData:joinArguments];
}

- (void) sendAnswerEvent
{
    NSDictionary* answerArguments = @{@"answer":[self.answer JSONSerialization],
                                      @"questionId":@(self.questionIdentifier)};
    [_gameSocket sendEvent:@"answer" withData:answerArguments];
}

//**************************************************************************
#pragma mark - event handling

- (void) handleJoinStatusEvent:(NSDictionary*)data
{
    if (![data[@"error"] isEqual:@NO]) {
        self.currentState = GameStateRequireJoin;
        return;
    }
    
    self.currentState = GameStateWaitingForQuestion;
}

- (void) handleQuestionEvent:(NSDictionary*)data
{
    if (self.currentState != GameStateWaitingForQuestion)
        return;
    
    if (!([data[@"question"] isKindOfClass:[NSString class]] && [data[@"id"] isKindOfClass:[NSNumber class]]))
        return;
    
    //set the question properties
    self.question = data[@"question"];
    self.questionIdentifier = [data[@"id"] integerValue];
    
    NSDate* endTime = nil;
    if ([data[@"time"] isKindOfClass:[NSNumber class]])
        endTime = [NSDate dateWithTimeIntervalSinceNow:[data[@"time"] doubleValue]];
    self.questionEndTime = endTime;
    
    //reset answer related properties
    self.answer = nil;
    self.correctAnswer = nil;
    self.results = nil;
    
    self.currentState = GameStateQuestionInProgress;
}

- (void) handleResultEvent:(NSDictionary*)data
{
    if (!self.currentState == GameStateQuestionInProgress)
        return;
    
    if (![data[@"questionId"] isKindOfClass:[NSNumber class]])
        return;
    
    NSInteger questionId = [data[@"questionId"] integerValue];
    if (questionId != self.questionIdentifier)
        return;
    
    if (!data[@"solve"])
        return;
    
    GameLocation* answer = [GameLocation gameLocationWithJSON:data[@"solve"]];
    
    NSDate* endTime = nil;
    if ([data[@"time"] isKindOfClass:[NSNumber class]])
        endTime = [NSDate dateWithTimeIntervalSinceNow:[data[@"time"] doubleValue]];
    self.resultsEndTime = endTime;
    
    self.correctAnswer = answer;
    BOOL success = NO;
    CLLocationDistance distance = -1;
    if (self.answer && self.correctAnswer)
    {
        CLLocation* loc1 = [[CLLocation alloc] initWithLatitude:self.answer.coordinate.latitude longitude:self.answer.coordinate.longitude];
        CLLocation* loc2 = [[CLLocation alloc] initWithLatitude:self.correctAnswer.coordinate.latitude longitude:self.correctAnswer.coordinate.longitude];
        distance = [loc1 distanceFromLocation:loc2];
        success = distance < SUCCESS_DISTANCE_METERS;
    }
    self.success = success;
    self.correctAnswerDistance = distance;
    
    self.results = [data[@"ranking"] isKindOfClass:[NSArray class]]?data[@"ranking"]:nil;
    
    self.currentState = GameStateWaitingForQuestion;
}

//**************************************************************************
#pragma mark - error handling

- (void) handleJoinError:(NSError*)error
{
    //notifiy
    [[NSNotificationCenter defaultCenter] postNotificationName:GameControllerErrorNotification
                                                        object:self
                                                      userInfo:@{@"error":[NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:0 userInfo:@{@"NSLocalizedDescription":@"Impossible de rejoindre la partie"}]}];
    self.currentState = GameStateRequireJoin;
}

//**************************************************************************
#pragma mark - SocketIODelegate

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"socketIODidConnect");
}
- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    NSLog(@"socketIODidDisconnect");
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    id data = [packet args][0];
    if (!([data isKindOfClass:[NSDictionary class]] || data == nil))
        return;
    
    if ([packet.name isEqualToString:@"join-status"])
        [self handleJoinStatusEvent:data];
    else if ([packet.name isEqualToString:@"question"])
        [self handleQuestionEvent:data];
    else if ([packet.name isEqualToString:@"result"])
        [self handleResultEvent:data];
    return;
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
{
    NSLog(@"didSendMessage");
}
- (void) socketIO:(SocketIO *)socket onError:(NSError *)error
{
    switch (self.currentState) {
        case GameStateJoining: {
            [self handleJoinError:error];
            return;
        default:
            break;
        }
    }
}


@end
