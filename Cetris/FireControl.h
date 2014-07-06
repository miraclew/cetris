//
//  FireControl.h
//  Cetris
//
//  Created by Wan Wei on 14/7/5.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef void (^FireBlock)(id object);
typedef void (^VectorChangeBlock)(id object);

@interface FireControl : SKNode

+(instancetype)controlWithRadius:(CGFloat)radius FireBlock:(FireBlock) block1 VectorChangeBlock:(VectorChangeBlock) block2;

@property (nonatomic) CGFloat radius;
@property (nonatomic) CGVector controlVector;

@end
