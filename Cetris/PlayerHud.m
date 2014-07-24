//
//  PlayerHud.m
//  Cetris
//
//  Created by Wan Wei on 14/7/24.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "PlayerHud.h"

@implementation PlayerHud {
    SKLabelNode *_nickNameLabel;
    SKLabelNode *_healthLabel;
    SKSpriteNode *_avatarNode;
}

-(instancetype)init {
    if(self = [super init]) {
        _nickNameLabel = [SKLabelNode labelNodeWithFontNamed:@"System"];
        _nickNameLabel.fontColor = [SKColor whiteColor];
        _nickNameLabel.fontSize = 16.0f;
        _nickNameLabel.position = CGPointMake(50, 0);
        _nickNameLabel.text = _nickName;
        [self addChild:_nickNameLabel];

        _healthLabel = [SKLabelNode labelNodeWithFontNamed:@"System"];
        _healthLabel.fontColor = [SKColor whiteColor];
        _healthLabel.fontSize = 16.0f;
        _healthLabel.text = _health;
        _healthLabel.position = CGPointMake(50, 30);
        [self addChild:_healthLabel];
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_avatar]];
        UIImage *image = [UIImage imageWithData:imageData];
        _avatarNode = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:image]];
        [self addChild:_avatarNode];
    }
    return self;
}

@end
