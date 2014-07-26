//
//  Car.h
//  Cetris
//
//  Created by Wan Wei on 14/6/29.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol CarDelegate

@optional
-(void)didPositionChanged:(SKSpriteNode*) car Position:(CGPoint) position;

@end

@interface Car : SKSpriteNode

@property (nonatomic, assign) BOOL isLeft;
@property (nonatomic, assign) int carId;
@property (nonatomic, assign) id  delegate;

+(instancetype) carWithId:(int64_t) carId IsLeft:(BOOL)isLeft;

-(void)takeTurn:(BOOL)take;


@end
