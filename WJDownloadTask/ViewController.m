//
//  ViewController.m
//  WJDownloadTask
//
//  Created by 王俊 on 16/12/27.
//  Copyright © 2016年 uhut. All rights reserved.
//

#import "ViewController.h"


//这里是一个很简单的断点续传的demo
//每次暂停回来的获得的resumeData千万不要用属性长期存储，只在用的时候短时间存储， 因为下载资源可能很大，对memory的消耗太过严重，这一点真的需要去注意一下

@interface ViewController ()<NSURLSessionTaskDelegate>

@property(nonatomic,strong)NSOperationQueue *operationQueue;
@property(nonatomic,strong)NSURLSession *session;
@property(nonatomic,strong)NSURLSessionDownloadTask *currentDownloadTask;
@property(nonatomic,strong)NSData *resumeData;

@property(nonatomic,strong)UIButton *downloadButton;

@property(nonatomic,strong)UIButton *pauseButton;

@property(nonatomic,strong)UIButton *resumeButton;
@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureDownloadMananger];
    [self configureUI];
    self.view.backgroundColor = [UIColor greenColor];
}

#pragma mark UI

-(void)configureUI{

    self.downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];//[[UIButton alloc] initWithFrame:];
    self.downloadButton.frame = CGRectMake(30, 50, 80, 40);
    [self.downloadButton setTitle:@"开始下载" forState:UIControlStateNormal];
    [self.downloadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.downloadButton addTarget:self action:@selector(clickBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.downloadButton];
    
    self.pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 100, 80, 40)];
    [self.pauseButton setTitle:@"暂停下载" forState:UIControlStateNormal];
    [self.pauseButton addTarget:self action:@selector(clickBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:self.pauseButton];
    
    self.resumeButton = [[UIButton alloc] initWithFrame:CGRectMake(30, 150, 80, 40)];
    [self.resumeButton setTitle:@"继续下载" forState:UIControlStateNormal];
    [self.resumeButton addTarget:self action:@selector(clickBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.resumeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:self.resumeButton];
    
    
}

-(void)clickBtnAction:(UIButton *)sender{

    if (sender == self.downloadButton) {
       [self startTaskWithUrl:@"http://7xod41.com2.z0.glb.qiniucdn.com//apptrain/video/20161107032322.mp4"];
    }else if (sender == self.pauseButton){
        [self pauseTask];
    }else if (sender == self.resumeButton){
        [self resumeTask];
    }
    
}



#pragma mark downloadManager
//这只是一个小的demo 没有模块的拆分 实际开发中一定要拆分好每一部分
-(void)configureDownloadMananger{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"background";
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                     delegate:self
                                                delegateQueue:[NSOperationQueue mainQueue]];
    });
    
}

-(void)startTaskWithUrl:(NSString *)urlString{

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDownloadTask *downLoadTask = [self.session downloadTaskWithRequest:request];
    self.currentDownloadTask = downLoadTask;
    [ self.currentDownloadTask resume];
}

-(void)pauseTask{
    if (self.currentDownloadTask) {
        [self.currentDownloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            NSLog(@"resumeData === %@",resumeData);
            //实际开发中最好不要用属性存储resumeData这样的数据
            self.resumeData = resumeData;
        }];
    }

}

-(void)resumeTask{

    if (!self.resumeData)return;
    self.currentDownloadTask = [self.session downloadTaskWithResumeData:self.resumeData];
    [self.currentDownloadTask resume];

}

#pragma mark --- delegate

//下载完成时的代理
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    
    
    NSLog(@"downloadTask === %@",downloadTask);
    //下载完成后系统会将文件存储在一个temp的文件路径下 如果不及时处理 会被系统清理 所以持久化存储 最好将下载的任务存储起来

}

//下载中出现错误的代理
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{

      //NSLog(@"downloadTask === %@",downloadTask);
//    self.resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
//    NSLog(@"error : %@",error);
//    [self resumeTask];
    //现在证明是会继续进行下载的
}

//下载进度相关的代理
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
      NSLog(@"downloadTask === %@",downloadTask);
    //NSLog(@"bytesWritten == %lld totalBytesExpectedToWrite === %lld",bytesWritten,totalBytesExpectedToWrite);
}




@end
