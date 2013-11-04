/*	QuickLook Plugin for C# .cs source files
	The code is based (ie. mostly lifted directly) from
	
	https://github.com/fousa/thong
 
*/


#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h>
#import <QuickLook/QuickLook.h>
#import <WebKit/WebKit.h>

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize);
void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail);

/* -----------------------------------------------------------------------------
    Generate a thumbnail for file

   This function's job is to create thumbnail for designated file as fast as possible
   ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
    NSString *content = [NSString stringWithContentsOfURL:(__bridge NSURL *)url
												 encoding:NSUTF8StringEncoding
													error:nil];
	
    if (content) {
        // Encapsulate the content of the .cs file in HTML
        NSString *html = [NSString stringWithFormat:@"<html><body><pre>%@</pre></body></html>", content];
        NSData *data   = [html dataUsingEncoding:NSUTF8StringEncoding];
        
		NSRect rect = NSMakeRect(0.0, 0.0, 600.0, 800.0);
		float scale = maxSize.height / 800.0;
		NSSize scaleSize = NSMakeSize(scale, scale);
		CGSize thumbSize = NSSizeToCGSize((CGSize) { maxSize.width * (600.0/800.0), maxSize.height});
        
        // Create the webview to display the thumbnail
        WebView *webView = [[WebView alloc] initWithFrame:rect];
		[webView scaleUnitSquareToSize:scaleSize];
        [webView.mainFrame.frameView setAllowsScrolling:NO];
        [webView.mainFrame loadData:data
						   MIMEType:@"text/html"
				   textEncodingName:@"utf-8" baseURL:nil];
		
		while([webView isLoading]) CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true);
        [webView display];

        // Draw the webview in the correct context
		CGContextRef context = QLThumbnailRequestCreateContext(thumbnail, thumbSize, false, NULL);
		if (context) {
			NSGraphicsContext* graphicsContext = [NSGraphicsContext graphicsContextWithGraphicsPort:(void *)context
																							flipped:webView.isFlipped];
			[webView displayRectIgnoringOpacity:webView.bounds
									  inContext:graphicsContext];
			QLThumbnailRequestFlushContext(thumbnail, context);
			CFRelease(context);
		}
    }
    
    return noErr;
}

void CancelThumbnailGeneration(void *thisInterface, QLThumbnailRequestRef thumbnail)
{
    // Implement only if supported
}
