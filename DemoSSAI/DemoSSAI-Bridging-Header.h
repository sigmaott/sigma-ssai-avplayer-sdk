//
//  DemoSSAI-Bridging-Header.h
//  DemoSSAI
//
//  Created by Pham Hai on 22/10/2024.
//

#ifndef DemoSSAI_Bridging_Header_h
#define DemoSSAI_Bridging_Header_h

#ifdef TARGET_OS_SIMULATOR
#else
#import "SigmaDRM.h"
//#import "<ssai-manipolution/SsaiSDK.h>"
#endif

#endif /* DemoSSAI_Bridging_Header_h */
