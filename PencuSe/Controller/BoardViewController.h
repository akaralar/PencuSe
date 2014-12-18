//
//  BoardViewController.h
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BaseViewController.h"

@class Move;
@protocol BoardRules;

@interface BoardViewController : BaseViewController

@property (nonatomic) id <BoardRules> ruleDelegate;

@end

@protocol BoardRules <NSObject>

- (BOOL)boardViewController:(BoardViewController *)controller
        isAllowedToMakeMove:(Move *)move;

@end

