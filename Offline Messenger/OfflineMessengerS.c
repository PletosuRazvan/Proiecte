#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <signal.h>
#include <pthread.h>
#include <sqlite3.h>

#define PORT 2908

extern int errno;

typedef struct thData{
	int idThread; 
	int cl; 
}thData;

struct chat{
  char user1[64];
  char user2[64];
} useri[100];

static void *treat(void *); 
void raspunde(void *);
int checkUser(char user[]);
void addUser(char user[], char parola[]);
void logOut (char user[]);
void logIn (char user[]);
int isLogged(char user[]);
int checkPassw(char user[], char parola[]);
int getLastIdU();
void mesaj(char user1[], char user2[], char mesaj[]);
int getLastIdM();
int checkMesaje(char user1[], char user2[]);
void seen(char user1[], char user2[]);
int checkMesajePrimite(char user1[], char user2[]);

int main ()
{
  char* err;
  sqlite3* db;
  sqlite3_open("MyDb.db", &db);
  int rc= sqlite3_exec(db,"create table if not exists useri(id INT, username varchar(300), parola varchar(300), status INT)", NULL, NULL, &err);
  if (rc != SQLITE_OK) 
    printf("error\n");
  rc= sqlite3_exec(db,"create table if not exists mesaje(id INT, user1 varchar(300), user2 varchar(300), mesaj varchar(300), citit INT)", NULL, NULL, &err);
  if (rc != SQLITE_OK) 
    printf("error\n");
  rc= sqlite3_exec(db,"update useri set status = 0;", NULL, NULL, &err);
  if (rc != SQLITE_OK) 
    printf("error\n");
  sqlite3_close(db);
  struct sockaddr_in server;	
  struct sockaddr_in from;	
  int nr;		
  int sd;		
  int pid;
  pthread_t th[100];   
	int i=0;
  
  if ((sd = socket (AF_INET, SOCK_STREAM, 0)) == -1)
    {
      perror ("[server]Eroare la socket().\n");
      return errno;
    }
  int on=1;
  setsockopt(sd,SOL_SOCKET,SO_REUSEADDR,&on,sizeof(on));

  bzero (&server, sizeof (server));
  bzero (&from, sizeof (from));
  
    server.sin_family = AF_INET;	
    server.sin_addr.s_addr = htonl (INADDR_ANY);
    server.sin_port = htons (PORT);
  
  if (bind (sd, (struct sockaddr *) &server, sizeof (struct sockaddr)) == -1)
    {
      perror ("[server]Eroare la bind().\n");
      return errno;
    }

  if (listen (sd, 2) == -1)
    {
      perror ("[server]Eroare la listen().\n");
      return errno;
    }
  while (1)
    {
      int client;
      thData * td;      
      int length = sizeof (from);

      printf ("[server]Asteptam la portul %d...\n",PORT);
      fflush (stdout);
      if ( (client = accept (sd, (struct sockaddr *) &from, &length)) < 0)
	{
	  perror ("[server]Eroare la accept().\n");
	  continue;
	}
    
	td=(struct thData*)malloc(sizeof(struct thData));	
	td->idThread=i++;
	td->cl=client;

	pthread_create(&th[i], NULL, &treat, td);	      
				
	}    
};				
static void *treat(void * arg)
{		
		struct thData tdL; 
		tdL= *((struct thData*)arg);	
		printf ("[thread]- %d - Asteptam mesajul...\n", tdL.idThread);
		fflush (stdout);		 
		pthread_detach(pthread_self());		
		raspunde((struct thData*)arg);
		close ((intptr_t)arg);
		return(NULL);	
  		
};


