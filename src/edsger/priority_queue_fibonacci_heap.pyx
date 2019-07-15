""" Priority queue based on a minimum binary heap.

 The following was initialy taken from the scipy library:
 https://github.com/scipy/scipy/blob/master/scipy/sparse/csgraph/_shortest_path.pyx
 Author: Jake Vanderplas  -- <vanderplas@astro.washington.edu>
 License: BSD, (C) 2011
"""

cimport cython

cdef FibonacciNode* rightmost_sibling(FibonacciNode* node) nogil:
    # Assumptions: - node is a valid pointer
    cdef FibonacciNode* temp = node
    while(temp.right_sibling):
        temp = temp.right_sibling
    return temp

cdef void initialize_node(FibonacciNode* node,
                          unsigned int index,
                          double val) nogil:
    # Assumptions: - node is a valid pointer
    #              - node is not currently part of a heap
    node.index = index
    node.val = val
    node.rank = 0
    node.state = NOT_IN_HEAP
    node.parent = NULL
    node.left_sibling = NULL
    node.right_sibling = NULL
    node.children = NULL

cdef FibonacciNode* leftmost_sibling(FibonacciNode* node) nogil:
    # Assumptions: - node is a valid pointer
    cdef FibonacciNode* temp = node
    while(temp.left_sibling):
        temp = temp.left_sibling
    return temp

cdef void add_child(FibonacciNode* node, FibonacciNode* new_child) nogil:
    # Assumptions: - node is a valid pointer
    #              - new_child is a valid pointer
    #              - new_child is not the sibling or child of another node
    new_child.parent = node

    if node.children:
        add_sibling(node.children, new_child)
    else:
        node.children = new_child
        new_child.right_sibling = NULL
        new_child.left_sibling = NULL
        node.rank = 1

cdef void add_sibling(FibonacciNode* node, FibonacciNode* new_sibling) nogil:
    # Assumptions: - node is a valid pointer
    #              - new_sibling is a valid pointer
    #              - new_sibling is not the child or sibling of another node
    cdef FibonacciNode* temp = rightmost_sibling(node)
    temp.right_sibling = new_sibling
    new_sibling.left_sibling = temp
    new_sibling.right_sibling = NULL
    new_sibling.parent = node.parent
    if new_sibling.parent:
        new_sibling.parent.rank += 1

cdef void remove(FibonacciNode* node) nogil:
    # Assumptions: - node is a valid pointer
    if node.parent:
        node.parent.rank -= 1
        if node.left_sibling:
            node.parent.children = node.left_sibling
        elif node.right_sibling:
            node.parent.children = node.right_sibling
        else:
            node.parent.children = NULL

    if node.left_sibling:
        node.left_sibling.right_sibling = node.right_sibling
    if node.right_sibling:
        node.right_sibling.left_sibling = node.left_sibling

    node.left_sibling = NULL
    node.right_sibling = NULL
    node.parent = NULL




cdef void insert_node(FibonacciHeap* heap,
                      FibonacciNode* node) nogil:
    # Assumptions: - heap is a valid pointer
    #              - node is a valid pointer
    #              - node is not the child or sibling of another node
    if heap.min_node:
        add_sibling(heap.min_node, node)
        if node.val < heap.min_node.val:
            heap.min_node = node
    else:
        heap.min_node = node

cdef void decrease_val(FibonacciHeap* heap,
                       FibonacciNode* node,
                       DTYPE_t newval) nogil:
    # Assumptions: - heap is a valid pointer
    #              - newval <= node.val
    #              - node is a valid pointer
    #              - node is not the child or sibling of another node
    #              - node is in the heap
    node.val = newval
    if node.parent and (node.parent.val >= newval):
        remove(node)
        insert_node(heap, node)
    elif heap.min_node.val > node.val:
        heap.min_node = node

cdef void link(FibonacciHeap* heap, FibonacciNode* node) nogil:
    # Assumptions: - heap is a valid pointer
    #              - node is a valid pointer
    #              - node is already within heap

    cdef FibonacciNode *linknode
    cdef FibonacciNode *parent
    cdef FibonacciNode *child

    if heap.roots_by_rank[node.rank] == NULL:
        heap.roots_by_rank[node.rank] = node
    else:
        linknode = heap.roots_by_rank[node.rank]
        heap.roots_by_rank[node.rank] = NULL

        if node.val < linknode.val or node == heap.min_node:
            remove(linknode)
            add_child(node, linknode)
            link(heap, node)
        else:
            remove(node)
            add_child(linknode, node)
            link(heap, linknode)


@cython.wraparound(False)
@cython.embedsignature(True)
@cython.boundscheck(False) # turn off bounds-checking for entire function
cdef FibonacciNode* remove_min(FibonacciHeap* heap) nogil:
    # Assumptions: - heap is a valid pointer
    #              - heap.min_node is a valid pointer
    cdef FibonacciNode *temp
    cdef FibonacciNode *temp_right
    cdef FibonacciNode *out
    cdef unsigned int i

    # make all min_node children into root nodes
    if heap.min_node.children:
        temp = leftmost_sibling(heap.min_node.children)
        temp_right = NULL

        while temp:
            temp_right = temp.right_sibling
            remove(temp)
            add_sibling(heap.min_node, temp)
            temp = temp_right

        heap.min_node.children = NULL

    # choose a root node other than min_node
    temp = leftmost_sibling(heap.min_node)
    if temp == heap.min_node:
        if heap.min_node.right_sibling:
            temp = heap.min_node.right_sibling
        else:
            out = heap.min_node
            heap.min_node = NULL
            return out

    # remove min_node, and point heap to the new min
    out = heap.min_node
    remove(heap.min_node)
    heap.min_node = temp

    # re-link the heap
    for i in range(100):
        heap.roots_by_rank[i] = NULL

    while temp:
        if temp.val < heap.min_node.val:
            heap.min_node = temp
        temp_right = temp.right_sibling
        link(heap, temp)
        temp = temp_right

    return out
