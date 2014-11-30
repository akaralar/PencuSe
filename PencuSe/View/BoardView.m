//
//  BoardView.m
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import "BoardView.h"
#import "PointView.h"
#import "Masonry.h"

// A point is the slot a checker can move to
static const NSInteger kNumberOfPoints = 24;

// 12 points plus middle bar and side paddings equal to 2 point widths in total
static const CGFloat kPointWidthToTotalWidthRatio = 1 / 14.0;

// 0.1 of total height is board padding (0.05 on top and bottom each)
// there are 2 rows of points, (1 - 0.1) / 2 = 0.45
static const CGFloat kPointHeightToTotalHeightRatio = 0.45;

@interface BoardView ()

@property (nonatomic) NSMutableArray *points;
@property (nonatomic) NSMutableArray *checkers;

@end

@implementation BoardView

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (!self) {
        return nil;
    }

    self.backgroundColor = [UIColor colorWithRed:(CGFloat)0.563
                                           green:(CGFloat)0.332
                                            blue:(CGFloat)0.264
                                           alpha:1];

    _points = [NSMutableArray array];

    for (NSInteger i = 0; i < kNumberOfPoints; ++i) {

        PointView *pointView = [[PointView alloc] initWithFrame:CGRectZero];
        pointView.pointColor = (i % 2 == 0) ? PointColorRed : PointColorWhite;
        pointView.pointDirection = i / (kNumberOfPoints / 2.0) < 1 ? PointDirectionDown : PointDirectionUp;
        [_points addObject:pointView];
        [self addSubview:pointView];


        CGFloat leftPaddingMultiplier = kPointWidthToTotalWidthRatio / 2;
        CGFloat leftEdgeMultiplier;
        if (i < kNumberOfPoints / 2) {

            leftEdgeMultiplier = leftPaddingMultiplier + (i * kPointWidthToTotalWidthRatio);
        }
        else {
            leftEdgeMultiplier = leftPaddingMultiplier + ((kNumberOfPoints - i - 1) * kPointWidthToTotalWidthRatio);
        }

        if (i >= kNumberOfPoints / 4 &&
            i < kNumberOfPoints - (kNumberOfPoints / 4)) {
            leftEdgeMultiplier += 2 * leftPaddingMultiplier;
        }

        CGFloat topPaddingMultiplier = (1 - 2 * kPointHeightToTotalHeightRatio) / 2.0;
        CGFloat topEdgeMultiplier = topPaddingMultiplier + i / (kNumberOfPoints / 2) * kPointHeightToTotalHeightRatio;

        [pointView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.left.equalTo(self.mas_right).multipliedBy(leftEdgeMultiplier);
            make.top.equalTo(self.mas_bottom).multipliedBy(topEdgeMultiplier);
            make.width.equalTo(self.mas_width).multipliedBy(kPointWidthToTotalWidthRatio);
            make.height.equalTo(self.mas_height).multipliedBy(kPointHeightToTotalHeightRatio);

        }];
    }
    
    return self;
}

@end
