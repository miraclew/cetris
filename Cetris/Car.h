//
//  Car.h
//  Cetris
//
//  Created by Wan Wei on 14/6/29.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Car : SKSpriteNode

+(instancetype) carWithId:(int) carId;

+(instancetype) leftCarWithId:(int) carId;
+(instancetype) rightCarWithId:(int) carId;


@property (nonatomic, assign) BOOL isLeft;
@property (nonatomic, assign) int carId;

@end
