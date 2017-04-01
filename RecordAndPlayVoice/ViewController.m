//
//  ViewController.m
//  RecordAndPlayVoice
//
//  Created by pengjie on 2016/11/27.
//  Copyright © 2016年 pengjie. All rights reserved.
//

// 保存数据的文件路径
#define kFilePath ([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"voicelist.data"])

#import "ViewController.h"
#import "LVRecordTool.h"
//#import <CoreTelephony/CTCallCenter.h>
//#import <CoreTelephony/CTCall.h>

@interface ViewController ()<LVRecordToolDelegate,UITableViewDelegate,UITableViewDataSource>

/** 录音工具 */
@property (nonatomic, strong) LVRecordTool *recordTool;

/** 停止按钮 */
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;

/** 录音时的图片 */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

/** 录音按钮 */
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;

/** 播放列表 */
@property (weak, nonatomic) IBOutlet UITableView *voiceListView;

/** 录音中的提示Label*/
@property (weak, nonatomic) IBOutlet UILabel *lineOnLabel;

/** 声音数组 */
@property (nonatomic,strong) NSMutableArray *voiceArray;


//@property (strong, nonatomic) CTCallCenter *callCenter;

@end

static NSString *identifier = @"cc";

@implementation ViewController

- (NSMutableArray *)voiceArray {
    if (nil == _voiceArray) {
        
        // 如果是第一次启动, 该路径下, 没有数据, 导致_dataArray为空
        _voiceArray = [NSKeyedUnarchiver unarchiveObjectWithFile:kFilePath];
        
        if (_voiceArray.count == 0) {
            // 没有读取到数据
            _voiceArray = [NSMutableArray array];
        }
    }
    return _voiceArray;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.lineOnLabel.hidden = YES;
    
    self.recordTool = [LVRecordTool sharedRecordTool];
    
    self.imageView.hidden = NO;
    
    self.voiceListView.dataSource = self;
    
    self.voiceListView.delegate = self;
    
    [self.voiceListView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
    
    // 初始化监听事件
    
    [self setup];
    
//    [self setCall];
}

- (IBAction)zanting:(id)sender {
    [self.recordTool pauseRecording];
}

- (IBAction)jixu:(id)sender {
    [self.recordTool resumeRecording];

}


- (void)setup {
    
    self.recordBtn.layer.cornerRadius = 10;
    
    [self.recordBtn setTitle:@"按下录音" forState:UIControlStateNormal];
    [self.recordBtn setTitle:@"开始录音" forState:UIControlStateHighlighted];
    [self.recordBtn setTitle:@"录音中" forState:UIControlStateSelected];
    
    
    self.recordTool.delegate = self;
    
}

//- (void)setCall{
//    
//    CTCallCenter *callCenter = [[CTCallCenter alloc] init];
//    
//    callCenter.callEventHandler = ^(CTCall* call) {
//        if ([call.callState isEqualToString:CTCallStateDisconnected])
//        {
//            NSLog(@"挂断了电话咯Call has been disconnected");
//        }
//        else if ([call.callState isEqualToString:CTCallStateConnected])
//        {
//            NSLog(@"电话通了Call has just been connected");
//        }
//        else if([call.callState isEqualToString:CTCallStateIncoming])
//        {
//            NSLog(@"来电话了Call is incoming");
//            
//        }
//        else if ([call.callState isEqualToString:CTCallStateDialing])
//        {
//            NSLog(@"正在播出电话call is dialing");
//        }
//        else
//        {
//            NSLog(@"嘛都没做Nothing is done");
//        }
//    };
//
//}

#pragma mark - 录音按钮事件

//按下录制按钮
- (IBAction)startRecord:(id)sender {
    
    [self.recordTool startRecording];
    
    self.lineOnLabel.textColor = [UIColor redColor];
    
    self.lineOnLabel.hidden = NO;
}

//按下停止按钮
- (IBAction)stop:(id)sender {
    
    self.lineOnLabel.hidden = YES;
    
    self.imageView.image = [UIImage imageNamed:@"mic_0"];
    
      [self.recordTool stopRecording];
    
            [self alertWithMessage:@"结束录音,请保存文件"];
    
}

#pragma mark - 弹窗提示
- (void)alertWithMessage:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message: message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString * fullPath =[[LVRecordTool sharedRecordTool].voiceArray lastObject];
        
         NSArray *lastArray = [fullPath componentsSeparatedByString:@"/Documents/"];
        
        [self.voiceArray addObject:lastArray.lastObject];
        //存档
         [NSKeyedArchiver archiveRootObject:self.voiceArray toFile:kFilePath];
        //刷新
         [self.voiceListView reloadData];
        
         [self.recordTool setValue:nil forKey:@"recorder"];
        
    }];
    
    [alertController addAction:cancelAction];
    
    [alertController addAction:okAction];
    
//       [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
//        textField.placeholder = @"请输入文件名";
//    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    
}

- (void)dealloc {
    
    if ([self.recordTool.recorder isRecording]) [self.recordTool stopPlaying];
    
    if ([self.recordTool.player isPlaying]) [self.recordTool stopRecording];
    
}

#pragma mark - LVRecordToolDelegate

- (void)recordTool:(LVRecordTool *)recordTool didstartRecoring:(int)no {
    
    NSString *imageName = [NSString stringWithFormat:@"mic_%d", no];
    
    self.imageView.image = [UIImage imageNamed:imageName];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.voiceArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.voiceArray[indexPath.row];
   
    return cell;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 1.获取沙盒地址
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *pathLast = self.voiceArray[indexPath.row];
    
    NSString *filePath = [path stringByAppendingPathComponent:pathLast];

    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
 
    [self.recordTool playRecordingFile:fileUrl];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // 删除数据
        // 移除模型中的数据
        [self.voiceArray removeObjectAtIndex:indexPath.row];
        
        
        // 从tableView 中删除数据
        [self.voiceListView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        // 归档数据
        [NSKeyedArchiver archiveRootObject:self.voiceArray toFile:kFilePath];
    }
    
}


@end

