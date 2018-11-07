//
//  main.m
//  CAToneFileGenerator
//
//  Created by ByungChen Moon on 07/11/2018.
//  Copyright © 2018 ByungChen Moon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define SAMPLE_RATE 44100 //CD 오디오 품질과 같은 초당 44,100 샘플이나, 44.1kHz 샘플율을 #define한다.
#define DURATION 5.0 // 오디오의 초

//AIFF(Audio Interchange File Format)는 개인용 컴퓨터와 기타 오디오 전자 장비에서 소리를 저장하는 데 사용하는 오디오 파일 형식이다.
//#define FILENAME_FORMAT @"%0.3f-square.aif" //사각형의 파형을 가지는 파일의 이름포맷
#define FILENAME_FORMAT @"%0.3f-saw.aif" //톱니 파형




int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        if(argc < 2) {
            printf("Usage: CAToneFileGenerator n\n (where n is tone is Hz) ");
            return -1;
        }
        // argv[1] : 생성하길 원하는 음색 주파수의 부동소수점 수
        double hz = atof(argv[1]);
        
        assert( hz > 0);
        
        NSLog(@"generating %f hz tone", hz);
        
        
        NSString *fileName = [NSString stringWithFormat:FILENAME_FORMAT, hz];
        
        NSString *filePath = [[[NSFileManager defaultManager] currentDirectoryPath] stringByAppendingPathComponent:fileName];
        
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        
        //형식을 준비
        //오디오의 스트림의 가장 광범위한 특성을 정의
        AudioStreamBasicDescription asbd;
        //ASBD의 필드를 초기화
        memset(&asbd, 0, sizeof(asbd));
        
        asbd.mSampleRate = SAMPLE_RATE;
        asbd.mFormatID = kAudioFormatLinearPCM;
        
        //kAudioFormatFlagIsBigEndian 샘플이 빅엔디언(바이트나 워드의 높은 비트가 낮은 비트보다 숫자적으로 더욱 중요함), 리틀엔디언인지 정해야함 AIFF파일은 빅엔디언만 됨
        //kAudioFormatFlagIsSignedInteger 샘플의 숫자형식을 식별
        //kAudioFormatFlagIsPacked 샘플 값이 각 바이트에 가용한 모든 비트를 사용하느지 여부
        asbd.mFormatFlags = kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        
        asbd.mBitsPerChannel = 16;  //16비트 샘플
        asbd.mChannelsPerFrame = 1;
        
        asbd.mFramesPerPacket = 1;
        //LPCM은 패킷을 사용하지 않고(가변 비트율 형식에만 유용함)
        asbd.mBytesPerFrame = 2;
        asbd.mBytesPerPacket = 2;
        
        //파일을 설정
        AudioFileID audioFile;
        OSStatus audioErr = noErr;
        
        //AudioFileID를 만들라고 코어 오디오에 요청
        //kAudioFileFlags_EraseFile 동작플래그(동일한 이름의 이미 존재하는 파일을 덮어쓰기 위한 의지를 나타냄)
        audioErr = AudioFileCreateWithURL((__bridge CFURLRef)fileURL, kAudioFileAIFFType, &asbd, kAudioFileFlags_EraseFile, &audioFile);
        
        assert(audioErr == noErr);
        
        
        //샘플 작성 시작
        //초당 SAMPLE_RATE 샘플에서 소리의 DURATION 초에 필요할 얼마나 많은 샘플이 필요한지 계산
        long maxSampleCount = SAMPLE_RATE * DURATION;
        
        long sampleCount = 0;
        UInt32 bytesToWrite = 2;
        double wavelengthInSamples = SAMPLE_RATE / hz;
        
        
        while(sampleCount < maxSampleCount) {
            for (int i=0; i < wavelengthInSamples; i++) {
                //Square wave
                /*
                SInt16 sample;
                if( i < wavelengthInSamples / 2) {
                    //빅엔디언으로 바이트를 변경할 필요가 있다.
                    sample = CFSwapInt16HostToBig(SHRT_MAX);
                    
                }else {
                    sample = CFSwapInt16HostToBig(SHRT_MIN);
                }
                */
                
                
                SInt16 sample = CFSwapInt16HostToBig(((i / wavelengthInSamples) * SHRT_MAX * 2) - SHRT_MAX);
                
                
                
                
                
                //AudioFileID
                //캐싱플래그
                //오디오 데이터에서 위치 오프셋
                //작성될 바이트의 수
                //작성할 바이트의 포인터
                
                
                //*압축 형식을 작성할 때와 같은 더욱 일반적인 경우에는 더욱 복잡한 AudioFileWritePackets()을 사용
                audioErr = AudioFileWriteBytes(audioFile, false, sampleCount*2, &bytesToWrite, &sample);
                
                assert(audioErr == noErr);
                sampleCount++;
                
            }
            
            
        }
        
        audioErr = AudioFileClose(audioFile);
        assert(audioErr == noErr);
        
        NSLog(@"wrote %ld samples", sampleCount);
        
    }
    return 0;
}
