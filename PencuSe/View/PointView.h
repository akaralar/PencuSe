//
//  PointView.h
//  PencuSe
//
//  Created by Ahmet Karalar on 29/11/14.
//  Copyright (c) 2014 Ahmet Karalar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PointDirection) {
    PointDirectionUp,
    PointDirectionDown
};

typedef NS_ENUM(NSInteger, PointColor) {
    PointColorRed,
    PointColorWhite
};

@interface PointView : UIView

@property (nonatomic) PointDirection pointDirection;
@property (nonatomic) PointColor pointColor;

@end
