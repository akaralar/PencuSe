//
//  Checker.h
//  PencuSe
//
//  Created by Ahmet Karalar on 3/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BaseModel.h"

typedef NS_ENUM(NSInteger, CheckerColor) {
    CheckerColorRed,
    CheckerColorBlack
};

@interface Checker : BaseModel

@property (nonatomic) CheckerColor color;
@property (nonatomic) NSInteger index;

@end
