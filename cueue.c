#include "cueue.h"
#include <limits.h>

struct Queue* createQueue(unsigned capacity)
{
    struct Queue* queue = (struct Queue*)malloc(
        sizeof(struct Queue));
    queue->capacity = capacity;
    queue->front = queue->size = 0;
 
    queue->rear = capacity - 1;
    queue->elements = (int*)malloc(
        queue->capacity * sizeof(int));
    return queue;
}
 
int isFull(struct Queue* queue)
{
    return (queue->size == queue->capacity);
}
 
int isEmpty(struct Queue* queue)
{
    return (queue->size == 0);
}
 
void enqueue(struct Queue* queue, int item)
{
    queue->size++;
    queue->elements = (int*)realloc(queue->elements, sizeof(int)*(queue->size + 1));
    queue->capacity++;
    queue->rear = (queue->rear + 1) % queue->capacity;
    queue->elements[queue->rear] = item;
}

void print(struct Queue *queue){
    printf("        > ");
    for(int i = queue->size - 1; i >= 0; i--){
        printf("%d ", queue->elements[i]);
    }
    printf("\n");
}