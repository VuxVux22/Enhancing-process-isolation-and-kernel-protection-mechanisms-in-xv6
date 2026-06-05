#include "kernel/types.h"
#include "user/user.h"

#define N 50

int
main(void)
{
  int pid;
  
  printf("=== WITHOUT LOCK ===\n");
  for(int i = 0; i < N; i++){
    pid = fork();
    if(pid == 0){
      testnolock();
      exit(0);
    }
  }
  for(int i = 0; i < N; i++){
    wait(0);
  }
  printf("Race condition test finished.\n");

  printf("\n=== WITH SPINLOCK ===\n");
  for(int i = 0; i < N; i++){
    pid = fork();
    if(pid == 0){
      testlock();
      exit(0);
    }
  }
  for(int i = 0; i < N; i++){
    wait(0);
  }
  printf("Spinlock test finished.\n");

  exit(0);
}
