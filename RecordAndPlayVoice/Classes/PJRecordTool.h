//
//  PJRecordTool.h
//  RecordAndPlayVoice
//
//  Created by pengjie on 2016/11/27.
//  Copyright © 2016年 pengjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class PJRecordTool;
@protocol PJRecordToolDelegate <NSObject>

@optional

- (void)recordTool:(PJRecordTool *)recordTool didstartRecoring:(int)no;

@end

@interface PJRecordTool : NSObject


/** 录音工具的单例 */
+ (instancetype)sharedRecordTool;

/** 开始录音 */
- (void)startRecording;

/** 停止录音 */
- (void)stopRecording;

/** 播放录音文件 */
- (void)playRecordingFile:(NSURL *)fileUrl;

/** 停止播放录音文件 */
- (void)stopPlaying;

/** 销毁录音文件 */
- (void)destructionRecordingFile;

/** 继续录制 */
- (void)resumeRecording;

/** 暂停 */
- (void)pauseRecording;

/** 录音对象 */
@property (nonatomic, strong) AVAudioRecorder *recorder;
/** 播放器对象 */
@property (nonatomic, strong) AVAudioPlayer *player;
/** 更新图片的代理 */
@property (nonatomic, assign) id<PJRecordToolDelegate> delegate;

@property (nonatomic,strong) NSMutableArray *voiceArray;

@end
