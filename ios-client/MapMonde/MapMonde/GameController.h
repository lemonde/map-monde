//
//  GameController.h
//  MapMonde
//
//  Created by Amadour Griffais (MIA) on 05/07/13.
//  Copyright (c) 2013 Le Monde Interactif. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

extern NSString* GameControllerErrorNotification;

typedef enum {
    GameStateRequireJoin,
    GameStateJoining,
    GameStateWaitingForQuestion,
    GameStateQuestionInProgress
} GameState;

@interface GameController : NSObject

+ (id) sharedInstance;

//state (KVO observable)
@property (nonatomic, readonly) GameState currentState;

//joining/disconnecting
- (void) joinGameWithNickname:(NSString*)nickname;
- (void) quitGame;

//getting information about the current game
@property (nonatomic, readonly) NSString* question;
@property (nonatomic, readonly)	NSInteger questionIdentifier;
- (void) answerQuestion:(CLLocationCoordinate2D)answer;

//getting the scores of the previous question
@property (nonatomic, readonly) NSArray* results;
@property (nonatomic, readonly) CLLocationCoordinate2D correctAnswer;

@end
