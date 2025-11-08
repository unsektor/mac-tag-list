#import <Foundation/Foundation.h>

int main(int argc, const char* argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s path ...\n", argv[0]);
        return 1;
    }

    @autoreleasepool {
        // Collect path set
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSMutableSet* pathSet = [NSMutableSet set];

        for (int i = 1; i < argc; i++) {
            NSString* path = [[NSString alloc] initWithCString:argv[i]
                                                      encoding:NSUTF8StringEncoding];

            if ([fileManager fileExistsAtPath:path]) {
                [pathSet addObject:path];
                continue;
            }

            fprintf(stderr, "Error: path `%s` not exists\n",
                    [path cStringUsingEncoding:NSUTF8StringEncoding]);
            // ... continue program
        }

        // Collect path tags
        NSMutableArray* pathMetadataList = [NSMutableArray array];

        NSEnumerator* pathSetEnumerator = [pathSet objectEnumerator];
        NSString* path;
        NSError* error;

        while ((path = [pathSetEnumerator nextObject])) {
            NSURL* url = [NSURL fileURLWithPath:path];
            NSArray* pathTagList;

            BOOL success = [url getResourceValue:&pathTagList forKey:NSURLTagNamesKey error:&error];
            if (NO == success) {
                fprintf(stderr, "Error: unable to obtain tags for path: %s (%ld)\n",
                        [[error localizedDescription] UTF8String], (long)[error code]);
                error = nil;
            }

            if (pathTagList == nil) {
                pathTagList = @[];
            }

            NSDictionary* pathMetadata = @{@"path" : path, @"tags" : pathTagList};
            [pathMetadataList addObject:pathMetadata];
        }

        // Output
        NSData* data = [NSJSONSerialization dataWithJSONObject:@{@"data" : pathMetadataList}
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];

        if (error != nil) {
            fprintf(stderr, "Error: unable to serialize data: %s.\n", error);
            return 2;
        }

        NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        printf("%s\n", result.UTF8String);
    }

    return 0;
}
