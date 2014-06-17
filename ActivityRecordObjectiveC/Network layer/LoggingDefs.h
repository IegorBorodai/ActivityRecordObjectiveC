//
//  LoggingDefs.h
//  localsgowild
//
//  Created by Arakelyan on 10/30/13.
//  Copyright (c) 2013 massinteractiveserviceslimited. All rights reserved.
//

#ifndef localsgowild_LoggingDefs_h
#define localsgowild_LoggingDefs_h

//#import "LoggerClient.h"


//#define CONSOLE_LOG

#ifdef DEBUG
#define NetLogging
#endif





#ifdef DEBUG
    #ifdef CONSOLE_LOG
        #define LOG_NETWORK_L(level, fmt, ...)     NSLog(fmt, ##__VA_ARGS__)
        #define LOG_GENERAL_L(level, fmt, ...)     NSLog(fmt, ##__VA_ARGS__)
        #define LOG_COREDATA_L(level, fmt, ...)    NSLog(fmt, ##__VA_ARGS__)
        #define LOG_SOCKET_L(level, fmt, ...)      NSLog(fmt, ##__VA_ARGS__)
        #define LOG_DEALLOC_L(level, fmt, ...)     NSLog(fmt, ##__VA_ARGS__)
        #define LOG_FACEBOOK_L(level, fmt, ...)    NSLog(fmt, ##__VA_ARGS__)
        #define LOG_CONVERSION_L(level, fmt, ...)  NSLog(fmt, ##__VA_ARGS__)
        #define LOG_IMAGE(...)                  do{}while(0)
    #else
        #define LOG_NETWORK_L(level, ...)    LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"network",level,__VA_ARGS__)
        #define LOG_GENERAL_L(level, ...)    LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"general",level,__VA_ARGS__)
        #define LOG_COREDATA_L(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"coredata",level,__VA_ARGS__)
        #define LOG_SOCKET_L(level, ...)     LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"socket",level,__VA_ARGS__)
        #define LOG_DEALLOC_L(level, ...)    LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"dealloc",0,__VA_ARGS__)
        #define LOG_FACEBOOK_L(level, ...)   LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"facebook",0,__VA_ARGS__)
        #define LOG_CONVERSION_L(level, ...) LogMessageF(__FILE__,__LINE__,__FUNCTION__,@"conversion",0,__VA_ARGS__)
        #define LOG_IMAGE(IMAGE)     LogImageDataF(__FILE__, __LINE__, __FUNCTION__, @"image", 0, ((UIImage *)IMAGE).size.width, ((UIImage *)IMAGE).size.height, UIImagePNGRepresentation(IMAGE))
    #endif
#else
    #define LOG_NETWORK_L(...)    do{}while(0)
    #define LOG_GENERAL_L(...)    do{}while(0)
    #define LOG_COREDATA_L(...)   do{}while(0)
    #define LOG_SOCKET_L(...)     do{}while(0)
    #define LOG_DEALLOC_L(...)    do{}while(0)
    #define LOG_FACEBOOK_L(...)   do{}while(0)
    #define LOG_CONVERSION_L(...) do{}while(0)
    #define LOG_IMAGE(...)        do{}while(0)
#endif


#define LOG_NETWORK(...)    LOG_NETWORK_L(0, __VA_ARGS__)
#define LOG_GENERAL(...)    LOG_GENERAL_L(0, __VA_ARGS__)
#define LOG_COREDATA(...)   LOG_COREDATA_L(0, __VA_ARGS__)
#define LOG_SOCKET(...)     LOG_SOCKET_L(0, __VA_ARGS__)
#define LOG_DEALLOC(...)    LOG_DEALLOC_L(0, __VA_ARGS__)
#define LOG_FACEBOOK(...)   LOG_FACEBOOK_L(0, __VA_ARGS__)
#define LOG_CONVERSION(...) LOG_CONVERSION_L(0, __VA_ARGS__)

//#define DLog(fmt, ...) LOG_GENERAL(fmt, ##__VA_ARGS__);
//#define Net_DLog(...) LOG_NETWORK(__VA_ARGS__);


#endif
