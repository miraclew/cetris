//
//  Tank.m
//  Cetris
//
//  Created by Wan Wei on 14/8/9.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "Tank.h"

@implementation Tank {
    SKSpriteNode* _chassis;
    NSMutableArray* _wheels;
}

-(id)initWithPosition:(CGPoint)pos {
    if (self = [super initWithColor:nil size:CGSizeMake(100, 40)]) {
        _joints = [[NSMutableArray alloc] init];
        _wheels = [[NSMutableArray alloc] init];
        self.alpha = 0.5;
        
        _chassis = [SKSpriteNode spriteNodeWithImageNamed:@"tank"];
        _chassis.position = pos;
        _chassis.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(_chassis.size.width-20, _chassis.size.height-20)];
        _chassis.physicsBody.mass = 2;
        [self addChild:_chassis];
        
        _stick = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:CGSizeMake(50, 5)];
        _stick.position = CGPointMake(pos.x+25, pos.y+15);
        _stick.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_stick.size];
        [self addChild:_stick];
        
        CGPoint p = CGPointMake(_stick.position.x-_stick.size.width/2, _stick.position.y);
        SKPhysicsJointPin* pin = [SKPhysicsJointPin jointWithBodyA:_chassis.physicsBody bodyB:_stick.physicsBody anchor:p];
        pin.frictionTorque = 1.0;
        pin.shouldEnableLimits = YES;
        pin.lowerAngleLimit = 0;
        pin.upperAngleLimit = M_PI;
        
        [_joints addObject:pin];

        [self creatWheels];
    }
    
    return self;
}

-(void)setCollisionBitmask:(uint32_t)collisionBitmask {
    _chassis.physicsBody.categoryBitMask = collisionBitmask;
    _stick.physicsBody.categoryBitMask = collisionBitmask;
    
    for (SKSpriteNode* w in _wheels) {
        w.physicsBody.categoryBitMask = collisionBitmask;
    }
}

-(void)setZRotation:(CGFloat)zRotation {
    _chassis.zRotation = zRotation;
}

-(void)setTowerRotation:(CGFloat)towerRotation {
    if (towerRotation > M_PI) {
        towerRotation = M_PI;
    }
    if (towerRotation < 0) {
        towerRotation = 0;
    }
    NSLog(@"setTowerRotation: %f", towerRotation);
    _stick.zRotation = towerRotation;
    _towerRotation = towerRotation;    
}

-(CGFloat)zRotation {
    return _chassis.zRotation;
}

-(CGPoint)position {
    return _chassis.position;
}

-(void)takeTurn:(BOOL)take {
    if (take) {
        self.alpha = 1.0;
    } else {
        self.alpha = 0.5;
    }
}

-(void)creatWheels {
    for (int i=0; i<3; i++) {
        SKSpriteNode* w = [SKSpriteNode spriteNodeWithImageNamed:@"wheel"];
        w.position = CGPointMake(28*i+_chassis.position.x - 28, _chassis.position.y-8);
        w.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:w.size.width/2];
        [self addChild:w];
        w.physicsBody.friction = 0.5;
        
        SKPhysicsJointPin* pin = [SKPhysicsJointPin jointWithBodyA:_chassis.physicsBody bodyB:w.physicsBody anchor:w.position];
        pin.frictionTorque = 0.05;
        [_joints addObject:pin];
        
        _leftWheel = w;
        [_wheels addObject:w];
    }
}

-(void)move:(BOOL)left {
    for (SKSpriteNode* w in _wheels) {
        [w.physicsBody applyTorque:left? -10:10];
    }
}

@end
