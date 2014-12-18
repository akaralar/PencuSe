//
//  Move.h
//  PencuSe
//
//  Created by Ahmet Karalar on 3/12/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BaseModel.h"

@class Checker;

@interface Move : BaseModel

@property (nonatomic, readonly) Checker *checker;
@property (nonatomic, readonly) NSInteger pips;
@property (nonatomic, readonly) NSInteger indexAfterMove;

- (instancetype)initWithChecker:(Checker *)checker pips:(NSInteger)pips;

@end
