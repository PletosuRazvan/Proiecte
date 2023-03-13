#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <netdb.h>
#include <string.h>

extern int errno;

int port;

int main (int argc, char *argv[])
{
  int sd;
  struct sockaddr_in server;
  char buf[300], s[300], msg[300];
  if (argc != 3)
    {
      printf ("Sintaxa: %s <adresa_server> <port>\n", argv[0]);
      return -1;
    }

  port = atoi (argv[2]);

  if ((sd = socket (AF_INET, SOCK_STREAM, 0)) == -1)
    {
      perror ("Eroare la socket().\n");
      return errno;
    }

  server.sin_family = AF_INET;
  server.sin_addr.s_addr = inet_addr(argv[1]);
  server.sin_port = htons (port);
  
  if (connect (sd, (struct sockaddr *) &server,sizeof (struct sockaddr)) == -1)
    {
      perror ("[client]Eroare la connect().\n");
      return errno;
    }

while (gets(s), !feof(stdin))
{
  
  
  printf("[client] Am citit %s\n",s);

  if (write (sd, &s, sizeof(s)) <= 0)
      return errno;

  if (read (sd, &buf, sizeof(buf)) < 0)
    {
      perror ("[client]Eroare la read() de la server.\n");
      return errno;
    }
  if (strcmp(buf, "Nu afisa asta"))
    printf ("%s\n", buf);
  
  if(strcmp(buf, "Se pregateste printarea istoricului") == 0)
    {
      while(1)
        {
          strcpy(msg, "In curs de printare");
          if (write (sd, &msg, sizeof(msg)) <= 0)
            {
              perror ("[client]Eroare la write() spre server.\n");
              return errno;
            }
          if (read (sd, &buf, sizeof(buf)) < 0)
            {
              perror ("[client]Eroare la read() de la server.\n");
              return errno;
            }
          if (strcmp(buf, "Am terminat de trimis") == 0)
                break;
          else 
              printf ("%s\n", buf);
        }
    }
    if (strcmp(buf, "Te-ai deconectat cu succes de la server.") == 0)
          break;
    if (strcmp(buf, "Te-ai autentificat cu succes") == 0)
      {
        memset(msg, 0, 300);
        strcpy(msg, "refresh");
        if (write (sd, &msg, sizeof(msg)) <= 0)
            {
              perror ("[client]Eroare la write() spre server.\n");
              return errno;
            }
          if (read (sd, &buf, sizeof(buf)) < 0)
            {
              perror ("[client]Eroare la read() de la server.\n");
              return errno;
            }
        printf("%s\n", buf);
      }
}
  close (sd);
}
