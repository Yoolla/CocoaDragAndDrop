//
//  DraggingView.m
//  CocoaDraggingView
//
//  Created by Alexander Yolkin on 3/1/16.
//  Copyright © 2016 Alexander Yolkin. All rights reserved.
//

#import "DraggingView.h"
#import <QuartzCore/QuartzCore.h>

@interface DraggingView ()
{
    __weak IBOutlet NSImageView *imageView;
    __weak IBOutlet NSImageView *dropFilesImageView;
}

@end

@implementation DraggingView

- (void)awakeFromNib
{
    [self registerForDraggedTypes:[self readablePasteboardTypes]];
#warning use unregisterDraggedTypes to unregisters the view as a possible destination in a dragging session.
    [imageView unregisterDraggedTypes];
    [dropFilesImageView unregisterDraggedTypes];
    
    dropFilesImageView.hidden = YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

#pragma mark Dragging Methods

- (NSArray *)readablePasteboardTypes
{
    return [NSArray arrayWithObjects:NSURLPboardType,NSFilenamesPboardType,nil];
}

- (void)highlightDropArea:(BOOL)bHighlight
{
    dropFilesImageView.hidden = !bHighlight;
}

/**
 *  If the dragging session leaves the view’s bounds, the draggingExited: method is invoked. 
 */
- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    [self highlightDropArea:NO];
}

/**
 *  The method obtains the dragging pasteboard and available drag operations from the sender object.
 */
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSDragOperation nret = NSDragOperationNone;
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *availableTypes = [pboard types];
    if ([availableTypes containsObject:NSFilenamesPboardType])
    {
        NSArray* filePathes = [pboard propertyListForType:NSFilenamesPboardType];
        for(NSString* filePath in filePathes)
        {
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            if([self isSupportedURL:fileURL])
                nret = NSDragOperationCopy;
        }
    }
    else if ([availableTypes containsObject:NSURLPboardType])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        if([self isSupportedURL:fileURL])
            nret = NSDragOperationCopy;
    }
    
    [self highlightDropArea:nret == NSDragOperationCopy];
    return nret;
}

/**
 * When the image is dropped with a drag operation other than NSDragOperationNone, the destination is sent a prepareForDragOperation: message followed by performDragOperation: and concludeDragOperation:. You can cancel the drag by returning NO from either of the first two methods.
 */
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    BOOL result = NO;
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *availableTypes = [pboard types];
    if ([availableTypes containsObject:NSFilenamesPboardType])
    {
        NSArray* filePathes = [pboard propertyListForType:NSFilenamesPboardType];
        for(NSString* filePath in filePathes)
        {
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:fileURL];
            imageView.image = image;
            result = YES;
        }
    }
    else if ([availableTypes containsObject:NSURLPboardType])
    {
        NSURL *fileURL = [NSURL URLFromPasteboard:pboard];
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:fileURL];
        imageView.image = image;
        result = YES;
    }
    
    [self highlightDropArea:NO];
    return result;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

/**
 *  set supported files for dragging here
 */
- (BOOL)isSupportedURL:(NSURL*)fileURL
{
    NSString *fileType = [fileURL pathExtension];
    if([fileType isEqualToString:@"png"] || [fileType isEqualToString:@"jpg"])
        return YES;
    return NO;
}

@end
