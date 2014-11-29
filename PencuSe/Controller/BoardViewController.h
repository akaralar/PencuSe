//
//  BoardViewController.h
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, GameMode) {
    GameModeMultiplayer
};

@interface BoardViewController : BaseViewController

- (instancetype)initWithGameMode:(GameMode)mode;

@end
