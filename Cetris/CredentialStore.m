//
//  CredentialStore.m
//  ColaNews
//
//  Created by Wan Wei on 1/29/14.
//  Copyright (c) 2014 Wan Wei. All rights reserved.
//

#import "CredentialStore.h"
#import "SSKeychain.h"

#define SERVICE_NAME @"AuthClient"
#define AUTH_TOKEN_KEY @"auth_token"

@implementation CredentialStore

+ (id)sharedStore {
    static CredentialStore *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[CredentialStore alloc] init];
    });
    return __instance;
}

- (BOOL) isLoggedIn {
    return [self authToken] != nil;
}

- (void) clearSavedCredentials {
    [self setAuthToken:nil];
}

- (NSString *) authToken {
    return [self secureValueForKey:AUTH_TOKEN_KEY];
}

- (void) setAuthToken:(NSString *) authToken {
    [self setSecureValue:authToken forKey:AUTH_TOKEN_KEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"token-changed" object:self];
}

- (NSString *)userName {
    return [self secureValueForKey:@"userName"];
}

- (void)setUserName:(NSString *)userName {
    [self setSecureValue:userName forKey:@"userName"];
}

- (NSString *)password {
    return [self secureValueForKey:@"password"];
}

- (void)setPassword:(NSString *)password {
    [self setSecureValue:password forKey:@"password"];
}

-(void)setSecureValue:(NSString *)value forKey:(NSString *) key {
    if (value) {
        [SSKeychain setPassword:value forService:SERVICE_NAME account:key];
    } else {
        [SSKeychain deletePasswordForService:SERVICE_NAME account:key];
    }
}

-(NSString *)secureValueForKey:(NSString *)key {
    return [SSKeychain passwordForService:SERVICE_NAME account:key];
}

@end
