//
//  Tank.h
//  Cetris
//
//  Created by Wan Wei on 14/8/9.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Tank : SKSpriteNode

@property (nonatomic) SKSpriteNode* stick;
@property (nonatomic) SKSpriteNode *leftWheel;
@property (nonatomic) NSMutableArray* joints;
@property (nonatomic, assign) CGFloat towerRotation;
@property (nonatomic, assign) uint32_t collisionBitmask;

-(id)initWithPosition:(CGPoint)pos;
-(void)move:(BOOL)left;
-(void)takeTurn:(BOOL)take;
@end
