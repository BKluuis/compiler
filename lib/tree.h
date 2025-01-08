#ifndef TREE_H
#define TREE_H

typedef struct Node
{
    char *symbol;
    struct Node **children;
    int childCount;
} Node;

typedef struct QueueNode
{
    Node *treeNode;
    int level;
    struct QueueNode *next;
} QueueNode;

typedef struct Queue
{
    QueueNode *front;
    QueueNode *rear;
} Queue;

Node *createNode(char *symbol);
void addChild(Node *parent, Node *child);
Queue *createQueue();
void enqueue(Queue *queue, Node *treeNode, int level);
Node *dequeue(Queue *queue, int *level);
int isQueueEmpty(Queue *queue);
void printTree(Node *root);

#endif
