//
//  PhysicsHelper.h
//  Cetris
//
//  Created by Bob  on 14-6-29.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhysicsHelper : NSObject

+(CGMutablePathRef) createMovingPath:(CGPoint) position
                            velocity:(CGPoint)velocity
                        acceleration:(CGPoint) acceleration
                               steps:(int) steps
                           deltaTime:(float) dt;
@end
