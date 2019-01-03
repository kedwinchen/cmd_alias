#include <stdio.h>
#include <sys/stat.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>

void usage(const char *p_cc_prg) {
    fprintf(stderr, "Usage: %s <filename>\n", p_cc_prg);
}

int main(int argc, char *argv[])
{
    const char *p_cc_prg = argv[0];
    const char *p_cc_fname = argv[1];

    if(argc != 2) {
        usage(p_cc_prg);
        exit(1);
    }
    
    struct stat r_fileInfo;
    if(stat(p_cc_fname, &r_fileInfo) < 0) {
        fprintf(stderr, "%s: error number %d (%s) while getting current permissions for file: %s\n", p_cc_prg, errno, strerror(errno), p_cc_fname); 
        exit(1);
    }

    mode_t fmode_old = r_fileInfo.st_mode;
    mode_t fmode_new = fmode_old & S_IFMT;
    if( (fmode_old & S_IRUSR) == S_IRUSR ) {fmode_new = fmode_new | S_IRUSR | S_IRGRP | S_IROTH;}
    // UCOMMENTING THE FOLLOWING LINE COULD LEAD TO SECURITY BREACHES!!! ONLY DO SO IF YOU ARE SURE YOU KNOW WHAT YOU ARE DOING!!!
    // if( (fmode_old & S_IWUSR) == S_IWUSR ) {fmode_new = fmode_new | S_IWUSR | S_IWGRP | S_IWOTH;}
    // IT IS NOT RECOMMENDED TO USE EITHER THE ONE LINE IMMEDIATELY ABOVE OR ONE LINE IMMEDIATELY BELOW
    // if( (fmode_old & S_IWUSR) == S_IWUSR ) {fmode_new = fmode_new | S_IWUSR | S_IWGRP;}
    // THE FOLLOWING LINE IS THE ONLY GUARANTEED SAFE ONE!
    if( (fmode_old & S_IWUSR) == S_IWUSR ) {fmode_new = fmode_new | S_IWUSR ;}
    if( (fmode_old & S_IXUSR) == S_IXUSR ) {fmode_new = fmode_new | S_IXUSR | S_IXGRP | S_IXOTH;}
    if( (fmode_old & S_ISUID) == S_ISUID ) {fmode_new = fmode_new | S_ISUID | S_IXUSR | S_IXGRP | S_IXOTH;}
    if( (fmode_old & S_ISGID) == S_ISGID ) {fmode_new = fmode_new | S_ISGID | S_IXUSR | S_IXGRP | S_IXOTH;}
    if( (fmode_old & S_ISVTX) == S_ISVTX ) {fmode_new = fmode_new | S_ISVTX;}

    int r = chmod(p_cc_fname, fmode_new);
    if(r < 0 || r != 0) {
        fprintf(stderr, "%s: error number %d (%s) while setting new permissions for file: %s\n", p_cc_prg, errno, strerror(errno), p_cc_fname); 
        r = errno;
    }

    fprintf(stdout, "%s: file %s: %s changing permissions from %6o to %6o\n", p_cc_prg, p_cc_fname, r == 0 ? "succeded" : "failed" ,fmode_old, fmode_new);

    exit(r);
}
