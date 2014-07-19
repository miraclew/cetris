//
//  DefaultClient.h
//  Cetris
//
//  Created by Wan Wei on 14/7/19.
//  Copyright (c) 2014年 Wan Wei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "Client.h"

@interface DefaultClient : NSObject <Client, GCDAsyncSocketDelegate>

@end
