//
//  Move.h
//  PencuSe
//
//  Created by Ahmet Karalar on 3/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BaseModel.h"

typedef struct {
    NSInteger index;
    NSInteger offset;
} MoveRange;

@class Checker;

@interface Move : BaseModel

@property (nonatomic) Checker *checker;
@property (nonatomic) MoveRange *range;

@end
