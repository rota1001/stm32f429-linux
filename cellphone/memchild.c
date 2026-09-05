/* 2-process (vfork) RAM experiment child, "DOOM-sized" variant: mmap a 1 MiB
 * zone the same way DOOM's Z_Init does (6 x 256 KiB), touch it, then hold it.
 * The parent (lvglsim) measures MemAvailable before/after, so we see whether
 * DOOM's zone can be grabbed while lvglsim is running, and how many of the
 * 256 KiB blocks actually succeed (no-MMU contiguity). */
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>

#define BLK   (256 * 1024)
#define NBLK  6                    /* 6 x 256 KiB = 1.5 MiB, like DOOM Z_Init */

int main(void)
{
    int got = 0;
    for(int i = 0; i < NBLK; i++) {
        void * p = mmap(NULL, BLK, PROT_READ | PROT_WRITE,
                        MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if(p == MAP_FAILED) break;
        memset(p, 0xA5, BLK);      /* touch -> commit (no-MMU commits at mmap) */
        got++;
    }
    printf("memchild pid=%d: got %d/%d x 256KiB = %d KiB zone\n",
           (int)getpid(), got, NBLK, got * 256);
    fflush(stdout);

    for(;;) pause();               /* hold the zone so the parent can measure */
    return 0;
}
