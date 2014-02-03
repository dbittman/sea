extern char **environ;
extern void tzset();
extern int main(int, char **, char **);
int _start(int a, char **g, char **en)
{
	environ = en;
	tzset();
	int ret = main(a, g, environ);
	exit(ret);
	return ret;
}
