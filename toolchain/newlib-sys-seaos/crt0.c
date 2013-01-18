extern char **environ;
extern void tzset();
extern int main(int, char **, char **);
char *___env[128];
int _start(int a, char **g, char **en)
{
	int max=32;
	int c=0;
	while(c < 127 && en[c] && en[c][0]) {
		___env[c] = (char*)malloc(strlen(en[c])+128);
		memset(___env[c], 0, strlen(en[c])+128);
		strcpy(___env[c], en[c]);
		c++;
	}
	___env[127]=0;
	environ = ___env;
	tzset();
	int ret = main(a, g, environ);
	exit(ret);
	return ret;
}
