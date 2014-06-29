//
//  PhysicsHelper.m
//  Cetris
//
//  Created by Bob  on 14-6-29.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "PhysicsHelper.h"

@implementation PhysicsHelper

+(CGMutablePathRef) createMovingPath:(CGPoint) position
                            velocity:(CGPoint)velocity
                        acceleration:(CGPoint) acceleration
                               steps:(int) steps
                           deltaTime:(float) dt {
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, NULL, position.x, position.y);
    
    for (int i=0; i<steps; i++) {
        position = skpAdd(position, skpMultiply(velocity, dt));
        velocity = skpAdd(velocity, skpMultiply(acceleration, dt));
        
        CGPathAddLineToPoint(pathRef, NULL, position.x, position.y);
    }
    
    return pathRef;
}


@end
