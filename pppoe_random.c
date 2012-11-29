/**
 * @file pppoe_random.c
 * @brief 自动进行pppoe拨号
 * @author 
 * @version 
 * @date 2012-11-29
 */
#include  <stdlib.h>
#include  <stdio.h>
#include  <string.h>
#include  "ljabits.h"

#define LEN 1000
#define NAME_LEN (9+1)
#define RAS_LEN 50

int main(int argc, char *argv[])
{
	long id;
	char name[NAME_LEN];
	char rasdial[RAS_LEN];
	memset(name,'\0',NAME_LEN);
	memset(rasdial,'\0',RAS_LEN);

	Bits bits;
	int ret = bits_init(&bits,LEN);
	if(-1 == ret){
		fprintf(stderr,"bits_init error %s %d\n",__FILE__,__LINE__);
	}

	FILE *save;
	save = fopen("random_save.txt","a+");
	if(NULL == save){
		fprintf(stderr,"open random_save.text failed\n");
		exit(1);
	}
	
	long times=0;
	long count=0;
	srand((int)time(0));
	do{
		id = rand();
		id = ((id<<4) + rand()) % LEN;
		if(!bits_get(&bits,id))
		{
			bits_set(&bits,id);
		}
		else
		{
			printf("Repeat times %ld\n",++count);
			continue;
		}
		if (LEN-1 == times){
			printf("Have try all size=%ld\n",times);
			goto EXIT;	
		}
		sprintf(name,"TYT010%03ld",id);
		sprintf(rasdial,"rasdial pppoe %s 8888\n",name);
		printf("times=%ld %s",++times,rasdial);
		ret = system(rasdial);
	}while(0 != ret);

EXIT:
	bits_destroy(&bits);
	fprintf(save,"times=%ld %s",times,rasdial);
	printf("Final Rpeat times %ld\n",count);

	return 0;
}
