/* no-MMU + musl memory experiment: how many 256 KiB blocks fit before OOM?
 *   malloc        : malloc(256K)      -> musl mmaps 256K+20 -> buddy order-7 -> 512K each
 *   malloc-margin : malloc(256K-64)   -> 256K+(-44) <= 64 pages -> order-6   -> 256K each
 *   mmap          : mmap(256K)        -> order-6                             -> 256K each
 * Proof = mmap / malloc-margin fit ~2x as many blocks as plain malloc. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/mman.h>

#define BS   (256 * 1024)
#define MAXB 64

int main(int argc, char ** argv)
{
    const char * mode = argc > 1 ? argv[1] : "malloc";
    int use_mmap = !strcmp(mode, "mmap");
    size_t req = (!strcmp(mode, "malloc-margin")) ? (BS - 64) : BS;

    void * blk[MAXB];
    size_t len[MAXB];
    int n = 0;

    for(; n < MAXB; n++) {
        void * p;
        if(use_mmap) {
            p = mmap(0, req, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);
            if(p == MAP_FAILED) p = NULL;
        }
        else {
            p = malloc(req);
        }
        if(!p) { printf("block %d (req=%zuB) FAILED\n", n, req); break; }
        memset(p, 0xA5, req);                 /* touch -> commit (no-MMU commits at alloc) */
        blk[n] = p;
        len[n] = req;
        printf("block %d: %p\n", n, p);
        fflush(stdout);
    }

    printf("=== mode=%s req=%zuKB : got %d blocks = %d KB usable ===\n",
           mode, req / 1024, n, n * (int)(req / 1024));
    fflush(stdout);

    for(int i = 0; i < n; i++) {
        if(use_mmap) munmap(blk[i], len[i]);
        else free(blk[i]);
    }
    return 0;
}
