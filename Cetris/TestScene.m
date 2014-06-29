
//
//  TestScene.m
//  Cetris
//
//  Created by Bob  on 14-6-29.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "TestScene.h"

@implementation TestScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        SKShapeNode *node = [SKShapeNode node];
        node.position = CGPointMake(100, 100);
        node.path = [self createMovingPath:node.position velocity:CGPointMake(20, 20) acceleration:CGPointMake(0, -10)];
        node.strokeColor = [UIColor redColor];
        [self addChild:node];
    }
    
    return self;
}

-(CGMutablePathRef) createMovingPath:(CGPoint) position velocity:(CGPoint)velocity acceleration:(CGPoint) acceleration {
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, position.x, position.y);
    
    //CGPathAddLineToPoint(pathRef, NULL, 100, 100);
    float dt = 0.1;
    // 10 steps, 1 second
    for (int i=0; i<100; i++) {
        position = skpAdd(position, skpMultiply(velocity, dt));
        velocity = skpAdd(velocity, skpMultiply(acceleration, dt));
        
        CGPathAddLineToPoint(pathRef, NULL, position.x, position.y);
    }

    return pathRef;
}




@end





