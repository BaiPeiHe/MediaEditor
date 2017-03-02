//
//  RootViewController.m
//  FFmpeg-01
//
//  Created by 白鹤 on 2017/2/28.
//  Copyright © 2017年 白鹤. All rights reserved.
//

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#import "RootViewController.h"

#import "OpenGLView20.h"

#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>

@interface RootViewController ()

@end

@implementation RootViewController
{
    OpenGLView20 *playView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self createView];
    
}

- (void)createView{
    
    UIButton *decodeBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [decodeBtn setTitleColor:[UIColor brownColor] forState:(UIControlStateNormal)];
    decodeBtn.frame = CGRectMake(SCREEN_WIDTH / 4, 64, 100, 30);
    [decodeBtn setTitle:@"解码" forState:(UIControlStateNormal)];
    [decodeBtn addTarget:self action:@selector(clickDecodeAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:decodeBtn];
    
    UIButton *playBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [playBtn setTitleColor:[UIColor brownColor] forState:(UIControlStateNormal)];
    playBtn.frame = CGRectMake(SCREEN_WIDTH / 4 * 2, 64, 100, 30);
    [playBtn setTitle:@"播放" forState:(UIControlStateNormal)];
    [playBtn addTarget:self action:@selector(clickPlayAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:playBtn];
    
    playView = [[OpenGLView20 alloc] initWithFrame:CGRectMake(20, 100, SCREEN_WIDTH - 40, SCREEN_HEIGHT - 101)];
    playView.backgroundColor = [UIColor brownColor];
    [self.view addSubview:playView];
    
    
}

- (void)clickPlayAction{
    NSLog(@"播放");
    
    AVFormatContext *pFormatCtx;
    int             videoIndex;
    AVCodecContext  *pCodecCtx;
    AVCodec         *pCodec;
    
    NSString *input = [[NSBundle mainBundle]pathForResource:@"nwn1" ofType:@"mp4"];
    const char *filePath = [input UTF8String];
    
    av_register_all();
    avformat_network_init();
    pFormatCtx = avformat_alloc_context();
    if(avformat_open_input(&pFormatCtx, filePath, NULL, NULL) != 0){
        printf("Couldn't open input steam.\n");
        exit(1);
    }
    
    if(avformat_find_stream_info(pFormatCtx, NULL) < 0){
        printf("Couldn't find stram information.\n");
        exit(1);
    }
    
    videoIndex = -1;
    for(int i = 0; i < pFormatCtx->nb_streams; i++){
        if(pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){
            videoIndex = i;
            break;
        }
    }
    
    if(videoIndex == -1){
        printf("Didn't find a video stream.\n");
        exit(1);
    }
    
    pCodecCtx = pFormatCtx->streams[videoIndex]->codec;
    pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
    if(pCodec == NULL){
        printf("Codec not found.\n");
        exit(1);
    }
    
    if(avcodec_open2(pCodecCtx, pCodec, NULL) < 0){
        printf("Could not open codec.\n");
        exit(1);
    }
    
    AVFrame *pFrame, *pFrameYUV;
    pFrame = av_frame_alloc();
    pFrameYUV = av_frame_alloc();
    uint8_t *out_buffer = (uint8_t *)av_malloc(avpicture_get_size(PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height));
    avpicture_fill((AVPicture *)pFrameYUV, out_buffer, PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height);
    
    int ret, got_picture;
    int y_size = pCodecCtx->width * pCodecCtx->height;
    
    AVPacket *packet = (AVPacket *)av_malloc(sizeof(AVPacket));
    av_new_packet(packet, y_size);
    
    printf("video infomatoin:\n");
    av_dump_format(pFormatCtx, 0, filePath, 0);
    
    while (av_read_frame(pFormatCtx, packet) >= 0) {
        if(packet->stream_index == videoIndex){
            ret = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, packet);
            if(ret < 0){
                printf("Decode Error.\n");
                exit(1);
            }
            
            if(got_picture){
                char *buf = (char*)malloc(pFrame->width * pFrame->height * 3 / 2);
                
                AVPicture *pict;
                int  w, h;
                char *y, *u, *v;
                pict = (AVPicture *)pFrame;// 这里的 frame 就是解码出来的 AVFrame
                w = pFrame->width;
                h = pFrame->height;
                y = buf;
                u = y + w * h;
                v = u + w * h / 4;
                
                for(int i = 0; i < h; i++){
                    memcpy(y + w * i, pict->data[0] + pict->linesize[0] * i, w);
                }
                
                for(int i = 0; i < h / 2; i++){
                    memcpy(u + w / 2 * i, pict->data[1] + pict->linesize[1] * i, w / 2);
                }
                for(int i = 0; i < h / 2; i++){
                    memcpy(v + w / 2 * i, pict->data[2] + pict->linesize[2] * i, w / 2);
                }
                
                [playView setVideoSize:pFrame->width height:pFrame->height];
                [playView displayYUV420pData:buf width:pFrame->width height:pFrame->height];
                free(buf);
            
            }
        }
        av_free_packet(packet);
    }
    
    av_free(pFrameYUV);
    avcodec_close(pCodecCtx);
    avformat_close_input(&pFormatCtx);
    
}

- (void)clickDecodeAction{
    
    NSLog(@"解码");
    
    // 1、Start 初始化
    AVFormatContext *pFormatCtx;
    int             i, videoIndex;
    AVCodecContext  *pCodecCtx;
    AVCodec         *pCodec;
    AVFrame *pFrame,*pFrameYUV;
    uint8_t *out_buffre;
    AVPacket *packet;
    int y_size;
    int ret, got_picture;
    struct SwsContext *img_convert_ctx;
    FILE *fp_yuv;
    int frame_cnt;
    clock_t time_start, time_finish;
    double  time_duration = 0.0;
    
    char input_str_full[500] = {0};
    char output_str_full[500] = {0};
    char info[1000] = {0};
    
    NSString *input_str = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"nwn.mp4"];
    NSString *output_str = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test.yuv"];
    
    // 主要功能是把格式化的数据写入某个字符串中
    sprintf(input_str_full, "%s",[input_str UTF8String]);
    sprintf(output_str_full, "%s",[output_str UTF8String]);
    
    printf("Input Path:%s\n",input_str_full);
    printf("Output Path:%s\n",output_str_full);
    
    unlink([output_str UTF8String]);
    
    // 2、
    av_register_all();
    avformat_network_init();
    pFormatCtx = avformat_alloc_context();
    // 3、
    if(avformat_open_input(&pFormatCtx, input_str_full, NULL, NULL) != 0){
        printf("Couldn't open input steam.\n");
        return;
    }
    // 4、
    if(avformat_find_stream_info(pFormatCtx, NULL) < 0){
        printf("Couldn't find stream information.\n");
        return;
    }
    
    videoIndex = -1;
    for(i = 0; i < pFormatCtx->nb_streams; i++){
        if(pFormatCtx->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO){
            videoIndex = i;
            break;
        }
    }
    if(videoIndex == -1){
        printf("Couldn't find a video stream.\n");
        return;
    }
    // 5、avcodec_find_decoder（）
    pCodecCtx = pFormatCtx->streams[videoIndex]->codec;
    pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
    if(pCodec == NULL){
        printf("Couldn't find Codec.\n");
        return;
    }
    // 6、
    if(avcodec_open2(pCodecCtx, pCodec, NULL) < 0){
        printf("Couldn't open codec.\n");
        return;
    }
    
    pFrame = av_frame_alloc();
    pFrameYUV = av_frame_alloc();
    out_buffre = (uint8_t *)av_malloc(avpicture_get_size(PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height));
    avpicture_fill((AVPicture *)pFrameYUV, out_buffre, PIX_FMT_YUV420P, pCodecCtx->width, pCodecCtx->height);
    packet = (AVPacket *)av_malloc(sizeof(AVPacket));
    
    img_convert_ctx = sws_getContext(pCodecCtx->width, pCodecCtx->height, pCodecCtx->pix_fmt, pCodecCtx->width, pCodecCtx->height, PIX_FMT_YUV420P, SWS_BICUBIC, NULL, NULL, NULL);
    
    sprintf(info,   "[Input     ]%s\n", [input_str UTF8String]);
    sprintf(info, "%s[Output    ]%s\n",info, [output_str UTF8String]);
    sprintf(info, "%s[Format    ]%s\n",info, pFormatCtx->iformat->name);
    sprintf(info, "%s[Codec     ]%s\n",info, pCodecCtx->codec->name);
    sprintf(info, "%s[Resolution]%dx%d\n",info, pCodecCtx->width,pCodecCtx->height);
    
    
    fp_yuv = fopen(output_str_full, "wb+");
    if(fp_yuv == NULL){
        printf("Couldn't open output file.\n");
        return;
    }
    
    frame_cnt = 0;
    time_start = clock();
    
    while (av_read_frame(pFormatCtx, packet) >= 0) {
        if(packet ->stream_index == videoIndex){
            ret = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, packet);
            if(ret < 0){
                printf("Decode Error.\n");
                return;
            }
            if(got_picture){
                sws_scale(img_convert_ctx, (const uint8_t* const*)pFrame->data, pFrame->linesize, 0, pCodecCtx->height, pFrameYUV->data, pFrameYUV->linesize);
                y_size = pCodecCtx->width * pCodecCtx->height;
                
                fwrite(pFrameYUV->data[0], 1, y_size, fp_yuv);      // Y
                fwrite(pFrameYUV->data[1], 1, y_size / 4, fp_yuv);  // U
                fwrite(pFrameYUV->data[2], 1, y_size / 4, fp_yuv);  // V
                // Output info
                char pictype_str[10] = {0};
                switch (pFrame->pict_type) {
                    case AV_PICTURE_TYPE_I:
                        sprintf(pictype_str, "I");
                        break;
                    case AV_PICTURE_TYPE_P:
                        sprintf(pictype_str, "P");
                        break;
                        
                    case AV_PICTURE_TYPE_B:
                        sprintf(pictype_str, "B");
                        break;
                        
                    default:
                        sprintf(pictype_str, "Other");
                        break;
                }
                printf("Frame Index: %5d. Type:%s\n",frame_cnt,pictype_str);
                frame_cnt++;
            }
        }
        av_free_packet(packet);
    }
    
    // flush decoder
    // FIX: Flush frames remained in Codec
    while (1) {
        ret = avcodec_decode_video2(pCodecCtx, pFrame, &got_picture, packet);
        if(ret < 0){
            break;
        }
        if(!got_picture){
            break;
        }
        
        sws_scale(img_convert_ctx, (const uint8_t* const*)pFrame->data, pFrame->linesize, 0, pCodecCtx->height, pFrameYUV->data, pFrameYUV->linesize);
        int y_size = pCodecCtx->width * pCodecCtx->height;
        fwrite(pFrameYUV->data[0], 1, y_size, fp_yuv);      // Y
        fwrite(pFrameYUV->data[1], 1, y_size / 4, fp_yuv);  // U
        fwrite(pFrameYUV->data[2], 1, y_size / 4, fp_yuv);  // V
        // Output info
        char pictype_str[10] = {0};
        switch (pFrame->pict_type) {
            case AV_PICTURE_TYPE_I:
                sprintf(pictype_str, "I");
                break;
            case AV_PICTURE_TYPE_P:
                sprintf(pictype_str, "P");
                break;
                
            case AV_PICTURE_TYPE_B:
                sprintf(pictype_str, "B");
                break;
                
            default:
                sprintf(pictype_str, "Other");
                break;
        }
        printf("Frame Index: %5d. Type:%s\n",frame_cnt,pictype_str);
        frame_cnt++;
    }
    time_finish = clock();
    time_duration = (double)(time_finish - time_start);
    
    sprintf(info, "%s[Time      ]%fus\n",info, time_duration);
    sprintf(info, "%s[Count     ]%d\n",info, frame_cnt);
    
    sws_freeContext(img_convert_ctx);
    
    fclose(fp_yuv);
    
    av_frame_free(&pFrameYUV);
    av_frame_free(&pFrame);
    avcodec_close(pCodecCtx);
    avformat_close_input(&pFormatCtx);
    
    NSString * info_ns = [NSString stringWithFormat:@"%s", info];
    
    NSLog(@"%@", info_ns);
    
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
