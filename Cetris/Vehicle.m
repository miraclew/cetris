//
//  Vehicle.m
//  Cetris
//
//  Created by Wan Wei on 14/8/9.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "Vehicle.h"

@implementation Vehicle {

}

- (SKSpriteNode*) makeWheel
{
    SKSpriteNode *wheel = [SKSpriteNode spriteNodeWithImageNamed:@"wheel"];
    //    wheel.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:wheel.size.width/2];
    return wheel;
}

-(id)initWithPosition:(CGPoint)pos {
    
    if (self = [super init]) {
        
        _joints = [NSMutableArray array];
        
        int wheelOffsetY    =   60;
        CGFloat damping     =   1;
        CGFloat frequency   =   4;
        
        SKSpriteNode *chassis = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:CGSizeMake(120, 8)];
        chassis.position = pos;
        chassis.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:chassis.size];
        [self addChild:chassis];
        
        _ctop = [SKSpriteNode spriteNodeWithColor:[UIColor greenColor] size:CGSizeMake(70, 16)];
        _ctop.position = CGPointMake(chassis.position.x+20, chassis.position.y+12);
        _ctop.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_ctop.size];
        [self addChild:_ctop];
        
        SKPhysicsJointFixed *cJoint = [SKPhysicsJointFixed jointWithBodyA:chassis.physicsBody
                                                                    bodyB:_ctop.physicsBody
                                                                   anchor:CGPointMake(_ctop.position.x, _ctop.position.y)];
        
        
        _leftWheel = [self makeWheel];
        _leftWheel.position = CGPointMake(chassis.position.x - chassis.size.width / 2, chassis.position.y - wheelOffsetY);  //Always set position before physicsBody
        _leftWheel.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_leftWheel.size.width/2];
        _leftWheel.physicsBody.allowsRotation = YES;
        [self addChild:_leftWheel];
        
        SKSpriteNode *rightWheel = [self makeWheel];
        rightWheel.position = CGPointMake(chassis.position.x + chassis.size.width / 2, chassis.position.y - wheelOffsetY);
        rightWheel.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rightWheel.size.width/2];
        rightWheel.physicsBody.allowsRotation = YES;
        [self addChild:rightWheel];
        
        //------------- LEFT SUSPENSION ----------------------------------------------------------------------------------------------- //
        
        SKSpriteNode *leftShockPost = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(7, wheelOffsetY)];
        leftShockPost.position = CGPointMake(chassis.position.x - chassis.size.width / 2, chassis.position.y - leftShockPost.size.height/2);
        leftShockPost.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:leftShockPost.size];
        [self addChild:leftShockPost];
        
        SKPhysicsJointSliding  *leftSlide = [SKPhysicsJointSliding jointWithBodyA:chassis.physicsBody
                                                                            bodyB:leftShockPost.physicsBody
                                                                           anchor:CGPointMake(leftShockPost.position.x, leftShockPost.position.y)
                                                                             axis:CGVectorMake(0, 1)];
        
        leftSlide.shouldEnableLimits = TRUE;
        leftSlide.lowerDistanceLimit = 5;
        leftSlide.upperDistanceLimit = wheelOffsetY;
        
        
        SKPhysicsJointSpring *leftSpring = [SKPhysicsJointSpring jointWithBodyA:chassis.physicsBody bodyB:_leftWheel.physicsBody
                                                                        anchorA:CGPointMake(chassis.position.x - chassis.size.width / 2, chassis.position.y)
                                                                        anchorB:_leftWheel.position];
        leftSpring.damping = damping;
        leftSpring.frequency = frequency;
        
        SKPhysicsJointPin *lPin = [SKPhysicsJointPin jointWithBodyA:leftShockPost.physicsBody bodyB:_leftWheel.physicsBody anchor:_leftWheel.position];
        
        
        //------------- RIGHT SUSPENSION ----------------------------------------------------------------------------------------------- //
        
        SKSpriteNode *rightShockPost = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(7, wheelOffsetY)];
        rightShockPost.position = CGPointMake(chassis.position.x + chassis.size.width / 2, chassis.position.y - rightShockPost.size.height/2);
        rightShockPost.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rightShockPost.size];
        [self addChild:rightShockPost];
        
        SKPhysicsJointSliding  *rightSlide = [SKPhysicsJointSliding jointWithBodyA:chassis.physicsBody
                                                                             bodyB:rightShockPost.physicsBody
                                                                            anchor:CGPointMake(rightShockPost.position.x, rightShockPost.position.y)
                                                                              axis:CGVectorMake(0, 1)];
        
        rightSlide.shouldEnableLimits = TRUE;
        rightSlide.lowerDistanceLimit = 5;
        rightSlide.upperDistanceLimit = wheelOffsetY;
        
        
        SKPhysicsJointSpring *rightSpring = [SKPhysicsJointSpring jointWithBodyA:chassis.physicsBody bodyB:rightWheel.physicsBody
                                                                         anchorA:CGPointMake(chassis.position.x + chassis.size.width / 2, chassis.position.y)
                                                                         anchorB:rightWheel.position];
        rightSpring.damping = damping;
        rightSpring.frequency = frequency;
        
        SKPhysicsJointPin *rPin = [SKPhysicsJointPin jointWithBodyA:rightShockPost.physicsBody bodyB:rightWheel.physicsBody anchor:rightWheel.position];
        
        
        // Add all joints to the array.
        
        [_joints addObject:cJoint];
        
        [_joints addObject:leftSlide];
        [_joints addObject:leftSpring];
        [_joints addObject:lPin];
        
        [_joints addObject:rightSlide];
        [_joints addObject:rightSpring];
        [_joints addObject:rPin];
        
    }
    
    return self;
}


@end