void raspunde(void *arg)
{
  while(1)
  {
    char msg[300];
    char buf[300];
    memset(buf,0,300);
    memset(msg,0,300);
	  struct thData tdL; 
	  tdL= *((struct thData*)arg);
	  if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
			{
			  printf("[Thread %d]\n",tdL.idThread);
			  perror ("Eroare la read() de la client.\n");
			}
    if(strcmp(buf,"disconnect") == 0)
      {
        strcpy(msg, "Te-ai deconectat cu succes de la server.");
        msg[strlen(msg)]='\0';
        if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		     {
		       printf("[Thread %d] ",tdL.idThread);
		       perror ("[Thread]Eroare la write() catre client.\n");
	  	   }
	      else
		      printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);	
        if(strlen(useri[tdL.idThread].user1)>0)
          logOut(useri[tdL.idThread].user1);
        break;
      }
    else if(strcmp(buf,"register") == 0)
      {
        memset(msg, 0, 300);
        strcpy(msg, "Alege un username:");
        if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		     {
		       printf("[Thread %d] ",tdL.idThread);
		       perror ("[Thread]Eroare la write() catre client.\n");
	  	   }
	      else
		      printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
        while (1){
            memset(buf, 0, 300);
            if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
			        {
			          printf("[Thread %d]\n",tdL.idThread);
			          perror ("Eroare la read() de la client.\n");
			        }
            if(checkUser(buf) == 0)
            {
              memset(msg, 0, 300);
              strcpy(msg, "Username-ul este disponibil, pune si o parola:");
              if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		           {
		            printf("[Thread %d] ",tdL.idThread);
		            perror ("[Thread]Eroare la write() catre client.\n");
	  	         }
	            else
		            printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
              strcpy(useri[tdL.idThread].user1, buf);
              memset(buf, 0, 300);
              if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
			        {
			          printf("[Thread %d]\n",tdL.idThread);
			          perror ("Eroare la read() de la client.\n");
			        }
              addUser(useri[tdL.idThread].user1, buf);
              memset(msg, 0, 300);
              strcpy(msg, "Te-ai inregistrat cu succes");
              if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		           {
		            printf("[Thread %d] ",tdL.idThread);
		            perror ("[Thread]Eroare la write() catre client.\n");
	  	         }
	            else
		            printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
              break;
            }
            else{
              memset(msg, 0, 300);
              strcpy(msg, "Username-ul este deja utilizat, alege altul:");
              if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		           {
		            printf("[Thread %d] ",tdL.idThread);
		            perror ("[Thread]Eroare la write() catre client.\n");
	  	         }
	            else
		            printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
            }
        }	

      }
      

	  else if (strcmp(buf, "login") == 0)
    {
      if (isLogged(useri[tdL.idThread].user1))
        {
          memset(msg, 0, 300);
          strcpy(msg, "Esti deja autentificat la un cont");
          if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		        {
		          printf("[Thread %d] ",tdL.idThread);
		          perror ("[Thread]Eroare la write() catre client.\n");
	  	      }
	        else
		          printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
        }
      else
        {
          memset(msg, 0, 300);
          strcpy(msg, "Care este username-ul tau?");
          if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		        {
		          printf("[Thread %d] ",tdL.idThread);
		          perror ("[Thread]Eroare la write() catre client.\n");
	  	      }
	        else
		          printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
          while(1)
            {
              memset(buf, 0, 300);
              if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
    			      {
		              printf("[Thread %d]\n",tdL.idThread);
	                perror ("Eroare la read() de la client.\n");
	              }
              if(isLogged(buf) == 0)
                {
                  break;
                }
              else
                {
                  memset(msg, 0, 300);
                  strcpy(msg, "Cineva este deja conectat la acest user, incearca altul:");
                  if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		                {
		                  printf("[Thread %d] ",tdL.idThread);
		                  perror ("[Thread]Eroare la write() catre client.\n");
	  	              }
	                else
		                printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                }  
            }
          while(1)
            {
              if(checkUser(buf))
                {
                  memset(msg, 0, 300);
                  strcpy(msg, "Care este parola?");
                  if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		                {
		                  printf("[Thread %d] ",tdL.idThread);
		                  perror ("[Thread]Eroare la write() catre client.\n");
	  	              }
	                else
		                printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                  strcpy(useri[tdL.idThread].user1, buf);
                  break;
                }
              else
                {
                  memset(msg, 0, 300);
                  strcpy(msg, "Nu exista acest user, incearca altul:");
                  if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		                {
		                  printf("[Thread %d] ",tdL.idThread);
		                  perror ("[Thread]Eroare la write() catre client.\n");
	  	              }
	                else
		                printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                  memset(buf, 0, 300);
                  if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
    			          {
		                  printf("[Thread %d]\n",tdL.idThread);
	                    perror ("Eroare la read() de la client.\n");
	                  }
                }  
            }
          while(1)
            {
              memset(buf, 0, 300);
              if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
    			      {
		              printf("[Thread %d]\n",tdL.idThread);
	                perror ("Eroare la read() de la client.\n");
	              }
              if(checkPassw(useri[tdL.idThread].user1, buf))
                {
                  memset(msg, 0, 300);
                  strcpy(msg, "Te-ai autentificat cu succes");
                  if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		                {
		                  printf("[Thread %d] ",tdL.idThread);
		                  perror ("[Thread]Eroare la write() catre client.\n");
	  	              }
	                else
		                printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                  logIn(useri[tdL.idThread].user1);
                  break;
                }
              else
                {
                  memset(msg, 0, 300);
                  strcpy(msg, "Parola gresita, mai incearca o data:");
                  if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		                {
		                  printf("[Thread %d] ",tdL.idThread);
		                  perror ("[Thread]Eroare la write() catre client.\n");
	  	              }
	                else
		                printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                }   
            }
        }
       
    }
    else if (strcmp(buf, "logout") == 0)
      {
        if(isLogged(useri[tdL.idThread].user1))
          {
            memset(msg, 0, 300);
            strcpy(msg, "Te-ai deconectat cu succes de la username");
            if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		          {
		            printf("[Thread %d] ",tdL.idThread);
		            perror ("[Thread]Eroare la write() catre client.\n");
	  	        }
	          else
		            printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
            logOut(useri[tdL.idThread].user1);
            memset(useri[tdL.idThread].user1, 0, 64);
          }
        else 
          {
            memset(msg, 0, 300);
            strcpy(msg, "Nu esti autentificat la niciun username");
            if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		          {
		            printf("[Thread %d] ",tdL.idThread);
		            perror ("[Thread]Eroare la write() catre client.\n");
	  	        }
	          else
		            printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
          }
      }
    else if(strcmp(buf,"send message") == 0)
      {
        if(isLogged(useri[tdL.idThread].user1)){

        memset(msg, 0, 300);
        strcpy(msg, "Cui vrei sa ii trimiti mesaj?");
        if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		      {
		        printf("[Thread %d] ",tdL.idThread);
		        perror ("[Thread]Eroare la write() catre client.\n");
	        }
	      else
	          printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
        while(1)
            {
              memset(buf, 0, 300);
              if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
    			      {
		              printf("[Thread %d]\n",tdL.idThread);
	                perror ("Eroare la read() de la client.\n");
	              }
              if(checkUser(buf))
                {
                  strcpy(useri[tdL.idThread].user2, buf);
                  while(1){
                  memset(msg, 0, 300);
                  strcpy(msg, "Scrie mesajul:");
                  if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		                {
		                  printf("[Thread %d] ",tdL.idThread);
		                  perror ("[Thread]Eroare la write() catre client.\n");
	  	              }
	                else
		                printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                  memset(buf, 0, 300);
                  if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
    			          {
		                  printf("[Thread %d]\n",tdL.idThread);
	                    perror ("Eroare la read() de la client.\n");
	                  }
                  mesaj(useri[tdL.idThread].user1, useri[tdL.idThread].user2, buf);
                  memset(msg, 0, 300);
                  strcpy(msg, "Mesajul s-a transmis cu succes, mai vrei sa trimiti unul?[y/n]");
                  if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		                {
		                  printf("[Thread %d] ",tdL.idThread);
		                  perror ("[Thread]Eroare la write() catre client.\n");
	  	              }
	                else
		                printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                  memset(buf, 0, 300);
                  if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
    			          {
		                  printf("[Thread %d]\n",tdL.idThread);
	                    perror ("Eroare la read() de la client.\n");
	                  }
                  if(strcmp(buf, "n") == 0)
                    {
                      memset(msg, 0, 300);
                      strcpy(msg, "Nu afisa asta");
                      if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		                   {
		                    printf("[Thread %d] ",tdL.idThread);
		                    perror ("[Thread]Eroare la write() catre client.\n");
	  	                 }
                      else
		                    printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread); 
                       break;
                    }
                  else if(strcmp(buf, "y"))
                    {
                      while(1)
                        {
                          memset(msg, 0, 300);
                          strcpy(msg, "y/n?");
                          if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		                        {
		                          printf("[Thread %d] ",tdL.idThread);
		                          perror ("[Thread]Eroare la write() catre client.\n");
	  	                      }
                          else
		                        printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                          if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
    			                  {
		                          printf("[Thread %d]\n",tdL.idThread);
	                            perror ("Eroare la read() de la client.\n");
	                          }
                          if(strcmp(buf, "y") == 0) break;
                          if(strcmp(buf, "n") == 0)
                            {
                              memset(msg, 0, 300);
                              strcpy(msg, "Nu afisa asta");
                              if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		                            {
		                              printf("[Thread %d] ",tdL.idThread);
		                              perror ("[Thread]Eroare la write() catre client.\n");
	  	                          }
                              else
		                            printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                              break;
                            }
                        }
                        if(strcmp(msg, "Nu afisa asta") == 0)
                          break;
                    }
                  }
                  memset(useri[tdL.idThread].user2, 0, 64);
                  break;
                }
              else
                {
                  memset(msg, 0, 300);
                  strcpy(msg, "Acest user nu exista, incearca altul");
                  if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		                {
		                  printf("[Thread %d] ",tdL.idThread);
		                  perror ("[Thread]Eroare la write() catre client.\n");
	  	              }
	                else
		                printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                }  
            }
        }
        else{
          memset(msg, 0, 300);
          strcpy(msg, "Trebuie sa fii autentificat la un username pentru a utiliza aceasta comanda");
          if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		       {
		        printf("[Thread %d] ",tdL.idThread);
		        perror ("[Thread]Eroare la write() catre client.\n");
	         }
	        else
	          printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
        }
      }
    else if(strcmp(buf, "refresh") == 0)
      {
        if(isLogged(useri[tdL.idThread].user1)){
        const unsigned char* destinatar;
        memset(msg, 0, 300);
        strcpy(msg, "Ai mesaje necitie de la: ");
        int l=strlen(msg);
        char* err;
        sqlite3* db;
        sqlite3_stmt* stmt;
        sqlite3_open("MyDb.db", &db);
        char *sql = "select distinct user1 from mesaje where user2 = ? and citit = 0";
        int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);
        if (rc == SQLITE_OK)
           sqlite3_bind_text(stmt, 1, useri[tdL.idThread].user1, strlen(useri[tdL.idThread].user1), NULL);
        while(sqlite3_step(stmt) != SQLITE_DONE)
          {
            destinatar=sqlite3_column_text(stmt, 0);
            strcat(msg, destinatar);
            strcat(msg, ", ");
          }
        if (l == strlen(msg))
          {
            memset(msg, 0, 300);
            strcpy(msg, "Nu ai niciun mesaj necitit");
          }
        else
          msg[strlen(msg)-2]='\0';
        sqlite3_finalize(stmt);
        sqlite3_close(db);
        if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		      {
		        printf("[Thread %d] ",tdL.idThread);
		        perror ("[Thread]Eroare la write() catre client.\n");
	        }
	      else
	          printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
      }
      else 
          {
            memset(msg, 0, 300);
            strcpy(msg, "Nu esti autentificat la niciun username");
            if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		          {
		            printf("[Thread %d] ",tdL.idThread);
		            perror ("[Thread]Eroare la write() catre client.\n");
	  	        }
	          else
		            printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
          }
      }
    else if(strcmp(buf, "show chat") == 0)
      {
        if(isLogged(useri[tdL.idThread].user1) == 0)
          {
            memset(msg, 0, 300);
            strcpy(msg, "Nu esti autentificat la niciun username");
            if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		          {
		            printf("[Thread %d] ",tdL.idThread);
		            perror ("[Thread]Eroare la write() catre client.\n");
	  	        }
	          else
		            printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
          }
        else
          {
            memset(msg, 0, 300);
            strcpy(msg, "Istoricul conversatiei cu cine vrei sa il vezi?");
            if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		          {
		            printf("[Thread %d] ",tdL.idThread);
		            perror ("[Thread]Eroare la write() catre client.\n");
	  	        }
	          else
		            printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
            while(1)
              {
                if (strcmp(buf, "renunt") == 0) break;
                if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
    		  	      {
		                printf("[Thread %d]\n",tdL.idThread);
                    perror ("Eroare la read() de la client.\n");
                  }
                if(checkUser(buf) == 0)
                  {
                    memset(msg, 0, 300);
                    strcpy(msg, "Nu exista acest username, incearca altul");
                    if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
        		          {
		                    printf("[Thread %d] ",tdL.idThread);
		                    perror ("[Thread]Eroare la write() catre client.\n");
	  	                }
	                  else
		                  printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);

                  }
                else if(checkMesaje(useri[tdL.idThread].user1, buf) == 0)
                  {
                    memset(msg, 0, 300);
                    strcpy(msg, "Nu ai mesaje cu acest username, incearca altul");
                    if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
        		          {
		                    printf("[Thread %d] ",tdL.idThread);
		                    perror ("[Thread]Eroare la write() catre client.\n");
	  	                }
	                  else
		                  printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                  }
                else
                  {
                    strcpy(useri[tdL.idThread].user2, buf);
                    memset(msg, 0, 300);
                    strcpy(msg, "Se pregateste printarea istoricului");
                    if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
        		          {
		                    printf("[Thread %d] ",tdL.idThread);
		                    perror ("[Thread]Eroare la write() catre client.\n");
	  	                }
	                  else
		                  printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                    char *err;
                    const unsigned char* destinatar;
                    const unsigned char* mesaj;
                    sqlite3* db;
                    sqlite3_stmt* stmt;
                    sqlite3_open("MyDb.db", &db);
                    char *sql = "select user1, mesaj from mesaje where ( user1 = ? and user2 = ? ) or ( user1 = ? and user2 = ? )";
                    int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);
                    if (rc == SQLITE_OK)
                      {
                        sqlite3_bind_text(stmt, 1, useri[tdL.idThread].user1, strlen(useri[tdL.idThread].user1), NULL);
                        sqlite3_bind_text(stmt, 2, useri[tdL.idThread].user2, strlen(useri[tdL.idThread].user2), NULL);
                        sqlite3_bind_text(stmt, 3, useri[tdL.idThread].user2, strlen(useri[tdL.idThread].user2), NULL);
                        sqlite3_bind_text(stmt, 4, useri[tdL.idThread].user1, strlen(useri[tdL.idThread].user1), NULL);
                      }
                    while(1)
                      {
                        if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
    		  	              {
		                        printf("[Thread %d]\n",tdL.idThread);
                            perror ("Eroare la read() de la client.\n");
                          }
                        if(sqlite3_step(stmt) == SQLITE_DONE)
                          {
                            sqlite3_finalize(stmt);
                            sqlite3_close(db);
                            memset(msg, 0, 300);
                            strcpy(msg, "Am terminat de trimis");
                            if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
        		                  {
		                            printf("[Thread %d] ",tdL.idThread);
		                            perror ("[Thread]Eroare la write() catre client.\n");
	  	                        }
	                          else
		                          printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                            break;
                          }
                        else
                          {
                            destinatar=sqlite3_column_text(stmt,0);
                            mesaj=sqlite3_column_text(stmt,1);
                            memset(msg, 0, 300);
                            strcpy(msg, destinatar);
                            strcat(msg, ": ");
                            strcat(msg, mesaj);
                            if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
        		                  {
		                            printf("[Thread %d] ",tdL.idThread);
		                            perror ("[Thread]Eroare la write() catre client.\n");
	  	                        }
	                          else
		                          printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                          }
                          
                      }
                    seen(useri[tdL.idThread].user1, useri[tdL.idThread].user2);
                    memset(useri[tdL.idThread].user2, 0, 64);
                    break;
                  }  
              }
          }
        
      }
    else if(strcmp(buf, "reply to") == 0)
      {
        if(isLogged(useri[tdL.idThread].user1) == 0)
          {
            memset(msg, 0, 300);
            strcpy(msg, "Nu esti autentificat la niciun username");
            if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		          {
		            printf("[Thread %d] ",tdL.idThread);
		            perror ("[Thread]Eroare la write() catre client.\n");
	  	        }
	          else
		            printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
          }
        else 
          {
            memset(msg, 0, 300);
            strcpy(msg, "Cui vrei sa ii raspunzi?");
            if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
		          {
		            printf("[Thread %d] ",tdL.idThread);
		            perror ("[Thread]Eroare la write() catre client.\n");
	  	        }
	          else
		            printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
            while(1)
              { 
                if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
    		  	      {
		                printf("[Thread %d]\n",tdL.idThread);
                    perror ("Eroare la read() de la client.\n");
                  }
                if (strcmp(buf, "renunt") == 0)
                  {
                    memset(msg, 0, 300);
                    strcpy(msg, "Nu afisa asta");
                    if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
        		          {
		                    printf("[Thread %d] ",tdL.idThread);
		                    perror ("[Thread]Eroare la write() catre client.\n");
	  	                }
	                  else
		                  printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                    break;
                  }
                if(checkUser(buf) == 0)
                  {
                    memset(msg, 0, 300);
                    strcpy(msg, "Nu exista acest username, incearca altul");
                    if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
        		          {
		                    printf("[Thread %d] ",tdL.idThread);
		                    perror ("[Thread]Eroare la write() catre client.\n");
	  	                }
	                  else
		                  printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);

                  }
                else if(checkMesajePrimite(useri[tdL.idThread].user1, buf) == 0)
                  {
                    memset(msg, 0, 300);
                    strcpy(msg, "Nu ai primit mesaje de la acest username, incearca altul");
                    if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
        		          {
		                    printf("[Thread %d] ",tdL.idThread);
		                    perror ("[Thread]Eroare la write() catre client.\n");
	  	                }
	                  else
		                  printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                  }
                else
                  {
                    strcpy(useri[tdL.idThread].user2, buf);
                    while(1)
                      {
                        memset(msg, 0, 300);
                        strcpy(msg, "La al catalea mesaj de la coada vrei sa raspunzi?(raspunde doar cu numarul)");
                        if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
        		              {
		                        printf("[Thread %d] ",tdL.idThread);
		                        perror ("[Thread]Eroare la write() catre client.\n");
	  	                    }
	                      else
		                      printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                        if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
    		  	              {
		                        printf("[Thread %d]\n",tdL.idThread);
                            perror ("Eroare la read() de la client.\n");
                          }
                        int nrm=atoi(buf);
                        if (nrm <= checkMesajePrimite(useri[tdL.idThread].user1, useri[tdL.idThread].user2) && nrm >0)
                          {
                            memset(msg, 0, 300);
                            strcpy(msg, "Cu ce vrei sa raspunzi?");
                            if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
        		                  {
		                            printf("[Thread %d] ",tdL.idThread);
		                            perror ("[Thread]Eroare la write() catre client.\n");
	  	                        }
	                          else
		                          printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                            if (read (tdL.cl, &buf,sizeof(buf)) <= 0)
    		  	                  {
		                            printf("[Thread %d]\n",tdL.idThread);
                                perror ("Eroare la read() de la client.\n");
                              }
                            const unsigned char* mesajt;
                            char* err;
                            sqlite3* db;
                            sqlite3_stmt* stmt;
                            sqlite3_open("MyDb.db", &db);
                            int rc= sqlite3_prepare_v2(db,"select mesaj from mesaje where user1 = ? and user2 = ? order by id desc", -1, &stmt, 0);
                            if (rc == SQLITE_OK)
                              {
                                sqlite3_bind_text(stmt, 1, useri[tdL.idThread].user2, strlen(useri[tdL.idThread].user2), NULL);
                                sqlite3_bind_text(stmt, 2, useri[tdL.idThread].user1, strlen(useri[tdL.idThread].user1), NULL);
                              }
                            while(nrm>0)
                              {
                                nrm--;
                                sqlite3_step(stmt);
                              }
                            mesajt=sqlite3_column_text(stmt,0);
                            memset(msg, 0, 300);
                            strcpy(msg, "(");
                            strcat(msg, mesajt);
                            strcat(msg,"): ");
                            strcat(msg, buf);
                            sqlite3_finalize(stmt);
                            sqlite3_close(db);
                            mesaj(useri[tdL.idThread].user1, useri[tdL.idThread].user2, msg);
                            memset(msg, 0, 300);
                            strcpy(msg, "Ai raspuns cu succes");
                            if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
        		                  {
		                            printf("[Thread %d] ",tdL.idThread);
		                            perror ("[Thread]Eroare la write() catre client.\n");
	  	                        }
	                          else
		                          printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
                          }
                        break;
                      }
                    break;
                  }
              }
          }
      }
    else
    {
      memset(msg, 0, 300);
      strcpy(msg, "Nu exista aceasta comanda");
      if (write (tdL.cl, &msg, sizeof(msg)) <= 0)
        {
		      printf("[Thread %d] ",tdL.idThread);
		      perror ("[Thread]Eroare la write() catre client.\n");
	      }
      else
		      printf ("[Thread %d]Mesajul a fost trasmis cu succes.\n",tdL.idThread);
      
    }	
  }
}
int checkUser(char user[])
{
  const unsigned char* username;
  char* err;
  sqlite3* db;
  sqlite3_stmt* stmt;
  sqlite3_open("MyDb.db", &db);
  sqlite3_prepare_v2(db,"select username from useri", -1, &stmt, 0);
  while(sqlite3_step(stmt) != SQLITE_DONE)
    {
        username=sqlite3_column_text(stmt,0);
        if(strcmp(username,user) == 0)
          {
            sqlite3_finalize(stmt);
            sqlite3_close(db);
            return 1;
          }
          
    }
    sqlite3_finalize(stmt);
    sqlite3_close(db);
    return 0;
}
void addUser(char user[], char parola[])
{
  char* err;
  sqlite3* db;
  sqlite3_stmt* stmt;
  sqlite3_open("MyDb.db", &db);
  int i= getLastIdU();
  char *sql = "insert into useri values (?, ?, ?, 1);";
  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);
  if (rc == SQLITE_OK)
    {
      sqlite3_bind_int(stmt, 1, i);
      sqlite3_bind_text(stmt, 2, user, strlen(user), NULL);
      sqlite3_bind_text(stmt, 3, parola, strlen(parola), NULL);
    }
  sqlite3_step(stmt);
  sqlite3_finalize(stmt);
  sqlite3_close(db);
}
void logOut (char user[])
{
  char* err;
  sqlite3* db;
  sqlite3_stmt* stmt;
  sqlite3_open("MyDb.db", &db);
  int i= getLastIdU();
  char *sql = "update useri set status = 0 where username = ?;";
  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);
  if (rc == SQLITE_OK)
    sqlite3_bind_text(stmt, 1, user, strlen(user), NULL);
  sqlite3_step(stmt);
  sqlite3_finalize(stmt);
  sqlite3_close(db);
}
void logIn (char user[])
{
  char* err;
  sqlite3* db;
  sqlite3_stmt* stmt;
  sqlite3_open("MyDb.db", &db);
  int i= getLastIdU();
  char *sql = "update useri set status = 1 where username = ?;";
  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);
  if (rc == SQLITE_OK)
    sqlite3_bind_text(stmt, 1, user, strlen(user), NULL);
  sqlite3_step(stmt);
  sqlite3_finalize(stmt);
  sqlite3_close(db);
}
int isLogged(char user[])
{
  char* err;
  sqlite3* db;
  sqlite3_stmt* stmt;
  sqlite3_open("MyDb.db", &db);
  char *sql = "select status from useri where username = ?;";
  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);
  if (rc == SQLITE_OK)
    sqlite3_bind_text(stmt, 1, user, strlen(user), NULL);
  sqlite3_step(stmt);
  int i = sqlite3_column_int(stmt, 0);
  sqlite3_finalize(stmt);
  sqlite3_close(db);
  return i;
}
int checkPassw(char user[], char parola[])
{
  const unsigned char* passw;
  char* err;
  sqlite3* db;
  sqlite3_stmt* stmt;
  sqlite3_open("MyDb.db", &db);
  char *sql = "select parola from useri where username = ?;";
  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);
  if (rc == SQLITE_OK)
    sqlite3_bind_text(stmt, 1, user, strlen(user), NULL);
  sqlite3_step(stmt);
  passw = sqlite3_column_text(stmt, 0);
  if (strcmp(passw, parola) == 0)
    {
      sqlite3_finalize(stmt);
      sqlite3_close(db);
      return 1;
    }
  sqlite3_finalize(stmt);
  sqlite3_close(db);
  return 0;
}
int getLastIdU()
{
  char* err;
  sqlite3* db;
  sqlite3_stmt* stmt;
  sqlite3_open("MyDb.db", &db);
  sqlite3_prepare_v2(db,"select id from useri order by id desc", -1, &stmt, 0);
  sqlite3_step(stmt);
  int i = sqlite3_column_int(stmt, 0);
  i++;
  sqlite3_finalize(stmt);
  sqlite3_close(db);
  return i;
}
void mesaj(char user1[], char user2[], char mesaj[])
{
  char* err;
  sqlite3* db;
  sqlite3_stmt* stmt;
  sqlite3_open("MyDb.db", &db);
  int i= getLastIdM();
  char *sql = "insert into mesaje values (?, ?, ?, ?, 0);";
  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);
  if (rc == SQLITE_OK)
    {
      sqlite3_bind_int(stmt, 1, i);
      sqlite3_bind_text(stmt, 2, user1, strlen(user1), NULL);
      sqlite3_bind_text(stmt, 3, user2, strlen(user2), NULL);
      sqlite3_bind_text(stmt, 4, mesaj, strlen(mesaj), NULL);
    }
  sqlite3_step(stmt);
  sqlite3_finalize(stmt);
  sqlite3_close(db);
}
int getLastIdM()
{
  char* err;
  sqlite3* db;
  sqlite3_stmt* stmt;
  sqlite3_open("MyDb.db", &db);
  sqlite3_prepare_v2(db,"select id from mesaje order by id desc", -1, &stmt, 0);
  sqlite3_step(stmt);
  int i = sqlite3_column_int(stmt, 0);
  i++;
  sqlite3_finalize(stmt);
  sqlite3_close(db);
  return i;
}
int checkMesaje(char user1[], char user2[])
{
  char* err;
  sqlite3* db;
  sqlite3_stmt* stmt;
  sqlite3_open("MyDb.db", &db);
  int i=0;
  char *sql = "select * from mesaje where ( user1 = ? and user2 = ? ) or ( user1 = ? and user2 = ? )";
  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);
  if (rc == SQLITE_OK)
    {
      sqlite3_bind_text(stmt, 1, user1, strlen(user1), NULL);
      sqlite3_bind_text(stmt, 2, user2, strlen(user2), NULL);
      sqlite3_bind_text(stmt, 3, user2, strlen(user2), NULL);
      sqlite3_bind_text(stmt, 4, user1, strlen(user1), NULL);
    }
  while(sqlite3_step(stmt) != SQLITE_DONE)
    i++;
  sqlite3_finalize(stmt);
  sqlite3_close(db);
  return i;
}
void seen (char user1[], char user2[])
{
  char* err;
  sqlite3* db;
  sqlite3_stmt* stmt;
  sqlite3_open("MyDb.db", &db);
  char *sql = "update mesaje set citit = 1 where user1= ? and user2= ?;";
  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);
  if (rc == SQLITE_OK)
    {
      sqlite3_bind_text(stmt, 1, user2, strlen(user2), NULL);
      sqlite3_bind_text(stmt, 2, user1, strlen(user1), NULL);
    }
  sqlite3_step(stmt);
  sqlite3_finalize(stmt);
  sqlite3_close(db);
}
int checkMesajePrimite(char user1[], char user2[])
{
  char* err;
  sqlite3* db;
  sqlite3_stmt* stmt;
  sqlite3_open("MyDb.db", &db);
  int i=0;
  char *sql = "select * from mesaje where user1 = ? and user2 = ?";
  int rc = sqlite3_prepare_v2(db, sql, -1, &stmt, 0);
  if (rc == SQLITE_OK)
    {
      sqlite3_bind_text(stmt, 1, user2, strlen(user2), NULL);
      sqlite3_bind_text(stmt, 2, user1, strlen(user1), NULL);
    }
  while(sqlite3_step(stmt) != SQLITE_DONE)
    i++;
  sqlite3_finalize(stmt);
  sqlite3_close(db);
  return i;
}