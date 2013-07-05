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

//#define SERVER_HOSTNAME 	@"172.30.1.55"
//#define SERVER_PORT 		2828
#define SERVER_HOSTNAME 	@"localhost"
#define SERVER_PORT 		3000

@interface  GameController() <SocketIODelegate>

@property (nonatomic, readwrite) 	GameState currentState;

@property (nonatomic, strong)		NSString* nickname;
@property (nonatomic, strong)		NSString* question;
@property (nonatomic)				NSInteger questionIdentifier;
@property (nonatomic)				CLLocationCoordinate2D answer;

@property (nonatomic, strong) 		NSArray* results;
@property (nonatomic, readwrite) 	CLLocationCoordinate2D correctAnswer;


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

- (void) answerQuestion:(CLLocationCoordinate2D)answer;
{
    if (self.currentState != GameStateQuestionInProgress)
        return;
    
    self.answer = answer;
    
    [self sendAnswerEvent];
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
    NSDictionary* answerArguments = @{@"answer":[self jsonFromLocationCoordinates:self.answer]};
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
    
    //reset answer related properties
    CLLocationCoordinate2D location;
    location.latitude = 0;
    location.longitude = 0;
    self.answer = location;
    self.correctAnswer = location;
    self.results = nil;
    
    self.currentState = GameStateQuestionInProgress;
}

- (void) handleResultEvent:(NSDictionary*)data
{
    if (!self.currentState == GameStateQuestionInProgress)
        return;
    
    if ([data[@"questionId"] isKindOfClass:[NSNumber class]])
        return;
    
    NSInteger questionId = [data[@"questionId"] integerValue];
    if (questionId != self.questionIdentifier)
        return;
    
    if (!data[@"answer"])
        return;
    
    CLLocationCoordinate2D answer = [self locationCoordinatesFromJSON:data[@"answer"]];
    
    
    self.correctAnswer = answer;
    self.results = [data[@"ranking"] isKindOfClass:[NSArray class]]?data[@"ranking"]:nil;
    
    self.currentState = GameStateWaitingForQuestion;
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
    id data = [packet dataAsJSON];
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
    NSLog(@"onError");
}

//**************************************************************************
#pragma mark - CLLocation helpers

- (NSDictionary*) jsonFromLocationCoordinates:(CLLocationCoordinate2D)location
{
    return @{@"lat": @(location.latitude), @"long": @(location.longitude)};
}

- (CLLocationCoordinate2D) locationCoordinatesFromJSON:(id)json
{
    CLLocationCoordinate2D location;
    location.latitude = 0;
    location.longitude = 0;
    if ([json isKindOfClass:[NSDictionary class]] && [json[@"lat"] isKindOfClass:[NSNumber class]] && [json[@"long"] isKindOfClass:[NSNumber class]]) {
        location.latitude = [json[@"lat"] doubleValue];
        location.longitude = [json[@"long"] doubleValue];
    }
    return location;
}


@end
