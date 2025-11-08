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

        while ((path = [pathSetEnumerator nextObject])) {
            NSURL* url = [NSURL fileURLWithPath:path];
            NSArray* pathTagList;

            [url getResourceValue:&pathTagList forKey:NSURLTagNamesKey error:nil];

            if (nil == pathTagList) {
                pathTagList = @[];
            }

            [pathMetadataList addObject:@{@"path" : path, @"tags" : pathTagList}];
        }

        // Output
        NSData* data = [NSJSONSerialization dataWithJSONObject:@{@"data" : pathMetadataList}
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
        NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        printf("%s\n", result.UTF8String);
    }

    return 0;
}
