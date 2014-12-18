//
//  Game.h
//  PencuSe
//
//  Created by Ahmet Karalar on 3/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BaseModel.h"

@class Move, Checker;

@interface Game : BaseModel

@property (nonatomic, readonly) NSArray *checkers;

+ (instancetype)newGame;

- (instancetype)initWithCheckers:(NSArray *)checkers;

- (BOOL)isMoveLegal:(Move *)move;

// returns the checker to hit with move, or nil
- (Checker *)makeMove:(Move *)move;


@end
