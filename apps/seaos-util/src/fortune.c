/* 
 * Fefe's fortune(6).  Public domain.
 * Developed under the One True OS, Linux.
 * Will output a random fortune to stdout.  Does not need strfile(1).
 * Will utilize system's /dev/urandom if available.
 * Uses mmap(2) for ease and performance.
 *
 * Usage: fortune <filename1> [<filename2>...]
 */

/* Added RE matching capability, getopt handling.
 * David Frey, Oct 1998
 */

#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <time.h>
#include <locale.h>
#include <regex.h>
#include <getopt.h>
#include <dirent.h>
#define VERSION "0.1"
#define FORTUNEDIR "/usr/share/fortunes"

struct option const long_options[] =
{
  {"help",     no_argument,       0, 'h'},
  {"help",     no_argument,       0, '?'},
  {"match",    required_argument, 0, 'm'},
  {"version",  no_argument,       0, 'V'},
  {(char *)0,  0,                 0, (char)0}
};

const char *progname;

char *printquote(char *map, char *c, size_t len)
{
  while (c > map && *c != '%') c--;
      
  if (*c == '%')  c++;
  if (*c == '\n') c++;
  while (c < map + len && *c != '%')
    putchar(*c++);

  return c;
}

char *regerr(regex_t *preg, int errcode) 
{
  size_t errlen;
  char *errbuf;

  errlen=regerror(errcode, preg, NULL, 0);
  errbuf=(char *)malloc(errlen+1);
  if (errbuf == 0) {
    return NULL;
  } else {
    regerror(errcode, preg, errbuf, sizeof(errbuf));
    return errbuf;
  }
}

int printormatchfortune(char *filename, char *re)
     /* Search FILENAME for a given RE (if != NULL) or print out a 
	random fortune (if RE == NULL) 
      */
{
  int fd, len;
  int retcode = 1;
  char *map;

  fd = open(filename, 0);
  if (fd >= 0) {
    len = lseek(fd, 0, SEEK_END);
    map = (char *)mmap(0, len, PROT_READ, MAP_SHARED, fd, 0);
    if (map){
      int ofs;
      
      if (re != NULL) {
	regex_t preg;
	regmatch_t pmatch[1];
	int errcode;
	char *errbuf;
	char *m;

	errcode=regcomp(&preg, re, REG_EXTENDED);
	if (errcode != 0) {
	  errbuf=regerr(&preg, errcode);
	  fprintf(stderr, 
		  "%s: couldn't compile regular expression `%s': %s\n", 
		  progname, re,errbuf);
	  free(errbuf);
	}
	pmatch[0].rm_so=-1; pmatch[0].rm_eo=-1; m=map-1;
	while ((errcode=regexec(&preg, m+1, 1, pmatch, 0)) == 0) {
	  if (pmatch[0].rm_so != -1) {
	    m=printquote(map, m+pmatch[0].rm_so, len);
	    putchar('%'); putchar('\n');
	  }
	}
	if (errcode != REG_NOMATCH) {
	  errbuf=regerr(&preg, errcode);
	  fprintf(stderr, 
		  "%s: couldn't match regular expression `%s': %s\n", 
		  progname, re,errbuf);
	  free(errbuf);
	}
	regfree(&preg);
      } else {
	ofs = random() % len;
	printquote(map, map + ofs, len);
      }
      retcode = 0;
    } else
      fprintf(stderr, "%s: could not mmap `%s'!\n", progname, filename);
    munmap(map, len);
    close(fd);
  } else
    fprintf(stderr, "%s: could not open `%s'!\n", progname, filename);

  return retcode;
}

int main(int argc, char *argv[])
{
  int fd;
  int retcode;
  int c;
  char *re;

  progname=argv[0]; re=NULL;
  while ((c = getopt_long(argc, argv, "h?m:V",
			  long_options, (int *) 0)) != EOF) {
    switch (c) {
      case 0  : break;
      case 'h':
      case '?': fprintf(stderr,
			"Usage: fortune [-hV][-m RE] <filename1> [<filename2>...]\n");
                return 0;
      case 'V': fprintf(stderr,"%s version %s\n", progname, VERSION);
		return 0;
      case 'm': re=optarg;
      default : break;
    }
  }

  setlocale(LC_CTYPE, "");

  if ((fd = open("/dev/random", O_RDONLY)) >= 0) {
    int foo;
    if (read(fd, &foo, sizeof(int)) > 0)
      srandom(foo);
    else
      srandom(time(0));
  } else
    srandom(time(0));

  /* Were some filenames given as arguments? */
  if (argc > optind) {
    char *filename;

    if (re == NULL)
      filename = argv[(random() % (argc - optind)) + optind];
    else 
      filename = argv[optind];

    retcode = printormatchfortune(filename, re);
  } else {
    /* No? Then search the fortune directory. */
    DIR *d;

    d=opendir(FORTUNEDIR);
    if (d == NULL) {
      fprintf(stderr, "%s: could not open directory `%s'!\n", 
	      progname, FORTUNEDIR);
      retcode=1;
    } else {
      struct dirent *e;
      char *files=NULL;
      int fileno=0;

      retcode=0;
     
      chdir(FORTUNEDIR);
      while ((e=readdir(d)) != NULL) {
	struct stat sbuf;

	if (lstat(e->d_name, &sbuf) < 0) {
	  fprintf(stderr, "%s: couldn't stat `%s'.\n", progname, e->d_name);
	} else {
	  if (S_ISREG(sbuf.st_mode))
	    if (re != NULL) {
	      fprintf(stderr, "%%(%s)\n", e->d_name);
	      retcode |= printormatchfortune(e->d_name, re);
	    } else {
	      files=(char *)realloc(files,(fileno+1)*256);	       
	      strcpy(&files[fileno*256],e->d_name);
	      fileno++;
	    }
	}
      }
      
      if (closedir(d) < 0)
	fprintf(stderr, "%s: could not close directory `%s'!\n", 
		progname, FORTUNEDIR);

      if (re == NULL) {
	printormatchfortune(&files[(random() % fileno)*256], re);
	free(files);
      }
    }
  }
  return retcode;
}
