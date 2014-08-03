//
//  StartScene.m
//  Cetris
//
//  Created by Wan Wei on 14/7/27.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import "StartScene.h"

@implementation StartScene {
    Game* _game;
    BOOL _ready;
    SKLabelNode* _startNode;
}

-(id)initWithSize:(CGSize)size  Game:(Game*)game {
    if (self = [super initWithSize:size]) {
        _game = game;
        _ready = NO;
        SKLabelNode *titleNode = [SKLabelNode labelNodeWithFontNamed:@"System"];
        titleNode.text = @"炮弹对轰";
        titleNode.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:titleNode];
        
        _startNode = [SKLabelNode labelNodeWithFontNamed:@"System"];
        _startNode.name = @"StartButton";
        _startNode.position = CGPointMake(size.width/2, size.height/2 - 80);
        [self addChild:_startNode];
        [self updateState];
    }
    return self;
}

-(void)updateState {
    _ready = NO;
    if (_game.state == GS_READY || _game.state == GS_OVER) {
        _startNode.text = @"点击开始";
        _ready = YES;
        [_game matchEnter];
    } else if (_game.state == GS_INIT) {
        _startNode.text = @"连接中...";
    } else {
        [_game matchEnter];
        _startNode.text = @"Unknown state";
    }
}

-(void)ready {
    _ready = YES;
    _startNode.text = @"点击开始";
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!_ready) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //if fire button touched, bring the rain
    if ([node.name isEqualToString:@"StartButton"]) {
        SKAction *buttonClick = [SKAction playSoundFileNamed:@"pushbtn.wav" waitForCompletion:NO];
        [self runAction:buttonClick];
        [_game matchEnter];
    }
}


@end
