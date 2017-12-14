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
#import "PJRecordTool.h"

@interface ViewController ()<PJRecordToolDelegate,UITableViewDelegate,UITableViewDataSource>

/** 录音工具 */
@property (nonatomic, strong) PJRecordTool *recordTool;

/** 录音时的图片 */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
/** 录音中的提示Label*/
@property (weak, nonatomic) IBOutlet UILabel *lineOnLabel;
/** 停止按钮 */
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
/** 录音按钮 */
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
/** 暂停按钮 */
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
/** 继续录制按钮 */
@property (weak, nonatomic) IBOutlet UIButton *goOnBtn;
/** 播放列表 */
@property (weak, nonatomic) IBOutlet UITableView *voiceListView;
/** 声音存放数组 */
@property (nonatomic,strong) NSMutableArray *voiceArray;
/** 声音文件名数组 */
@property (nonatomic,strong) NSMutableArray *voiceNameArray;

@end

static NSString *identifier = @"cc";

@implementation ViewController

- (NSMutableArray *)voiceArray {
    // 如果是第一次启动
    if (nil == _voiceArray) {
        _voiceArray = [NSKeyedUnarchiver unarchiveObjectWithFile:kFilePath];
        //初始化
        if (_voiceArray.count == 0) {
            _voiceArray = [NSMutableArray array];
            _voiceNameArray = [NSMutableArray array];
        }
    }
    return _voiceArray;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.title = @"录音器";
    self.recordTool = [PJRecordTool sharedRecordTool];
    
    self.lineOnLabel.hidden = YES;
    self.imageView.hidden = NO;
    
    self.recordBtn.enabled = YES;
    self.stopBtn.enabled = NO;
    self.pauseBtn.enabled = NO;
    self.goOnBtn.enabled = NO;
    
    self.voiceListView.dataSource = self;
    self.voiceListView.delegate = self;
    self.recordTool.delegate = self;
    
    [self.voiceListView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
}

#pragma mark - 录音按钮事件
//按下录制按钮
/**
 开始录制

 @param sender 按钮
 */
- (IBAction)startRecord:(id)sender {
    [self.recordTool startRecording];
    
    self.lineOnLabel.textColor = [UIColor redColor];
    self.lineOnLabel.hidden = NO;
    
    self.stopBtn.enabled = YES;
    self.pauseBtn.enabled = YES;
    self.goOnBtn.enabled = NO;
    self.recordBtn.enabled = NO;
}

//按下停止按钮
/**
 结束录制

 @param sender 按钮
 */
- (IBAction)stop:(id)sender {
    [self.recordTool stopRecording];
    
    self.lineOnLabel.hidden = YES;
    self.imageView.image = [UIImage imageNamed:@"mic_0"];
    
    self.stopBtn.enabled = NO;
    self.pauseBtn.enabled = NO;
    self.goOnBtn.enabled = NO;
    self.recordBtn.enabled = YES;
    
    [self alertWithMessage:@"结束录音,请保存文件"];
}

/**
 暂停

 @param sender 按钮
 */
- (IBAction)zanting:(id)sender {
    
    [self.recordTool pauseRecording];
    
    self.lineOnLabel.textColor = [UIColor greenColor];
    self.lineOnLabel.text = @"已暂停";
    
    self.recordBtn.enabled = NO;
    self.stopBtn.enabled = YES;
    self.pauseBtn.enabled = NO;
    self.goOnBtn.enabled = YES;
}

/**
 继续

 @param sender 按钮
 */
- (IBAction)jixu:(id)sender {
    [self.recordTool resumeRecording];
    
    self.lineOnLabel.textColor = [UIColor redColor];
    self.lineOnLabel.text = @"录音中..";
    
    self.stopBtn.enabled = YES;
    self.pauseBtn.enabled = YES;
    self.goOnBtn.enabled = NO;
    self.recordBtn.enabled = NO;

}

#pragma mark - 弹窗提示
- (void)alertWithMessage:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message: message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * textField){
        textField.placeholder = @"请输入文件名";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
     __weak typeof(alertController) weakAlert = alertController;
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        
       NSString *voiceName = weakAlert.textFields.firstObject.text;
       [self.voiceNameArray addObject:voiceName];
        
       NSString * fullPath =[[PJRecordTool sharedRecordTool].voiceArray lastObject];
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
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)dealloc {
    
    if ([self.recordTool.recorder isRecording]) [self.recordTool stopPlaying];
    if ([self.recordTool.player isPlaying]) [self.recordTool stopRecording];
    
}

#pragma mark - PJRecordToolDelegate

- (void)recordTool:(PJRecordTool *)recordTool didstartRecoring:(int)no {
    
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
        [self.voiceNameArray removeObjectAtIndex:indexPath.row];
        // 从tableView 中删除数据
        [self.voiceListView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        // 归档数据
        [NSKeyedArchiver archiveRootObject:self.voiceArray toFile:kFilePath];
    }
    
}


@end

