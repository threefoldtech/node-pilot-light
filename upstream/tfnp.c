#define _GNU_SOURCE
#include <stdio.h>
#include <sys/stat.h>
#include <string.h>
#include <dlfcn.h>
#include <errno.h>

typedef int (*orig_mkdir_t)(const char *pathname, mode_t mode);

int mkdir(const char *pathname, mode_t mode) {
    orig_mkdir_t orig_mkdir;
    orig_mkdir = (orig_mkdir_t) dlsym(RTLD_NEXT, "mkdir");

    // call original mkdir
    int value = orig_mkdir(pathname, mode);

    // does not return real error code
    // for chains directory
    if(strstr(pathname, ".node-pilot/chains")) {
        errno = 0;
        return 0;
    }

    return value;
}
