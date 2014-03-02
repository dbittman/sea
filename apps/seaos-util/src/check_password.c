#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pwd.h>
#include <time.h>
#include <string.h>
#include <signal.h>
#include <sys/stat.h>
#include <time.h>
#include <errno.h>
#include <openssl/sha.h>
#include <ctype.h>

#define _SHADOW_RIGHT 0
#define _SHADOW_O_ERR 1
#define _SHADOW_NOENT 2
#define _SHADOW_WRONG 3
#define _SHADOW_F_ERR 4

void get_secure_salt(unsigned char *salt, int length)
{
	/* we trust the kernel to give us random numbers */
	FILE *randfile = fopen("/dev/random", "rb");
	if(!randfile) {
		int i;
		fprintf(stderr, "error opening /dev/random: %s\n", strerror(errno));
		fprintf(stderr, "warning - using pseudorandom number generator for salting! BAD IDEA.\n");
		srandom(time(0));
		for(i=0;i<length;i++) {
			*(salt+i) = ((double)random()/RAND_MAX) * 0xFF;
		}
	} else {
		fread(salt, sizeof(unsigned char), length, randfile);
		fclose(randfile);
	}
}

void generate_hash(unsigned char *hash, unsigned char *salt, unsigned char *password, int salt_length)
{
	SHA512_CTX c;
	unsigned char buffer[salt_length + strlen(password) + 1];
	strcpy(buffer, password);
	memcpy(buffer + strlen(password), salt, salt_length);
	
	SHA512_Init(&c);
	SHA512_Update(&c, buffer, strlen(password) + salt_length);
	SHA512_Final(hash, &c);
}

static int __get_raw(int v)
{
	if(isdigit(v)) return v - '0';
	v = tolower(v);
	return (v - 'a') + 10;
}

static int verify_hash(char *given_password, char *stored_password)
{
	char *stored_salt, *stored_hash, *algorithm;
	if(*stored_password != '$') /* format error */
		return _SHADOW_F_ERR;
	stored_password++; /* skip first $ */
	
	algorithm = stored_password;
	stored_salt = strchr(algorithm, '$');
	if(!stored_salt)
		return _SHADOW_F_ERR;
	*stored_salt=0;
	stored_salt++; /* skip $ */
	
	stored_hash = strchr(stored_salt, '$');
	if(!stored_hash)
		return _SHADOW_F_ERR;
	*stored_hash=0;
	stored_hash++;
	
	unsigned char salt[SHA512_DIGEST_LENGTH];
	unsigned char hash[SHA512_DIGEST_LENGTH];
	unsigned char compare_hash[SHA512_DIGEST_LENGTH];
	int i=0;
	while(*stored_salt) {
		unsigned char v1, v2;
		v1 = *stored_salt;
		v2 = *(stored_salt+1);
		v1 = __get_raw(v1);
		v2 = __get_raw(v2);
		salt[i] = (v1 << 4) | v2;
		stored_salt+=2;
		i++;
	}
	i=0;
	while(*stored_hash) {
		unsigned char v1, v2;
		v1 = *stored_hash;
		v2 = *(stored_hash+1);
		v1 = __get_raw(v1);
		v2 = __get_raw(v2);
		compare_hash[i] = (v1 << 4) | v2;
		stored_hash+=2;
		i++;
	}

	generate_hash(hash, salt, given_password, SHA512_DIGEST_LENGTH);
	
	if(!memcmp(hash, compare_hash, SHA512_DIGEST_LENGTH))
		return _SHADOW_RIGHT;
	return _SHADOW_WRONG;
}

int verify_password(char *login, char *given_password)
{
	FILE *f = fopen("/etc/shadow", "r");
	if(!f)
		return _SHADOW_O_ERR;
	char buffer[4096];
	while(fgets(buffer, 4095, f)) {
		/* search for user's entry */
		char *col = strchr(buffer, ':');
		if(!col)
			continue;
		/* so we can strcmp */
		*col = 0;
		if(!strcmp(buffer, login)) {
			fclose(f);
			if(!given_password) return _SHADOW_RIGHT;
			/* okay, find salt and hash */
			char *stored_password = col+1;
			char *delim = strchr(stored_password, ':');
			if(!delim) /* okay, line ends early. But we can still deal with it... */
				delim = strchr(stored_password, '\n');
			if(delim) *delim = 0;
			return verify_hash(given_password, stored_password);
		}
	}
	fclose(f);
	return _SHADOW_NOENT;
}

int check_password2(char *prompt, char *username)
{
	char buffer[128];
	
	if(verify_password(username, 0) != _SHADOW_RIGHT)
		return 1;
	
	memset(buffer, 0, 128);
	printf("%s", prompt);
	fflush(0);
	
	if(!fgets(buffer, 128, stdin)) return 0;
	
	char *nl = strchr(buffer, '\n');
	if(nl) *nl=0;
	
	int r = verify_password(username, buffer);
	switch(r) {
		case _SHADOW_F_ERR:
			fprintf(stderr, "shadow file format error!\n");
			/* fall through */
		case _SHADOW_O_ERR:
		case _SHADOW_NOENT:
		case _SHADOW_RIGHT:
			return 1;
		case _SHADOW_WRONG:
			return 0;
	}
	return 1;
}

int check_password(char *username)
{
	return check_password2("Password: ", username);
}
