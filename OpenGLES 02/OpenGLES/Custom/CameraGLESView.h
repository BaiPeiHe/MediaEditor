//
//  CameraView.h
//  OpenGLES02
//
//  Created by 白鹤 on 2016/12/30.
//  Copyright © 2016年 白鹤. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface CameraGLESView : UIView

@property (nonatomic, assign) BOOL isFullYUVRange;

- (void)setupGL;

- (void)displayPixelBUffer:(CVPixelBufferRef)pixelBuffer;

@end
