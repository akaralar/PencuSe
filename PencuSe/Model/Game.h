//
//  Game.h
//  PencuSe
//
//  Created by Ahmet Karalar on 3/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BaseModel.h"
#import "Move.h"

@interface Game : BaseModel

@property (nonatomic, readonly) NSArray *checkers;
@property (nonatomic, readonly) NSArray *dice;

/**
 *  Starting a game
 */
- (void)newGame;

/**
 *  Actions
 */
- (void)roll;
- (void)makeMove:(Move *)move;

/**
 *  Game Mechanics
 */
- (BOOL)isLegal:(Move *)move;





@end
