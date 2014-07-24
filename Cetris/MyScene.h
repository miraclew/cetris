//
//  MyScene.h
//  Cetris
//

//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Client.h"

@interface MyScene : SKScene <SKPhysicsContactDelegate, ClientDelegate>

@property (nonatomic, strong) NSArray* players;
@property (nonatomic, strong) NSArray* keyPoints;

@end
