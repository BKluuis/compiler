#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

Node *createNode(char *symbol)
{
    Node *node = (Node *)malloc(sizeof(Node));
    node->symbol = strdup(symbol);
    node->children = NULL;
    node->childCount = 0;
    return node;
}

void addChild(Node *parent, Node *child)
{
    parent->childCount++;
    parent->children = (Node **)realloc(parent->children, parent->childCount * sizeof(Node *));
    parent->children[parent->childCount - 1] = child;
}

Queue *createQueue()
{
    Queue *queue = (Queue *)malloc(sizeof(Queue));
    queue->front = queue->rear = NULL;
    return queue;
}

void enqueue(Queue *queue, Node *treeNode, int level)
{
    QueueNode *newQueueNode = (QueueNode *)malloc(sizeof(QueueNode));
    newQueueNode->treeNode = treeNode;
    newQueueNode->level = level;
    newQueueNode->next = NULL;
    if (queue->rear)
    {
        queue->rear->next = newQueueNode;
    }
    else
    {
        queue->front = newQueueNode;
    }
    queue->rear = newQueueNode;
}

Node *dequeue(Queue *queue, int *level)
{
    if (queue->front == NULL)
        return NULL;
    QueueNode *temp = queue->front;
    Node *treeNode = temp->treeNode;
    *level = temp->level;
    queue->front = queue->front->next;
    if (queue->front == NULL)
        queue->rear = NULL;
    free(temp);
    return treeNode;
}

int isQueueEmpty(Queue *queue)
{
    return queue->front == NULL;
}

void printTree(Node *root)
{
    if (root == NULL)
        return;

    Queue *queue = createQueue();
    enqueue(queue, root, 0);
    int currentLevel = -1;

    while (!isQueueEmpty(queue))
    {
        int level;
        Node *node = dequeue(queue, &level);

        if (level != currentLevel)
        {
            currentLevel = level;
            printf("\nNível %d: ", currentLevel);
        }

        printf("%s ", node->symbol);

        for (int i = 0; i < node->childCount; i++)
        {
            enqueue(queue, node->children[i], level + 1);
        }
    }

    printf("\n");
    free(queue);
}
