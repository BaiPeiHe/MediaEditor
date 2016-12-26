//
//  AGLKContext.h
//  OpenGLES
//
//  Created by 白鹤 on 2016/12/26.
//  Copyright © 2016年 白鹤. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface AGLKContext : EAGLContext
{
    GLKVector4 clearColor;
}

@property (nonatomic, assign) GLKVector4 clearColor;

- (void)clear:(GLbitfield)mask;

@end
