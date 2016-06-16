// "Verwaltungsverteilung"
// maximum weight perfect matching on a complete graph
// solved by branch and bound
//
// gcc -Wall verwaltungsverteilung_klemm.c -o verwaltungsverteilung_klemm
// verwaltungsverteilung_klemm < inpfile_klemm.txt

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#define namelen 20
#define maxstack 1000




void
read_matrix(int m, int N, int *weight, int *excl, char **name)
{
  int i,j,k,l,a,b,w;

  /* read line with city names and save them in the cities array*/
  char str[100];
  scanf("%[^\n]", str);
  char * cities[10];
  i=0;
  cities[i] = strtok (str," ");
  while (cities[i] != NULL)
  {
    i++;
    cities[i] = strtok (NULL, " ,.-");
  }

  /* go through cost matrix */
  for (i=k=0; i<m; i++)
    for (j=0; j<m; j++)
      {
	scanf(" %i",&w);
	if (j<i)
	  {
	    weight[k]=w;
	    name[k][0]=0;
	    sprintf(name[k],"%s %s",cities[j],cities[i]);

	    for (a=l=0; a<m; a++)
	      for (b=0; b<a; b++)
		{
		  if ((a==i)||(a==j)||(b==i)|(b==j))
		    excl[l*N+k]=excl[k*N+l]=1;
		  l++;
		}
        
	    printf(" %i %i %i %i\n",i,j,k,w);
	    k++;
	  }
      }
}

//int calc_lower_bound(int* sol, int ssol)

int
calc_lower_bound(int* sol,int m, int* ord, int* weight, int *excl)
{
  int j,c;

  j=0; c=0;
  while ((j<m/2)&&(sol[j]!=-1))
    c+=weight[ord[sol[j++]]];
  
  return c;
}

int 
main(int argc, char *argv[])
{
  int* weight; // weight[i]=contribution of item i to cost
  char** name; // name[i[ =name of item[i], normally two nodes of an edge
  int* excl; // symm matrix, excl[i*N+j]=1 <=> mutual exclusion of items i,j
  int *ord;
  int *stack,nstack;
  int *sol;

  int m; // size of graph (number of "cities")
  int N; // total number of items (edges)
  int b; // bound on cost

  int i,j,k,flag,a;
  int c;
  
  
  if (scanf("%i %i\n",&m,&b)!=2) exit(0);

  N=m*(m-1)/2; // we have a symetric matrix and have to store one half only
  printf("#cities %i #items %i #boundary %i\n",m,N,b);
  
  weight = calloc(N,sizeof(*weight));
  name   = calloc(N,sizeof(*name));
  for (i=0; i<N; i++) name[i]=calloc(namelen,sizeof(**name));
  excl   = calloc(N*N,sizeof(*excl));
  ord    = calloc(N,sizeof(*ord));
  sol    = calloc(m/2+1,sizeof(*sol));
  stack  = calloc(maxstack*m,sizeof(*stack));

  read_matrix(m,N,weight,excl,name);

  for (i=0; i<N; i++) ord[i]=i;
  do
    {
      for (i=1, flag=0; i<N; i++)
	if (weight[ord[i]]<weight[ord[i-1]])
	  { a=ord[i]; ord[i]=ord[i-1]; ord[i-1]=a; flag=1;}
    }
  while (flag);

  for (j=0; j<m/2; j++) stack[j]=-1; // totally undefined (all solutions) on stack
  nstack=1;
  
  while (nstack)
    {
      printf("#%i\n",nstack);
      nstack--;
      for (j=0; j<m; j++) // take solution set from stack
	sol[j]=stack[m*nstack+j];
    
      c=calc_lower_bound(sol,m,ord,weight,excl);

      for (j=0; j<m/2; j++)   
	if (sol[j]!=-1)
	  printf("(%s) ",name[ord[sol[j]]]);
	else
	  printf("***** ");
      printf(" %i\n",c);


      //printf("%i %i\n",nstack,c);

      i=0; while ((i!=m/2)&&(sol[i]!=-1)) i++;   // i = lowest undefined position

      if (c<=b)
	{
	  if (i==m/2) // solution singleton
	    {
	      for (j=0; j<m/2; j++)   
		printf("(%s) ",name[ord[sol[j]]]);
	      printf("sol %i\n",c);
	    }

	  else
	    {
	      k=(i==0) ? 0 : sol[i-1];
	      while (k<N-m/2+i)
		{
		  for (j=0; j<i; j++)
		    if (excl[ord[k]*N+ord[sol[j]]]) break;
		  if (j==i)
		    {
		      sol[i]=k;
		      for (j=0; j<m/2; j++)
			stack[m*nstack+j]=sol[j];
		      nstack++;
		    }
		  k++;
		}
	    }
	}
    }   
  return 0;
}
