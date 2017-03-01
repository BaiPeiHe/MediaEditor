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
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>

@interface RootViewController ()

@end

@implementation RootViewController

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
