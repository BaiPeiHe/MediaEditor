//
//  Case06ViewController.m
//  OpenGLES02
//
//  Created by 白鹤 on 2016/12/30.
//  Copyright © 2016年 白鹤. All rights reserved.
//

#import "Case06ViewController.h"

#import "CameraGLESView.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface Case06ViewController ()<AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureDeviceOutput;

@property (nonatomic, strong) CameraGLESView *cameraView;

@end

@implementation Case06ViewController
{
    dispatch_queue_t processQueue;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cameraView = [[CameraGLESView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.cameraView];
    [self.cameraView setupGL];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    processQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    AVCaptureDevice *inputCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for(AVCaptureDevice *device in devices){
        if([device position] == AVCaptureDevicePositionFront){
            inputCamera = device;
        }
    }
    
    self.captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
    
    if([self.captureSession canAddInput:self.captureDeviceInput]){
        [self.captureSession addInput:self.captureDeviceInput];
    }
    
    self.captureDeviceOutput = [[AVCaptureVideoDataOutput alloc] init];
    [self.captureDeviceOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    self.cameraView.isFullYUVRange = YES;
    
    [self.captureDeviceOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    [self.captureDeviceOutput setSampleBufferDelegate:self queue:processQueue];
    
    if([self.captureSession canAddOutput:self.captureDeviceOutput]){
        [self.captureSession addOutput:self.captureDeviceOutput];
    }
    
    AVCaptureConnection *connection = [self.captureDeviceOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:(AVCaptureVideoOrientationPortraitUpsideDown)];
    
    [self.captureSession startRunning];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    static long frameID = 0;
    ++frameID;
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    [self.cameraView displayPixelBUffer:pixelBuffer];
    
    NSLog(@"frameID = %ld",frameID);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
