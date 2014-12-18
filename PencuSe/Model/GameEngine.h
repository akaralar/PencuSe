//
//  GameEngine.h
//  PencuSe
//
//  Created by Ahmet Karalar on 4/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BaseModel.h"
// import Checker class to have access CheckerColor enum
#import "Checker.h"

FOUNDATION_EXPORT NSString * const DidStartGame;
FOUNDATION_EXPORT NSString * const DidRollInitialDiceForRed;
FOUNDATION_EXPORT NSString * const DidRollInitialDiceForBlack;
FOUNDATION_EXPORT NSString * const WillRerollInitialDice;
FOUNDATION_EXPORT NSString * const DidRollDice;
FOUNDATION_EXPORT NSString * const DidMakeMove;
FOUNDATION_EXPORT NSString * const DidHitBlot;
FOUNDATION_EXPORT NSString * const DidFinishTurn;
FOUNDATION_EXPORT NSString * const DidRunOutOfMoves;

@class Game, Move;

@interface GameEngine : BaseModel

@property (nonatomic, readonly) NSArray *dice;
@property (nonatomic, readonly) Game *game;
@property (nonatomic, readonly) CheckerColor movingColor;
@property (nonatomic, readonly) CheckerColor opponentColor;
@property (nonatomic, readonly, getter = isWaitingForRoll) BOOL waitingForRoll;

+ (instancetype)sharedEngine;

- (void)newGame;
- (void)roll;
- (BOOL)canMoveCheckerAtIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx;
- (void)moveCheckerAtIndex:(NSInteger)fromIdx toIndex:(NSInteger)toIdx;

@end
