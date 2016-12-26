//
//  GLKVertexAttribArrayBuffer.m
//  OpenGLES
//
//  Created by 白鹤 on 2016/12/26.
//  Copyright © 2016年 白鹤. All rights reserved.
//

#import "GLKVertexAttribArrayBuffer.h"

@interface GLKVertexAttribArrayBuffer ()

@property (nonatomic, assign) GLsizeiptr bufferSizeBytes;

@property (nonatomic, assign) GLsizeiptr stride;

@end

@implementation GLKVertexAttribArrayBuffer

@synthesize glName;
@synthesize bufferSizeBytes;
@synthesize stride;


- (id)initWithAttribStride:(GLsizeiptr)aStride
          numberOfVertices:(GLsizei)count
                      data:(const GLvoid *)dataPtr
                     usage:(GLenum)usage;
{
    NSParameterAssert(0 < aStride);
    NSParameterAssert(0 < count);
    NSParameterAssert(NULL != dataPtr);
    
    if(nil != (self = [super init]))
    {
        stride = aStride;
        bufferSizeBytes = stride * count;
        
        // 1.
        glGenBuffers(1,
                     &glName);
        
        glBindBuffer(GL_ARRAY_BUFFER,
                     self.glName);
        
        glBufferData(GL_ARRAY_BUFFER,
                     bufferSizeBytes,
                     dataPtr,
                     usage);
        
        NSAssert(0 != glName, @"Faild to generate glName");
    }
    
    return self;
}

-(void)prepareToDrawWithAttrib:(GLuint)index
           numberOfCoordinates:(GLint)count
                  attribOffset:(GLsizeiptr)offset
                  shouldEnable:(BOOL)shouldEnable
{
    NSParameterAssert((0 < count) && count < 4);
    NSParameterAssert(offset < self.stride);
    NSAssert(0 != glName, @"Invalid glNmae");
    // 2.
    glBindBuffer(GL_ARRAY_BUFFER,
                 self.glName);
    
    if(shouldEnable){
        // 4.
        glEnableVertexAttribArray(
                                  index);
    }
    
    // 5.
    glVertexAttribPointer(index,
                          count,
                          GL_FLOAT,
                          GL_FALSE,
                          self.stride,
                          NULL + offset);
}

-(void)drawArrayWithMode:(GLenum)mode
        startVertexIndex:(GLint)first
        numberOfVertices:(GLsizei)count
{
    NSAssert(self.bufferSizeBytes >= ((first + count) * self.stride), @"Attempt to draw more vertex data than availabel.");
    
    // 6.
    glDrawArrays(mode, first, count);
    
}

- (void)dealloc{
    // 7.
    if(0 != glName){
        glDeleteBuffers(1,
                        &glName);
        glName = 0;
    }
}

@end
