//
//  Vehicle.h
//  Cetris
//
//  Created by Wan Wei on 14/8/9.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Vehicle : SKNode
@property (nonatomic) SKSpriteNode *leftWheel;
@property (nonatomic) SKSpriteNode *ctop;
@property (nonatomic) NSMutableArray* joints;


-(id)initWithPosition:(CGPoint)pos;
-(void)initPhysics;

@end
