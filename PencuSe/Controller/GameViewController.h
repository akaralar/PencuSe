//
//  GameViewController.h
//  PencuSe
//
//  Created by Ahmet Karalar on 30/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, GameMode) {
    GameModeMultiplayer
};

@interface GameViewController : BaseViewController

- (instancetype)initWithGameMode:(GameMode)mode;

@end
