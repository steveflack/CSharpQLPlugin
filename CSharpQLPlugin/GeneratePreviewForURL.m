/*	QuickLook Plugin for C# .cs source files
 The code is based (ie. mostly lifted directly) from
 
 https://github.com/fousa/thong
 
*/

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>


OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options);
void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview);

/* -----------------------------------------------------------------------------
   Generate a preview for file

   This function's job is to create preview for designated file
   ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	NSString *content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url
												 encoding:NSUTF8StringEncoding
													error:nil];
    
    QLPreviewRequestSetDataRepresentation(preview,(__bridge CFDataRef)[content dataUsingEncoding:NSUTF8StringEncoding],kUTTypePlainText,NULL);

    return noErr;
}

void CancelPreviewGeneration(void *thisInterface, QLPreviewRequestRef preview)
{
    // Implement only if supported
}
