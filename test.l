(load "rb-tree.l")

(symbols '(rbtree pico))

(def '*units-test
  '(test-delete-tree-one-by-one
    test-delete-single-child
    test-delete-single-deep-child
    test-deletion-black-node-black-successor-no-child-case-4
    test-deletion-black-node-black-successor-right-red-child
    test-deletion-black-node-no-successor-case-3-then-1
    test-deletion-black-node-no-successor-case-3-then-5-then-6
    test-deletion-black-node-no-successor-case-6
    test-deletion-black-node-successor-case-2-then-4
    test-deletion-red-node-red-successor-no-children
    test-deletion-root
    test-deletion-root-2-nodes
    test-functional-test-build-tree
    test-left-right-rotation-no-sibling
    test-left-rotation-no-sibling
    test-mirror-deletion-black-node-no-successor-case-3-then-5-then-6
    test-mirror-deletion-black-node-no-successor-case-6
    test-mirror-deletion-black-node-successor-case-2-then-4
    test-mirror-deletion-red-node-red-successor-no-children
    test-recolor-lr
    test-recoloring-only
    test-recoloring-two
    test-right-left-rotation-after-recolor
    test-right-left-rotation-no-sibling
    test-right-rotation
    test-right-rotation-after-recolor
    test-right-rotation-no-sibling-left-subtree

    test-addition-performance
    test-deletion-performance
    test-deletion-and-addition-performance

    test-add-delete-random-order
    test-add-0-to-100-delete-100-to-0
    test-add-delete-0-to-100-delete-0-to-100

    test-ceil
    test-ceil-same-value
    test-floor
    test-floor-same))

(de run-tests ()
  (for X *units-test
    (prinl) (prinl)
    (prin "Test: ") (println X)
    (X)
    (prinl "Passed: " X))
  (prinl "All tests passed! Bye!")
  (bye))

(de assert-T (A)
  ~(assert A))

(de assert-not (A)
  ~(assert (not A)))

(de assert-eq-num (A B)
  ~(assert (= A B)))

(de assert-eq-list (A B)
  ~(assert (= A B)))

(de assert-eq @
  # first is symbol then props...
  # last is B
  (let (Sym (next)
        Args (rest)
        Props (head -1 Args)
        B (last Args)
        A (apply 'get Props Sym))
    ~(assert (= A B))))

(de test-recoloring-only ()
    "
    Create a red-black tree add a red no(e such that we only have to recolor
    upwards twice
    add 4 which recolors 2 and 8 to 'black
            6 to 'red
                -10 20 to 'black
    :return:
    "

    (setq tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL))
    # LEFT SUBTREE
    (setq node-m10 (new '(+RBNode) -10 'red root)) #OK
    (setq node-6 (new '(+RBNode) 6 'black node-m10)) #OK
    (setq node-8 (new '(+RBNode) 8 'red node-6 *nil-leaf *nil-leaf)) #OK
    (setq node-2 (new '(+RBNode) 2 'red node-6 *nil-leaf *nil-leaf)) #OK
    (put node-6 'left node-2) #OK
    (put node-6 'right node-8) #OK
    (setq node-m20 (new '(+RBNode) -20 'black node-m10 *nil-leaf *nil-leaf)) #OK
    (put node-m10 'left node-m20) #OK
    (put node-m10 'right node-6) #OK

    # RIGHT SUBTREE
    (setq node-20 (new '(+RBNode) 20 'red root)) #OK
    (setq node-15 (new '(+RBNode) 15 'black node-20 *nil-leaf *nil-leaf)) #OK
    (setq node-25 (new '(+RBNode) 25 'black node-20 *nil-leaf *nil-leaf)) #OK
    (put node-20 'left node-15) #OK
    (put node-20 'right node-25) #OK

    (put root 'left node-m10) #OK
    (put root 'right node-20) #OK

    (put tree 'root root)
    (add> tree 4)
    "
                -----10B-----                                     -----10B-----
            ---10R--        --20R--                           ---10R--        --20R--
        -20B      6B     15B     25B  --FIRST RECOLOR-->  -20B      6R     15B     25B
                2R  8R                                            2B  8B
            Add-->4R                                                4R



                              -----10B-----
                          ---10B--        --20B--
--SECOND RECOLOR-->    -20B      6R     15B     25B
                              2B  8B
                                4R
    "
    " This should trigger two recolors.
        2 and 8 should turn to black
        6 should turn to red
        -10 and 20 should turn to black
        10 should try to turn to red but since it's the root it can't be black"
    (setq expected-values (-20 -10 2 4 6 8 10 15 20 25))
    (setq values (list> tree))
    (assert-eq-list values expected-values)

    (assert-eq node-2   'color 'black)
    (assert-eq node-8   'color 'black)
    (assert-eq node-6   'color 'red  )
    (assert-eq node-m10 'color 'black)
    (assert-eq node-20  'color 'black))


(de test-recoloring-two ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # left subtree
    (setq node-m10 (new '(+RBNode) -10 'red root *nil-leaf *nil-leaf))
    (setq node-m20 (new '(+RBNode) -20 'black node-m10 *nil-leaf *nil-leaf))
    (setq node-6 (new '(+RBNode) 6 'black node-m10 *nil-leaf *nil-leaf))
    (put node-m10 'left node-m20)
    (put node-m10 'right node-6)

    # right subtree
    (setq node-20 (new '(+RBNode) 20 'red root *nil-leaf *nil-leaf))
    (setq node-15 (new '(+RBNode) 15 'black node-20 *nil-leaf *nil-leaf))
    (setq node-25 (new '(+RBNode) 25 'black node-20 *nil-leaf *nil-leaf))
    (put node-20 'left node-15)
    (put node-20 'right node-25)
    (setq node-12 (new '(+RBNode) 12 'red node-15 *nil-leaf *nil-leaf))
    (setq node-17 (new '(+RBNode) 17 'red node-15 *nil-leaf *nil-leaf))
    (put node-15 'left node-12)
    (put node-15 'right node-17)

    (put root 'left node-m10)
    (put root 'right node-20)
    (put rb-tree 'root root)
    (add> rb-tree 19)


    "

              -----10B-----                                        -----10B-----
        ---10R--        --20R--                              ---10R--        --20R--
      -20B      6B     15B     25B     FIRST RECOLOR-->    -20B      6B     15R     25B
                    12R  17R                                             12B  17B
                    Add-->19R                                                 19R


    SECOND RECOLOR


            -----10B-----
        ---10B--        --20B--
    -20B      6B     15R     25B
                  12B  17B
                        19R
    "

    (setq expected-values (-20 -10 6 10 12 15 17 19 20 25))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-19 (get node-17 'right))
    (assert-eq node-19 'value 19)
    (assert-eq node-19 'color 'red)
    (assert-eq node-19 'parent node-17)

    (assert-eq node-17 'color 'black)
    (assert-eq node-12 'color 'black)
    (assert-eq node-15 'color 'red)
    (assert-eq node-20 'color 'black)
    (assert-eq node-25 'color 'black)
    (assert-eq node-m10 'color 'black)
    (assert-eq rb-tree 'root 'color 'black))


(de test-right-rotation ()
    (setq tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL))

    # LEFT SUBTREE
    (setq node-m10 (new '(+RBNode) -10 'black root *nil-leaf *nil-leaf))
    (setq node-7 (new '(+RBNode) 7 'red node-m10 *nil-leaf *nil-leaf))
    (put node-m10 'right node-7)

    # RIGHT SUBTREE
    (setq node-20 (new '(+RBNode) 20 'black root *nil-leaf *nil-leaf))
    (setq node-15 (new '(+RBNode) 15 'red node-20 *nil-leaf *nil-leaf))
    (put node-20 'left node-15)

    (put root 'left node-m10)
    (put root 'right node-20)

    (put tree 'root root)
    (add> tree 13)

    "
              ----10B----                                           ----10B----
          -10B          20B       --(LL -> R) RIGHT ROTATE-->    -10B         15B
              7R       15R                                           7R      13R 20R
              Add -> 13R
    "
    (setq expected-values (-10 7 10 13 15 20))
    (setq values (list> tree))
    (assert-eq-list values expected-values)

    (setq node-20 (get node-15 'right))
    (setq node-13 (get node-15 'left))

    (assert-eq node-15 'color 'black)  # this should be the parent of both now
    (assert-eq node-15 'parent  'value 10)

    (assert-eq node-20 'value 20)
    (assert-eq node-20 'color 'red)
    (assert-eq node-20 'parent  'value 15)
    (assert-eq node-20 'left *nil-leaf)
    (assert-eq node-20 'right *nil-leaf)

    (assert-eq node-13 'value 13)
    (assert-eq node-13 'color 'red)
    (assert-eq node-13 'parent  'value 15)
    (assert-eq node-13 'left *nil-leaf)
    (assert-eq node-13 'right *nil-leaf))


(de test-left-rotation-no-sibling ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # LEFT SUBTREE
    (setq node-7 (new '(+RBNode) 7 'black root *nil-leaf *nil-leaf))
    (setq node-8 (new '(+RBNode) 8 'red node-7 *nil-leaf *nil-leaf))
    (put node-7 'right node-8)

    # RIGHT SUBTREE
    (setq rightest (new '(+RBNode) 20 'black root *nil-leaf *nil-leaf))
    (put root 'left node-7)
    (put root 'right rightest)

    (put rb-tree 'root root)
    (add> rb-tree 9)
    "
              -->     10B                                10B
    ORIGINAL -->  7B    20B  --LEFT ROTATION-->       8B   20B
              -->    8R                              7R  9R
              -->     9R
    We add 9 which is the right child of 8 and causes a red-red relationship
    this calls for a left rotation so 7 becomes left child of 8 and 9 the right child of 8
    8 is black 7 and 9 are red
    "
    (setq expected-values (7 8 9 10 20))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-9 (get node-8 'right))

    (assert-eq node-9 'value 9)
    (assert-eq node-9 'color 'red)
    (assert-eq node-9 'parent  'value 8)
    (assert-eq node-9 'left *nil-leaf)
    (assert-eq node-9 'right *nil-leaf)

    (assert-eq node-8 'parent  'value 10)
    (assert-eq node-8 'color 'black)
    (assert-eq node-8 'left  'value 7)
    (assert-eq node-8 'right  'value 9)

    (assert-eq node-7 'color 'red)
    (assert-eq node-7 'parent  'value 8)
    (assert-eq node-7 'left *nil-leaf)
    (assert-eq node-7 'right *nil-leaf))


(de test-right-rotation-no-sibling-left-subtree ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # LEFT SUBTREE
    (setq node-m10 (new '(+RBNode) -10 'black root *nil-leaf *nil-leaf))
    (setq node-m11 (new '(+RBNode) -11 'red node-m10 *nil-leaf *nil-leaf))
    (put node-m10 'left node-m11)
    # RIGHT SUBTREE
    (setq node-20 (new '(+RBNode) 20 'black root *nil-leaf *nil-leaf))
    (setq node-15 (new '(+RBNode) 15 'red node-20 *nil-leaf *nil-leaf))
    (put node-20 'left node-15)

    (put root 'left node-m10)
    (put root 'right node-20)
    (put rb-tree 'root root)
    (add> rb-tree -12)
    "


                        ----10----                                       ----10----
                    ---10B--     20B  (LL->R) Right rotate-->          -11B        20B
                -11R          15R                                   -12R  -10R   15R
      Add--> 12R



    red-red relationship with -11 -12 so we do a right rotation where -12 becomes the left child of -11
                                                                        -10 becomes the right child of -11
    -11's parent is root -11 is black -10-12 are 'red
    "
    (setq expected-values (-12 -11 -10 10 15 20))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-m12 (get node-m11 'left))
    (assert-eq rb-tree 'root 'left 'value -11)

    (assert-eq node-m12 'value -12)
    (assert-eq node-m12 'color 'red)
    (assert-eq node-m12 'parent 'value -11)
    (assert-eq node-m12 'left *nil-leaf)
    (assert-eq node-m12 'right *nil-leaf)

    (assert-eq node-m11 'color 'black)
    (assert-eq node-m11 'parent (get rb-tree 'root))
    (assert-eq node-m11 'left  'value -12)
    (assert-eq node-m11 'right  'value -10)

    (assert-eq node-m10 'color 'red)
    (assert-eq node-m10 'parent 'value -11)
    (assert-eq node-m10 'left *nil-leaf)
    (assert-eq node-m10 'right *nil-leaf))

(de test-left-right-rotation-no-sibling ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # LEFT PART
    (setq node-m10 (new '(+RBNode) -10 'black root *nil-leaf *nil-leaf))
    (setq node-7 (new '(+RBNode) 7 'red node-m10 *nil-leaf *nil-leaf))
    (put node-m10 'right node-7)

    # RIGHT PART
    (setq node-20 (new '(+RBNode) 20 'black root *nil-leaf *nil-leaf))
    (setq node-15 (new '(+RBNode) 15 'red node-20 *nil-leaf *nil-leaf))
    (put node-20 'left node-15)

    (put root 'left node-m10)
    (put root 'right node-20)

    (put rb-tree 'root root)
    (add> rb-tree 17)
    "
                ---10---                                                     ----10----
              -10B      20B                                                -10B        20B
                7R   15R        --(LR=>RL) Left Rotate (no recolor) -->      7R     17R
                Add--> 17R                                                         15R



                                            ----10----
    Right Rotate (with recolor) -->      -10B        17B
                                            7R     15R 20R

    15-17 should do a left rotation so 17 is now the parent of 15.
    Then a right rotation should be done so 17 is the parent of 20(15's prev parent)
    Also a recoloring should be done such that 17 is now black and his children are red
    "
    (setq expected-values (-10 7 10 15 17 20))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-15 node-15)
    (setq node-20 node-20)
    (setq node-17 (get node-15 'parent))
    (assert-eq rb-tree 'root 'right node-17)

    (assert-eq node-17 'value 17)
    (assert-eq node-17 'color 'black)
    (assert-eq node-17 'parent (get rb-tree 'root))
    (assert-eq node-17 'left 'value 15)
    (assert-eq node-17 'right 'value 20)

    (assert-eq node-20 'parent 'value 17)
    (assert-eq node-20 'color 'red)
    (assert-eq node-20 'left *nil-leaf)
    (assert-eq node-20 'right *nil-leaf)

    (assert-eq node-15 'parent 'value 17)
    (assert-eq node-15 'color 'red)
    (assert-eq node-15 'left *nil-leaf)
    (assert-eq node-15 'right *nil-leaf))


(de test-right-left-rotation-no-sibling ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # LEFT PART
    (setq node-m10 (new '(+RBNode) -10 'black root *nil-leaf *nil-leaf))
    (setq node-7 (new '(+RBNode) 7 'red node-m10 *nil-leaf *nil-leaf))
    (put node-m10 'right node-7)

    # RIGHT PART
    (setq node-20 (new '(+RBNode) 20 'black root *nil-leaf *nil-leaf))
    (setq node-15 (new '(+RBNode) 15 'red node-20 *nil-leaf *nil-leaf))
    (put node-20 'left node-15)

    (put root 'left node-m10)
    (put root 'right node-20)

    (put rb-tree 'root root)
    (add> rb-tree 2)
    "

        ---10---                                                        ---10---
      -10B       20B                                                  -10B       20B
        7R     15R   --- (LR=>RL) Right Rotation (no recolor)-->        2R    15R
Add--> 2R                                                                7R


                                              -----10-----
    Left Rotation (with recolor) -->     --2B--       --20B--
                                      -10R     7R    15R


    2 goes as left to 7 but both are red so we do a RIGHT-LEFT rotation
    First a right rotation should happen so that 2 becomes the parent of 7 [2 right-> 7]
    Second a left rotation should happen so that 2 becomes the parent of -10 and 7
    2 is black -10 and 7 are now red. 2's parent is the root - 10)
    "
    (setq expected-values (-10 2 7 10 15 20))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-2 (get node-7 'parent))
    (assert-eq node-2 'parent 'value 10)
    (assert-eq node-2 'color 'black)
    (assert-eq node-2 'left 'value -10)
    (assert-eq node-2 'right 'value 7)

    (assert-eq node-7 'color 'red)
    (assert-eq node-7 'parent 'value 2)
    (assert-eq node-7 'left *nil-leaf)
    (assert-eq node-7 'right *nil-leaf)

    (assert-eq node-m10 'color 'red)
    (assert-eq node-m10 'parent 'value 2)
    (assert-eq node-m10 'left *nil-leaf)
    (assert-eq node-m10 'right *nil-leaf))


(de test-recolor-lr ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL))
    # RIGHT SUBTREE
    (setq node-m10 (new '(+RBNode) -10 'red root *nil-leaf *nil-leaf))
    (setq node-m20 (new '(+RBNode) -20 'black node-m10 *nil-leaf *nil-leaf))
    (put node-m10 'left node-m20)
    (setq node-6 (new '(+RBNode) 6 'black node-m10 *nil-leaf *nil-leaf))
    (put node-m10 'right node-6)
    (setq node-1 (new '(+RBNode) 1 'red node-6 *nil-leaf *nil-leaf))
    (put node-6 'left node-1)
    (setq node-9 (new '(+RBNode) 9 'red node-6 *nil-leaf *nil-leaf))
    (put node-6 'right node-9)

    # LEFT SUBTREE
    (setq node-20 (new '(+RBNode) 20 'black root *nil-leaf *nil-leaf))
    (setq node-15 (new '(+RBNode) 15 'red node-20 *nil-leaf *nil-leaf))
    (put node-20 'left node-15)
    (setq node-30 (new '(+RBNode) 30 'red node-20 *nil-leaf *nil-leaf))
    (put node-20 'right node-30)

    (put root 'left node-m10)
    (put root 'right node-20)
    (put rb-tree 'root root)
    (add> rb-tree 4)

    #{

            ---------10B---------                                      ---------10B---------
        ----10R---              --20B--                            ----10R---              --20B--
    -20B      --6B--         15R     30R  ---RECOLORS TO -->   -20B      --6R--         15R     30R
            1R     9R                                                  1B     9B
              4R                                                         4R

                                  ---------10B---------
                              ---6R---              --20B--                                   ------6B--
    LEFT ROTATOES TO --> ---10B--    9B         15R      30R   ---RIGHT ROTATES TO-->   ---10R--       -10R-
                      -20B      1B                                                   -20B      1B    9B   --20B--
                                  4R                                                             4R     15R     30R



    Adding 4 we recolor once then we check upwards and see that there's a black sibling.
    We see that our direction is RightLeft (RL) and do a Left Rotation followed by a Right Rotation
    -10 becomes 6's left child and 1 becomes -10's right child
    }#

    (setq expected-values (-20 -10 1 4 6 9 10 15 20 30))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-10(get rb-tree 'root 'right))
    (setq node-4 (get node-1 'right))

    (assert-eq rb-tree 'root  'value     6)
    (assert-eq rb-tree 'root 'parent    NIL)
    (assert-eq rb-tree 'root 'left  'value -10)
    (assert-eq rb-tree 'root 'right 'value 10)

    (assert-eq node-m10 'parent 'value  6)
    (assert-eq node-m10 'color        'red)
    (assert-eq node-m10 'left   'value  -20)
    (assert-eq node-m10 'right  'value  1)

    (assert-eq node-10 'color         'red)
    (assert-eq node-10 'parent 'value   6)
    (assert-eq node-10 'left   'value   9)
    (assert-eq node-10 'right  'value   20)

    (assert-eq node-m20 'color       'black)
    (assert-eq node-m20 'parent 'value -10)
    (assert-eq node-m20 'left        *nil-leaf)
    (assert-eq node-m20 'right       *nil-leaf)

    (assert-eq node-1 'color       'black)
    (assert-eq node-1 'parent 'value -10)
    (assert-eq node-1 'left        *nil-leaf)
    (assert-eq node-1 'right 'color'red)
    (assert-eq node-4 'value       4)
    (assert-eq node-4 'color       'red))


(de test-functional-test-build-tree ()
    (setq rb-tree (new '(+Tree)))
    (add> rb-tree 2)
    (assert-eq rb-tree 'root 'value 2)
    (assert-eq rb-tree 'root 'color 'black)
    (setq node-2 (get rb-tree 'root))
    " 2 "
    (setq expected-values (2))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (add> rb-tree 1)
    "
        2B
        1R
    "
    (setq expected-values (1 2))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-1 (get rb-tree 'root 'left))
    (assert-eq node-1 'value 1)
    (assert-eq node-1 'color 'red)

    (add> rb-tree 4)
    "
        2B
      1R  4R
    "
    (setq expected-values (1 2 4))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-4 (get rb-tree 'root 'right))
    (assert-eq node-4 'value 4)
    (assert-eq node-4 'color 'red)
    (assert-eq node-4 'left *nil-leaf)
    (assert-eq node-4 'right *nil-leaf)

    (add> rb-tree 5)
    "
        2B                              2B
      1R  4R    ---CAUSES RECOLOR-->  1B  4B
            5R                              5R
    "
    (setq expected-values (1 2 4 5))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-5 (get node-4 'right))
    (assert-eq node-5 'value 5)
    (assert-eq node-4 'color 'black)
    (assert-eq node-1 'color 'black)
    (assert-eq node-5 'color 'red)

    (add> rb-tree 9)
    "
        2B                                           --2B--
      1B  4B        ---CAUSES LEFT ROTATION-->     1B     5B
            5R                                          4R  9R
              9R
    "
    (setq expected-values (1 2 4 5 9))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-9 (get node-5 'right))
    (assert-eq node-9 'value 9)
    (assert-eq node-9 'color 'red)
    (assert-eq node-9 'left *nil-leaf)
    (assert-eq node-9 'right *nil-leaf)

    (assert-eq node-4 'color 'red)
    (assert-eq node-4 'left *nil-leaf)
    (assert-eq node-4 'right *nil-leaf)
    (assert-eq node-4 'parent  'value 5)

    (assert-eq node-5 'parent  'value 2)
    (assert-eq node-5 'color 'black)
    (assert-eq node-5 'left  'value 4)
    (assert-eq node-5 'right  'value 9)

    (add> rb-tree 3)
    "
        --2B--                                  --2B--
      1B      5B     ---CAUSES RECOLOR-->     1B      5R
            4R  9R                                  4B  9B
            3R                                      3R
    "
    (setq expected-values (1 2 3 4 5 9))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-3 (get node-4 'left))
    (assert-eq node-3 'value 3)
    (assert-eq node-3 'color 'red)
    (assert-eq node-3 'left *nil-leaf)
    (assert-eq node-3 'right *nil-leaf)
    (assert-eq node-3 'parent  'value 4)

    (assert-eq node-4 'color 'black)
    (assert-eq node-4 'right *nil-leaf)
    (assert-eq node-4 'parent  'value 5)

    (assert-eq node-9 'color 'black)
    (assert-eq node-9 'parent  'value 5)

    (assert-eq node-5 'color 'red)
    (assert-eq node-5 'left  'value 4)
    (assert-eq node-5 'right  'value 9)

    (add> rb-tree 6)
    "
    Nothing special
        --2B--
      1B      5R---
            4B    -9B
          3R    6R
    "
    (setq expected-values (1 2 3 4 5 6 9))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-6 (get node-9 'left))
    (assert-eq node-6 'value 6)
    (assert-eq node-6 'color 'red)
    (assert-eq node-6 'parent  'value 9)
    (assert-eq node-6 'left *nil-leaf)
    (assert-eq node-6 'right *nil-leaf)

    (add> rb-tree 7)
    "
                --2B--                                                    --2B--
              1B      ---5R---             ---LEFT  ROTATION TO-->       1B   ---5R---
                    4B      -9B-                                             4B      9B
                  3R       6R                                               3R      7R
                            7R                                                     6B
        RIGHT ROTATION (RECOLOR) TO
              --2B--
            1B    ---5R---
                4B      7B
                3R     6R  9R
    "
    (setq expected-values (1 2 3 4 5 6 7 9))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-7 (get node-5 'right))
    (assert-eq node-7 'value 7)
    (assert-eq node-7 'color 'black)
    (assert-eq node-7 'left  'value 6)
    (assert-eq node-7 'right  'value 9)
    (assert-eq node-7 'parent  'value 5)

    (assert-eq node-5 'color 'red)
    (assert-eq node-5 'right  'value 7)

    (assert-eq node-6 'color 'red)
    (assert-eq node-6 'left *nil-leaf)
    (assert-eq node-6 'right *nil-leaf)
    (assert-eq node-6 'parent  'value 7)

    (assert-eq node-9 'color 'red)
    (assert-eq node-9 'left *nil-leaf)
    (assert-eq node-9 'right *nil-leaf)
    (assert-eq node-9 'parent  'value 7)

    (add> rb-tree 15)
    "
                --2B--                                         --2B--
            1B    ---5R---                                    1B    ---5R---
                4B      7B       ---RECOLORS TO-->                4B       7R
                3R     6R  9R                                     3R       6B 9B
                            15R                                                15R
            Red-red relationship on 5R-7R. 7R's sibling is 'black so we need to rotate.
            7 is the right child of 5 5 is the right child of 2 so we have RR => L: Left rotation with recolor
            What we get is:

                        ---5B---
                    --2R--      7R
                  1B     4B    6B 9B
                        3R         15R
    "
    (setq expected-values (1 2 3 4 5 6 7 9 15))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-15 (get node-9 'right))
    (assert-eq node-15 'color 'red)
    (assert-eq node-15 'parent  'value 9)
    (assert-eq node-15 'left *nil-leaf)
    (assert-eq node-15 'right *nil-leaf)

    (assert-eq node-9 'color 'black)
    (assert-eq node-9 'left *nil-leaf)
    (assert-eq node-9 'right  'value 15)
    (assert-eq node-9 'parent  'value 7)

    (assert-eq node-6 'color 'black)

    (assert-eq node-7 'color 'red)
    (assert-eq node-7 'left  'value 6)
    (assert-eq node-7 'right  'value 9)

    (assert-eq rb-tree 'root  'value 5)
    (assert-not (get node-5 'parent))
    (assert-eq node-5 'right  'value 7)
    (assert-eq node-5 'left  'value 2)

    (assert-eq node-2 'color 'red)
    (assert-eq node-2 'parent  'value 5)
    (assert-eq node-2 'left  'value 1)
    (assert-eq node-2 'right  'value 4)

    (assert-eq node-4 'parent  'value 2)
    (assert-eq node-4 'color 'black)
    (assert-eq node-4 'left  'value 3)
    (assert-eq node-4 'right *nil-leaf))

(de test-right-left-rotation-after-recolor ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    (setq node-10 root)

    # left subtree
    (setq node-5 (new '(+RBNode) 5 'black root *nil-leaf *nil-leaf))

    # right subtree
    (setq node-20 (new '(+RBNode) 20 'red root *nil-leaf *nil-leaf))
    (setq node-15 (new '(+RBNode) 15 'black node-20 *nil-leaf *nil-leaf))
    (setq node-25 (new '(+RBNode) 25 'black node-20 *nil-leaf *nil-leaf))
    (put node-20 'left node-15)
    (put node-20 'right node-25)

    (setq node-12 (new '(+RBNode) 12 'red node-15 *nil-leaf *nil-leaf))
    (setq node-17 (new '(+RBNode) 17 'red node-15 *nil-leaf *nil-leaf))
    (put node-15 'left node-12)
    (put node-15 'right node-17)

    (put root 'left node-5)
    (put root 'right node-20)
    (put rb-tree 'root root)
    (add> rb-tree 19)

    "
                ----10B----                           ----10B----
                5B      --20R--                       5B      --20R--
                  --15B--   25B   --RECOLORS TO-->      --15R--   25B
                12R      17R                          12B      17B
                    Add-->19R                                   19R


                              ----10B----
LR=>RL: Right rotation to   5B          ---15R---
                                      12B      --20R--
                                            17B      25B
                                              19R


                                  ------15B-----
    Left rotation to           10R           --20R--
                            5B  12B     --17B--    25B
                                              19R
    "
    (setq expected-values (5 10 12 15 17 19 20 25))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-19 (get node-17 'right))

    (assert-eq node-19 'value 19)
    (assert-eq node-19 'color 'red)
    (assert-eq node-19 'left *nil-leaf)
    (assert-eq node-19 'right *nil-leaf)
    (assert-eq node-19 'parent node-17)

    (assert-eq node-17 'parent node-20)
    (assert-eq node-17 'color 'black)
    (assert-eq node-17 'left *nil-leaf)
    (assert-eq node-17 'right node-19)

    (assert-eq node-20 'parent node-15)
    (assert-eq node-20 'color 'red)
    (assert-eq node-20 'left node-17)
    (assert-eq node-20 'right node-25)

    (assert-eq rb-tree 'root node-15)
    (assert-not (get node-15 'parent))
    (assert-eq node-15 'left node-10)
    (assert-eq node-15 'right node-20)
    (assert-eq node-15 'color 'black)

    (assert-eq node-10 'parent node-15)
    (assert-eq node-10 'color 'red)
    (assert-eq node-10 'right node-12)
    (assert-eq node-10 'left node-5)

    (assert-eq node-12 'color 'black)
    (assert-eq node-12 'parent node-10)
    (assert-eq node-12 'left *nil-leaf)
    (assert-eq node-12 'right *nil-leaf))


(de test-right-rotation-after-recolor ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    (setq node-10 root)
    # left subtree
    (setq node-m10 (new '(+RBNode) -10 'red root *nil-leaf *nil-leaf))
    (setq node-6 (new '(+RBNode) 6 'black node-m10 *nil-leaf *nil-leaf))
    (setq node-m20 (new '(+RBNode) -20 'black node-m10 *nil-leaf *nil-leaf))
    (put node-m10 'left node-m20)
    (put node-m10 'right node-6)
    (setq node-m21 (new '(+RBNode) -21 'red node-m20 *nil-leaf *nil-leaf))
    (setq node-m19 (new '(+RBNode) -19 'red node-m20 *nil-leaf *nil-leaf))
    (put node-m20 'left node-m21)
    (put node-m20 'right node-m19)
    # right subtree
    (setq node-20 (new '(+RBNode) 20 'black root *nil-leaf *nil-leaf))
    (setq node-15 (new '(+RBNode) 15 'red node-20 *nil-leaf *nil-leaf))
    (setq node-25 (new '(+RBNode) 25 'red node-20 *nil-leaf *nil-leaf))
    (put node-20 'left node-15)
    (put node-20 'right node-25)

    (put root 'left node-m10)
    (put root 'right node-20)
    (put rb-tree 'root root)
    (add> rb-tree -22)

    "

                -----10-----                                               -----10-----
                /            \                                             /            \
            -10R           20B                                         -10R           20B
            /    \          /   \                                      /   \          /    \
        -20B    6B       15R  25R     --RECOLOR TO-->              -20R    6B       15R  25R
        /   \                                                       /  \
      -21R -19R                                                   -21B -19B
        /                                                         /
Add-> -22R                                                        22R



                                    -----10B-----
                                    /             \
                                  -20R          --10R--
                                  /   \        /       \
    Right rotation to->       -21B  -19B     6B    --20B--
                                /                  /       \
                            -22R                 15R     25R

    "
    (setq expected-values (-22 -21 -20 -19 -10 6 10 15 20 25))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (assert-eq rb-tree 'root node-m10)
    (assert-eq node-m10 'parent NIL)
    (assert-eq node-m10 'left node-m20)
    (assert-eq node-m10 'right node-10)
    (assert-eq node-m10 'color 'black)

    (assert-eq node-10 'parent node-m10)
    (assert-eq node-10 'color 'red)
    (assert-eq node-10 'left node-6)
    (assert-eq node-10 'right node-20)

    (assert-eq node-m20 'parent node-m10)
    (assert-eq node-m20 'color 'red)
    (assert-eq node-m20 'left node-m21)
    (assert-eq node-m20 'right node-m19)

    (assert-eq node-m21 'color 'black)
    (assert-eq node-m21 'left  'value -22)

    (assert-eq node-6 'parent node-10)
    (assert-eq node-6 'color 'black)
    (assert-eq node-6 'left *nil-leaf)
    (assert-eq node-6 'right *nil-leaf)

    (assert-eq node-m19 'color 'black)
    (assert-eq node-m19 'parent node-m20)
    (assert-eq node-m19 'left *nil-leaf)
    (assert-eq node-m19 'right *nil-leaf))


# ***************TEST INSERTIONS***************

# ***************TEST DELETIONS***************

(de test-deletion-root ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 5 'black NIL *nil-leaf *nil-leaf))
    (setq left-child (new '(+RBNode) 3 'red root *nil-leaf *nil-leaf))
    (setq right-child (new '(+RBNode) 8 'red root *nil-leaf *nil-leaf))
    (put root 'left left-child)
    (put root 'right right-child)
    "
  REMOVE--> --5--                     --8B--
            /     \     --Result-->   /
          3R      8R                3R
    "
    (put rb-tree 'root root)
    (del> rb-tree 5)

    (setq expected-values (3 8))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-8 (get rb-tree 'root))
    (assert-eq node-8 'value 8)
    (assert-eq node-8 'color 'black)
    (assert-eq node-8 'parent NIL)
    (assert-eq node-8 'left  'value 3)
    (assert-eq node-8 'right *nil-leaf)
    (setq node-3 (get node-8 'left))
    (assert-eq node-3 'color 'red)
    (assert-eq node-3 'parent node-8)
    (assert-eq node-3 'left *nil-leaf)
    (assert-eq node-3 'right *nil-leaf))

(de test-deletion-root-2-nodes ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 5 'black NIL *nil-leaf *nil-leaf))
    (setq right-child (new '(+RBNode) 8 'red root *nil-leaf *nil-leaf))
    (put root 'right right-child)
    (put rb-tree 'root root)
    (del> rb-tree 5)
    "
            --5B-- <-- REMOVE        --8B--
                  \      Should become--^
                  8R
    "
    (setq expected-values (8))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq root (get rb-tree 'root))
    (assert-eq root 'value 8)
    (assert-eq root 'parent NIL)
    (assert-eq root 'color 'black)
    (assert-eq root 'left *nil-leaf)
    (assert-eq root 'right *nil-leaf))


(de test-delete-single-child ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 5 'black NIL *nil-leaf *nil-leaf))
    (setq left-child (new '(+RBNode) 1 'red root *nil-leaf *nil-leaf))
    (setq right-child (new '(+RBNode) 6 'red root *nil-leaf *nil-leaf))
    (put root 'left left-child)
    (put root 'right right-child)
    (put rb-tree 'root root)
    (del> rb-tree 6)
    "
        5                        5B
      / \   should become      /
    1R   6R                   1R
    "
    (setq expected-values (1 5))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (assert-eq root 'right *nil-leaf)
    (assert-eq root 'value 5)
    (assert-eq root 'color 'black)
    (assert-eq root 'parent NIL)
    (assert-eq root 'left  'value 1)
    (setq node-1 (get root 'left))
    (assert-eq node-1 'left *nil-leaf)
    (assert-eq node-1 'right *nil-leaf))


(de test-delete-single-deep-child ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 20 'black NIL *nil-leaf *nil-leaf))
    # left subtree
    (setq node-10 (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    (setq node-5 (new '(+RBNode) 5 'red node-10 *nil-leaf *nil-leaf))
    (setq node-15 (new '(+RBNode) 15 'red node-10 *nil-leaf *nil-leaf))
    (put node-10 'left node-5)
    (put node-10 'right node-15)
    # right subtree
    (setq node-38 (new '(+RBNode) 38 'red root *nil-leaf *nil-leaf))
    (setq node-28 (new '(+RBNode) 28 'black node-38 *nil-leaf *nil-leaf))
    (setq node-48 (new '(+RBNode) 48 'black node-38 *nil-leaf *nil-leaf))
    (put node-38 'left node-28)
    (put node-38 'right node-48)
    # node-28 subtree
    (setq node-23 (new '(+RBNode) 23 'red node-28 *nil-leaf *nil-leaf))
    (setq node-29 (new '(+RBNode) 29 'red node-28 *nil-leaf *nil-leaf))
    (put node-28 'left node-23)
    (put node-28 'right node-29)
    # node-48 subtree
    (setq node-41 (new '(+RBNode) 41 'red node-48 *nil-leaf *nil-leaf))
    (setq node-49 (new '(+RBNode) 49 'red node-48 *nil-leaf *nil-leaf))
    (put node-48 'left node-41)
    (put node-48 'right node-49)

    (put root 'left node-10)
    (put root 'right node-38)
    (put rb-tree 'root root)
    (del> rb-tree 49)
    "
            ------20------
            /              \
          10B           ---38R---
        /   \         /         \
      5R    15R      28B         48B
                    /  \        /   \
                  23R  29R     41R   49R    <--- REMOVE
    "
    (setq expected-values (5 10 15 20 23 28 29 38 41 48))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (assert-eq node-48 'right *nil-leaf)
    (assert-eq node-48 'color 'black)
    (assert-eq node-48 'left  'value 41)
    (assert-not (find-node> rb-tree 49)))  # assure its not in the tree


(de test-deletion-red-node-red-successor-no-children ()
    "
    This must be the easiest deletion yet!
    "
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # Left subtree
    (setq node-5 (new '(+RBNode) 5 'red root *nil-leaf *nil-leaf))
    (setq node-m5 (new '(+RBNode) -5 'black root *nil-leaf *nil-leaf))
    (setq node-7 (new '(+RBNode) 7 'black node-5 *nil-leaf *nil-leaf))
    (put node-5 'left node-m5)
    (put node-5 'right node-7)

    # right subtree
    (setq node-35 (new '(+RBNode) 35 'red root *nil-leaf *nil-leaf))
    (setq node-20 (new '(+RBNode) 20 'black node-35 *nil-leaf *nil-leaf))
    (setq node-38 (new '(+RBNode) 38 'black node-35 *nil-leaf *nil-leaf))
    (put node-35 'left node-20)
    (put node-35 'right node-38)
    (setq node-36 (new '(+RBNode) 36 'red node-38 *nil-leaf *nil-leaf))
    (put node-38 'left node-36)

    (put root 'left node-5)
    (put root 'right node-35)
    (put rb-tree 'root root)
    (del> rb-tree 35)

    "
                10B
              /     \
            5R       35R   <-- REMOVE THIS
            /  \     /   \
        -5B   7B   20B  38B   We get it's in-order successor which is 36
                        /
                      36R     36 Is red and has no children so we easily swap it's 'value with 35 and remove 36

                  10B
                /     \
  RESULT IS    5R       36R
              /  \     /   \
          -5B   7B   20B  38B
    "
    (setq expected-values (-5 5 7 10 20 36 38))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    # Careful with reference equals
    (setq node-36(get rb-tree 'root 'right))
    (assert-eq node-36 'value 36)
    (assert-eq node-36 'color 'red)
    (assert-eq node-36 'parent (get rb-tree 'root))
    (assert-eq node-36 'left 'value 20)
    (assert-eq node-36 'right 'value 38)

    (assert-eq node-20 'parent 'value 36)
    (assert-eq node-38 'parent 'value 36)
    (assert-eq node-38 'left *nil-leaf))


(de test-mirror-deletion-red-node-red-successor-no-children ()
    "
    This must be the easiest deletion yet!
    "
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # Left subtree
    (setq node-5 (new '(+RBNode) 5 'red root *nil-leaf *nil-leaf))
    (setq node-m5 (new '(+RBNode) -5 'black root *nil-leaf *nil-leaf))
    (setq node-7 (new '(+RBNode) 7 'black node-5 *nil-leaf *nil-leaf))
    (put node-5 'left node-m5)
    (put node-5 'right node-7)
    (setq node-6 (new '(+RBNode) 6 'red node-7 *nil-leaf *nil-leaf))
    (put node-7 'left node-6)

    # right subtree
    (setq node-35 (new '(+RBNode) 35 'red root *nil-leaf *nil-leaf))
    (setq node-20 (new '(+RBNode) 20 'black node-35 *nil-leaf *nil-leaf))
    (setq node-38 (new '(+RBNode) 38 'black node-35 *nil-leaf *nil-leaf))
    (put node-35 'left node-20)
    (put node-35 'right node-38)
    (setq node-36 (new '(+RBNode) 36 'red node-38 *nil-leaf *nil-leaf))
    (put node-38 'left node-36)

    (put root 'left node-5)
    (put root 'right node-35)
    (put rb-tree 'root root)
    (del> rb-tree 5)

    "
                10B
              /     \
REMOVE -->  5R       35R
            /  \     /   \
        -5B   7B   20B  38B   We get it's in-order successor which is 6
              /         /
            6R         36R      6 Is red and has no children
                                so we easily swap it's 'value with 5 and remove 6

                  10B
                /     \
  RESULT IS    6R       35R
              /  \     /   \
          -5B   7B   20B  38B
                          /
                        36R
    "
    (setq expected-values (-5 6 7 10 20 35 36 38))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-6 (get rb-tree 'root 'left))
    (assert-eq node-6 'value 6)
    (assert-eq node-6 'color 'red)
    (assert-eq node-6 'parent (get rb-tree 'root))
    (assert-eq node-6 'left 'value -5)
    (assert-eq node-6 'right 'value 7)
    (setq node-7 (get node-6 'right))
    (assert-eq node-7 'color 'black)
    (assert-eq node-7 'parent node-6)
    (assert-eq node-7 'left *nil-leaf)
    (assert-eq node-7 'right *nil-leaf))


(de test-deletion-black-node-black-successor-right-red-child ()
    " fuck it i don't even know anymore "
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # left subtree
    (setq node-5 (new '(+RBNode) 5 'black root *nil-leaf *nil-leaf))
    (setq node-m5 (new '(+RBNode) -5 'black node-5 *nil-leaf *nil-leaf))
    (setq node-7 (new '(+RBNode) 7 'black node-5 *nil-leaf *nil-leaf))
    (put node-5 'left node-m5)
    (put node-5 'right node-7)
    # right subtree
    (setq node-30 (new '(+RBNode) 30 'black root *nil-leaf *nil-leaf))
    (setq node-20 (new '(+RBNode) 20 'black node-30 *nil-leaf *nil-leaf))
    (setq node-38 (new '(+RBNode) 38 'red node-30 *nil-leaf *nil-leaf))
    (put node-30 'left node-20)
    (put node-30 'right node-38)
    # node-38 subtree
    (setq node-32 (new '(+RBNode) 32 'black node-38 *nil-leaf *nil-leaf))
    (setq node-41 (new '(+RBNode) 41 'black node-38 *nil-leaf *nil-leaf))
    (put node-38 'left node-32)
    (put node-38 'right node-41)
    (setq node-35 (new '(+RBNode) 35 'red node-32 *nil-leaf *nil-leaf))
    (put node-32 'right node-35)

    (put root 'left node-5)
    (put root 'right node-30)

    (put rb-tree 'root root)
    (del> rb-tree 30)
    "
                      ---10B---                                             ---10B---
                    /         \                                           /         \
                    5B         30B  <------- REMOVE THIS                  5B         32B  <----
                  /  \       /   \                                      /  \       /   \
                -5B  7B    20B   38R                                  -5B  7B    20B   38R
                                /   \                                                 /   \
                successor ---> 32B    41B                                       -->  35B    41B
                                  \             30B becomes 32B
                                  35R           old 32B becomes 35B
    "
    (setq expected-values (-5 5 7 10 20 32 35 38 41))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-32 (get node-30))
    (assert-eq node-32 'value 32)
    (assert-eq node-32 'parent  'value 10)
    (assert-eq node-32 'color 'black)
    (assert-eq node-32 'left node-20)
    (assert-eq node-32 'right node-38)

    (setq node-35 (get node-38 'left))
    (assert-eq node-35 'value 35)
    (assert-eq node-35 'parent  'value 38)
    (assert-eq node-35 'color 'black)
    (assert-eq node-35 'left *nil-leaf)
    (assert-eq node-35 'right *nil-leaf))


(de test-deletion-black-node-black-successor-no-child-case-4 ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # left subtree
    (setq node-m10 (new '(+RBNode) -10 'black root *nil-leaf *nil-leaf))
    # right subtree
    (setq node-30 (new '(+RBNode) 30 'red root *nil-leaf *nil-leaf))
    (setq node-20 (new '(+RBNode) 20 'black node-30 *nil-leaf *nil-leaf))
    (setq node-38 (new '(+RBNode) 38 'black node-30 *nil-leaf *nil-leaf))
    (put node-30 'left node-20)
    (put node-30 'right node-38)

    (put root 'left node-m10)
    (put root 'right node-30)
    (put rb-tree 'root root)
    (del> rb-tree 10)

    "
              ---10B---   <----- REMOVE THIS       ---20B---
              /         \                          /         \
            -10B        30R                      -10B        30R
                      /   \                                /   \
      successor --> 20B    38B                double black DB  38B
                                            Case 4 applies since the sibling is black has no red children and
                                            the parent is 'red
                                            So we simply exchange colors of the parent and the sibling


                    ---20B---
                  /         \
                -10B        30B        DONE
                                \
                              38R

    "
    (setq expected-values (-10 20 30 38))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (assert-eq rb-tree 'root  'value 20)
    (assert-eq rb-tree 'root 'color 'black)
    (setq node-30(get rb-tree 'root 'right))
    (assert-eq node-30 'parent  'value 20)
    (assert-eq node-30 'value 30)
    (assert-eq node-30 'color 'black)
    (assert-eq node-30 'left *nil-leaf)
    (assert-eq node-30 'right  'value 38)
    (setq node-38 (get node-30 'right))
    (assert-eq node-38 'value 38)
    (assert-eq node-38 'color 'red)
    (assert-eq node-38 'left *nil-leaf)
    (assert-eq node-38 'right *nil-leaf))


(de test-deletion-black-node-no-successor-case-6 ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # left subtree
    (setq node-m10 (new '(+RBNode) -10 'black root *nil-leaf *nil-leaf))
    # right subtree
    (setq node-30 (new '(+RBNode) 30 'black root *nil-leaf *nil-leaf))
    (setq node-25 (new '(+RBNode) 25 'red node-30 *nil-leaf *nil-leaf))
    (setq node-40 (new '(+RBNode) 40 'red node-30 *nil-leaf *nil-leaf))
    (put node-30 'left node-25)
    (put node-30 'right node-40)

    (put root 'left node-m10)
    (put root 'right node-30)
    (put rb-tree 'root root)
    (del> rb-tree -10)

    "
                    ---10B---
                    /         \           Case 6 applies here since
      REMOVE-->  -10B         30B         The parent's color does not matter
      Double Black           /   \        The sibling's color is 'black
                          25R    40R     The sibling's right child is 'red (in the MIRROR CASE - left child should be 'red)
    Here we do a left rotation and change the colors such that
        the sibling gets the parent's color (30 gets 10's color)
        the parent(now sibling's left) and sibling's right become 'black


              ---30B---
            /         \
          10B         40B
        /    \
      NULL    25R
    -10B
    would be here
    but we're removing it
    "
    (assert-eq rb-tree 'root 'color 'black)
    (assert-eq rb-tree 'root  'value 30)
    (setq node-10 (get rb-tree 'root 'left))
    (assert-eq node-10 'value 10)
    (assert-eq node-10 'color 'black)
    (assert-eq node-10 'parent (get rb-tree 'root))
    (assert-eq node-10 'left *nil-leaf)
    (setq node-25 (get node-10 'right))
    (assert-eq node-25 'value 25)
    (assert-eq node-25 'color 'red)
    (assert-eq node-25 'parent node-10)
    (assert-eq node-25 'left *nil-leaf)
    (assert-eq node-25 'right *nil-leaf)
    (setq node-40(get rb-tree 'root 'right))
    (assert-eq node-40 'value 40)
    (assert-eq node-40 'parent (get rb-tree 'root))
    (assert-eq node-40 'color 'black)
    (assert-eq node-40 'left *nil-leaf)
    (assert-eq node-40 'right *nil-leaf))


(de test-mirror-deletion-black-node-no-successor-case-6 ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    (setq node-12 (new '(+RBNode) 12 'black root *nil-leaf *nil-leaf))
    (setq node-5 (new '(+RBNode) 5 'black root *nil-leaf *nil-leaf))
    (setq node-1 (new '(+RBNode) 1 'red node-5 *nil-leaf *nil-leaf))
    (setq node-7 (new '(+RBNode) 7 'red node-5 *nil-leaf *nil-leaf))
    (put node-5 'left node-1)
    (put node-5 'right node-7)
    (put root 'left node-5)
    (put root 'right node-12)
    (put rb-tree 'root root)
    (del> rb-tree 12)
    "
                --10B--                                           --5B--
                /      \                                         /      \
              5B       12B  <--- REMOVE                        1B        10B
            /  \              has no successors                        /
          1R   7R                                                    7R
                        case 6 applies so we left rotate at 5b
    "
    (setq node-5 (get rb-tree 'root))
    (assert-eq node-5 'value 5)
    (assert-eq node-5 'color 'black)
    (assert-eq node-5 'parent NIL)
    (assert-eq node-5 'left  'value 1)
    (assert-eq node-5 'right  'value 10)
    (setq node-1 (get node-5 'left))
    (assert-eq node-1 'value 1)
    (assert-eq node-1 'parent node-5)
    (assert-eq node-1 'color 'black)
    (assert-eq node-1 'left *nil-leaf)
    (assert-eq node-1 'right *nil-leaf)
    (setq node-10 (get node-5 'right))
    (assert-eq node-10 'value 10)
    (assert-eq node-10 'parent node-5)
    (assert-eq node-10 'color 'black)
    (assert-eq node-10 'left  'value 7)
    (assert-eq node-10 'right *nil-leaf)
    (setq node-7 (get node-10 'left))
    (assert-eq node-7 'value 7)
    (assert-eq node-7 'parent node-10)
    (assert-eq node-7 'color 'red)
    (assert-eq node-7 'left *nil-leaf)
    (assert-eq node-7 'right *nil-leaf))


(de test-deletion-black-node-no-successor-case-3-then-1 ()
    "
    Delete a node such that case 3 is called which pushes
    the double black node upwards into a case 1 problem
    "
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # left subtree
    (setq node-m10 (new '(+RBNode) -10 'black root *nil-leaf *nil-leaf))
    # right subtree
    (setq node-30 (new '(+RBNode) 30 'black root *nil-leaf *nil-leaf))

    (put root 'left node-m10)
    (put root 'right node-30)
    (put rb-tree 'root root)
    (del> rb-tree -10)

    "                                             Double
                                                    Black
                ---10B---                         --|10B|--
                /         \     ---->             /         \
REMOVE-->   -10B         30B                  REMOVED      30R  <--- COLO'red 'red

        We color the sibling red and try to resolve the double black problem in the root.
        We go through the cases 1-6 and find that case 1 is what we're looking for
        Case 1 simply recolors the root to black and we are done
            ---10B---
                      \
                      30R
    "
    (setq node-10 (get rb-tree 'root))
    (assert-eq node-10 'color 'black)
    (assert-eq node-10 'parent NIL)
    (assert-eq node-10 'left *nil-leaf)
    (assert-eq node-10 'right  'value 30)
    (setq node-30 (get node-10 'right))
    (assert-eq node-30 'value 30)
    (assert-eq node-30 'color 'red)
    (assert-eq node-30 'parent node-10)
    (assert-eq node-30 'left *nil-leaf)
    (assert-eq node-30 'right *nil-leaf))


(de test-deletion-black-node-no-successor-case-3-then-5-then-6 ()
    "
    We're going to delete a black node which will cause a case 3 deletion
    which in turn would pass the double black node up into a case 5 which
    will restructure the tree in such a way that a case 6 rotation becomes possible
    "
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # left subtree
    (setq node-m30 (new '(+RBNode) -30 'black root *nil-leaf *nil-leaf))
    (setq node-m40 (new '(+RBNode) -40 'black node-m30 *nil-leaf *nil-leaf))
    (setq node-m20 (new '(+RBNode) -20 'black node-m30 *nil-leaf *nil-leaf))
    (put node-m30 'left node-m40)
    (put node-m30 'right node-m20)
    # right subtree
    (setq node-50 (new '(+RBNode) 50 'black root *nil-leaf *nil-leaf))
    (setq node-30 (new '(+RBNode) 30 'red node-50 *nil-leaf *nil-leaf))
    (setq node-70 (new '(+RBNode) 70 'black node-50 *nil-leaf *nil-leaf))
    (put node-50 'left node-30)
    (put node-50 'right node-70)
    (setq node-15 (new '(+RBNode) 15 'black node-30 *nil-leaf *nil-leaf))
    (setq node-40 (new '(+RBNode) 40 'black node-30 *nil-leaf *nil-leaf))
    (put node-30 'left node-15)
    (put node-30 'right node-40)

    (put root 'left node-m30)
    (put root 'right node-50)
    (put rb-tree 'root root)
    (del> rb-tree -40)
    "
    In mirror cases this'd be mirrored
    |node| - double black node
                ---10B---                                 ---10B---
                /         \               DOUBLE          /         \
            -30B         50B             'black-->   |-30B|        50B
            /    \       /   \                        /    \       /   \
REMOVE-->|-40B|  -20B   30R   70B     --CASE 3--> REMOVED  -20R   30R   70B
                      /   \                                     /   \
                    15B   40B                                 15B   40B



  --CASE 5-->                              ---10B---
  parent is black        still double     /         \
  sibling is black         black -->  |-30B|        30B
  sibling 'left is red                     \        /   \
  sibling 'right is black                  -20R   15B   50R
  left rotation on sibling 'left                       /   \
                                                    40B   70B


  What we've done here is we've simply
  restructured the tree to be eligible
  for a case 6 solution :)                              ---30B---
  --CASE 6-->                                          /         \
  parent color DOESNT MATTER                         10B         50B
  sibling is black                                  /   \       /   \
  sibling 'left DOESNT MATTER                     -30B   15B   40B   70B
  sibling 'right is 'red                              \
  left rotation on sibling (30B on the above)       -20R
  where the sibling gets the color of the parent
      and the parent is now to the left of sibling and
      repainted 'black
      the sibling's right also gets repainted black
    "
    (setq node-30 (get rb-tree 'root))
    (assert-eq node-30 'value 30)
    (assert-eq node-30 'parent NIL)
    (assert-eq node-30 'color 'black)
    (assert-eq node-30 'left  'value 10)
    (assert-eq node-30 'right  'value 50)

    # test left subtree
    (setq node-10 (get node-30 'left))
    (assert-eq node-10 'value 10)
    (assert-eq node-10 'color 'black)
    (assert-eq node-10 'parent node-30)
    (assert-eq node-10 'left  'value -30)
    (assert-eq node-10 'right  'value 15)
    (setq node-m30 (get node-10 'left))
    (assert-eq node-m30 'value -30)
    (assert-eq node-m30 'color 'black)
    (assert-eq node-m30 'parent node-10)
    (assert-eq node-m30 'left *nil-leaf)
    (assert-eq node-m30 'right  'value -20)
    (setq node-15 (get node-10 'right))
    (assert-eq node-15 'value 15)
    (assert-eq node-15 'color 'black)
    (assert-eq node-15 'parent node-10)
    (assert-eq node-15 'left *nil-leaf)
    (assert-eq node-15 'right *nil-leaf)
    (setq node-m20 (get node-m30 'right))
    (assert-eq node-m20 'value -20)
    (assert-eq node-m20 'color 'red)
    (assert-eq node-m20 'parent node-m30)
    (assert-eq node-m20 'left *nil-leaf)
    (assert-eq node-m20 'right *nil-leaf)

    # test right subtree
    (setq node-50 (get node-30 'right))
    (assert-eq node-50 'value 50)
    (assert-eq node-50 'color 'black)
    (assert-eq node-50 'parent node-30)
    (assert-eq node-50 'left  'value 40)
    (assert-eq node-50 'right  'value 70)
    (setq node-40 (get node-50 'left))
    (assert-eq node-40 'value 40)
    (assert-eq node-40 'parent node-50)
    (assert-eq node-40 'color 'black)
    (assert-eq node-40 'left *nil-leaf)
    (assert-eq node-40 'right *nil-leaf)
    (setq node-70 (get node-50 'right))
    (assert-eq node-70 'value 70)
    (assert-eq node-70 'color 'black)
    (assert-eq node-70 'parent node-50)
    (assert-eq node-70 'left *nil-leaf)
    (assert-eq node-70 'right *nil-leaf))


(de test-mirror-deletion-black-node-no-successor-case-3-then-5-then-6 ()
    "
    We're going to delete a black node which will cause a case 3 deletion
    which in turn would pass the double black node up into a case 5 which
    will restructure the tree in such a way that a case 6 rotation becomes possible
    "
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 50 'black NIL *nil-leaf *nil-leaf))
    # left subtree
    (setq node-30 (new '(+RBNode) 30 'black root *nil-leaf *nil-leaf))
    (setq node-20 (new '(+RBNode) 20 'black node-30 *nil-leaf *nil-leaf))
    (setq node-35 (new '(+RBNode) 35 'red node-30 *nil-leaf *nil-leaf))
    (put node-30 'left node-20)
    (put node-30 'right node-35)
    (setq node-34 (new '(+RBNode) 34 'black node-35 *nil-leaf *nil-leaf))
    (setq node-37 (new '(+RBNode) 37 'black node-35 *nil-leaf *nil-leaf))
    (put node-35 'left node-34)
    (put node-35 'right node-37)
    # right subtree
    (setq node-80 (new '(+RBNode) 80 'black root *nil-leaf *nil-leaf))
    (setq node-70 (new '(+RBNode) 70 'black node-80 *nil-leaf *nil-leaf))
    (setq node-90 (new '(+RBNode) 90 'black node-80 *nil-leaf *nil-leaf))
    (put node-80 'left node-70)
    (put node-80 'right node-90)

    (put root 'left node-30)
    (put root 'right node-80)
    (put rb-tree 'root root)
    (del> rb-tree 90)

    "
                        Parent is black
            ---50B---    Sibling is black                       ---50B---
          /         \   Sibling's children are black          /         \
        30B          80B        CASE 3                       30B        |80B|
      /   \        /   \        ==>                        /  \        /   \
    20B   35R    70B    90B <---REMOVE                   20B  35R     70R   X
          /  \                                               /   \
        34B   37B                                          34B   37B



Case 5
Parent is black                                 --50B--
Sibling is black             CASE 5            /       \
Closer sibling child is 'red  =====>          35B      |80B|
    (right in this case                    /   \      /
      left in mirror)                     30R   37B    70R
Outer sibling child is blck             /  \
                                      20B  34B


We have now successfully position our tree
for a CASE 6 scenario
The parent's color does not matter                           --35B--
The sibling is black                                        /       \
The closer sibling child             CASE 6               30R       50R
    's color does not matter         ====>               /   \     /   \
The outer sibling child                                20B   34B 37B    80B
    (left in this case                                                 /
      right in mirror)                                                  70R
      is 'red!
    "
    (setq expected-values (20 30 34 35 37 50 70 80))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-35 (get rb-tree 'root))
    (assert-eq node-35 'value 35)
    (assert-eq node-35 'parent NIL)
    (assert-eq node-35 'color 'black)
    (assert-eq node-35 'left  'value 30)
    (assert-eq node-35 'right  'value 50)
    # right subtree
    (setq node-50 (get node-35 'right))
    (assert-eq node-50 'value 50)
    (assert-eq node-50 'color 'black)
    (assert-eq node-50 'parent node-35)
    (assert-eq node-50 'left  'value 37)
    (assert-eq node-50 'right  'value 80)
    (setq node-37 (get node-50 'left))
    (assert-eq node-37 'value 37)
    (assert-eq node-37 'color 'black)
    (assert-eq node-37 'parent node-50)
    (assert-eq node-37 'left *nil-leaf)
    (assert-eq node-37 'right *nil-leaf)
    (setq node-80 (get node-50 'right))
    (assert-eq node-80 'value 80)
    (assert-eq node-80 'color 'black)
    (assert-eq node-80 'parent node-50)
    (assert-eq node-80 'left  'value 70)
    (assert-eq node-80 'right *nil-leaf)
    (setq node-70 (get node-80 'left))
    (assert-eq node-70 'value 70)
    (assert-eq node-70 'color 'red)
    (assert-eq node-70 'parent node-80)
    (assert-eq node-70 'left *nil-leaf)
    (assert-eq node-70 'right *nil-leaf)
    # left subtree
    (setq node-30 (get node-35 'left))
    (assert-eq node-30 'value 30)
    (assert-eq node-30 'parent node-35)
    (assert-eq node-30 'color 'black)
    (assert-eq node-30 'left  'value 20)
    (assert-eq node-30 'right  'value 34)
    (setq node-20 (get node-30 'left))
    (assert-eq node-20 'value 20)
    (assert-eq node-20 'color 'black)
    (assert-eq node-20 'parent node-30)
    (assert-eq node-20 'left *nil-leaf)
    (assert-eq node-20 'right *nil-leaf)
    (setq node-34 (get node-30 'right))
    (assert-eq node-34 'value 34)
    (assert-eq node-34 'color 'black)
    (assert-eq node-34 'parent node-30)
    (assert-eq node-34 'left *nil-leaf)
    (assert-eq node-34 'right *nil-leaf))


(de test-deletion-black-node-successor-case-2-then-4 ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 10 'black NIL *nil-leaf *nil-leaf))
    # left subtree
    (setq node-m10 (new '(+RBNode) -10 'black root *nil-leaf *nil-leaf))
    (setq node-m20 (new '(+RBNode) -20 'black node-m10 *nil-leaf *nil-leaf))
    (setq node-m5 (new '(+RBNode) -5 'black node-m10 *nil-leaf *nil-leaf))
    (put node-m10 'left node-m20)
    (put node-m10 'right node-m5)
    # right subtree
    (setq node-40 (new '(+RBNode) 40 'black root *nil-leaf *nil-leaf))
    (setq node-20 (new '(+RBNode) 20 'black node-40 *nil-leaf *nil-leaf))
    (setq node-60 (new '(+RBNode) 60 'red node-40 *nil-leaf *nil-leaf))
    (put node-40 'left node-20)
    (put node-40 'right node-60)
    (setq node-50 (new '(+RBNode) 50 'black node-60 *nil-leaf *nil-leaf))
    (setq node-80 (new '(+RBNode) 80 'black node-60 *nil-leaf *nil-leaf))
    (put node-60 'left node-50)
    (put node-60 'right node-80)

    (put root 'left node-m10)
    (put root 'right node-40)
    (put rb-tree 'root root)
    (del> rb-tree 10)
    "

REMOVE--->    ---10B---           parent is black             ---20B---
            /         \          sibling is red            /         \
        -10B         40B        s.children aren't red    -10B         60B
        /    \       /   \       --CASE 2 ROTATE-->      /    \       /   \
    -20B    -5B |20B|   60R       LEFT ROTATE         -20B  -5B    40R   80B
SUCCESSOR IS 20----^   /   \      SIBLING 60                      /   \
                      50B    80B                       REMOVE--> 20    50B


CASE 4                                         ---20B---
20'S parent is 'red                           /         \
sibling is 'black                            -10B         60B
sibling's children are NOT 'red             /    \       /   \
    so we push parent's                  -20B  -5B    40B   80B
    redness down to the sibling                      /   \
    and remove node                      REMOVED--> X    50R
    "
    (setq expected-values (-20 -10 -5 20 40 50 60 80))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-20 (get rb-tree 'root))
    (assert-eq node-20 'value 20)
    (assert-eq node-20 'parent NIL)
    (assert-eq node-20 'color 'black)
    (assert-eq node-20 'left  'value -10)
    (assert-eq node-20 'right  'value 60)
    # test left subtree
    (setq node-m10 (get node-20 'left))
    (assert-eq node-m10 'value -10)
    (assert-eq node-m10 'color 'black)
    (assert-eq node-m10 'parent node-20)
    (assert-eq node-m10 'left  'value -20)
    (assert-eq node-m10 'right  'value -5)
    (setq node-m20 (get node-m10 'left))
    (assert-eq node-m20 'value -20)
    (assert-eq node-m20 'color 'black)
    (assert-eq node-m20 'parent node-m10)
    (assert-eq node-m20 'left *nil-leaf)
    (assert-eq node-m20 'right *nil-leaf)
    (setq node-m5 (get node-m10 'right))
    (assert-eq node-m5 'value -5)
    (assert-eq node-m5 'color 'black)
    (assert-eq node-m5 'parent node-m10)
    (assert-eq node-m5 'left *nil-leaf)
    (assert-eq node-m5 'right *nil-leaf)
    # test right subtree
    (setq node-60 (get node-20 'right))
    (assert-eq node-60 'value 60)
    (assert-eq node-60 'color 'black)
    (assert-eq node-60 'parent node-20)
    (assert-eq node-60 'left  'value 40)
    (assert-eq node-60 'right  'value 80)
    (setq node-80 (get node-60 'right))
    (assert-eq node-80 'value 80)
    (assert-eq node-80 'color 'black)
    (assert-eq node-80 'parent node-60)
    (assert-eq node-80 'left *nil-leaf)
    (assert-eq node-80 'right *nil-leaf)
    (setq node-40 (get node-60 'left))
    (assert-eq node-40 'value 40)
    (assert-eq node-40 'color 'black)
    (assert-eq node-40 'parent node-60)
    (assert-eq node-40 'left *nil-leaf)
    (assert-eq node-40 'right  'value 50)
    (setq node-50 (get node-40 'right))
    (assert-eq node-50 'value 50)
    (assert-eq node-50 'color 'red)
    (assert-eq node-50 'parent node-40)
    (assert-eq node-50 'left *nil-leaf)
    (assert-eq node-50 'right *nil-leaf))


(de test-mirror-deletion-black-node-successor-case-2-then-4 ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 20 'black NIL *nil-leaf *nil-leaf))
    # left subtree
    (setq node-10 (new '(+RBNode) 10 'black root *nil-leaf *nil-leaf))
    (setq node-8 (new '(+RBNode) 8 'red node-10 *nil-leaf *nil-leaf))
    (setq node-15 (new '(+RBNode) 15 'black node-10 *nil-leaf *nil-leaf))
    (put node-10 'left node-8)
    (put node-10 'right node-15)
    (setq node-6 (new '(+RBNode) 6 'black node-8 *nil-leaf *nil-leaf))
    (setq node-9 (new '(+RBNode) 9 'black node-8 *nil-leaf *nil-leaf))
    (put node-8 'left node-6)
    (put node-8 'right node-9)
    # right subtree
    (setq node-30 (new '(+RBNode) 30 'black root *nil-leaf *nil-leaf))
    (setq node-25 (new '(+RBNode) 25 'black node-30 *nil-leaf *nil-leaf))
    (setq node-35 (new '(+RBNode) 35 'black node-30 *nil-leaf *nil-leaf))
    (put node-30 'left node-25)
    (put node-30 'right node-35)

    (put root 'left node-10)
    (put root 'right node-30)
    (put rb-tree 'root root)
    (del> rb-tree 15)

    "

            ---20B---        Parent is black               ---20B---
            /         \       Sibling is red               /         \
        10B          30B     s.children are black        8B        30B
        /   \        /   \    ======>                    /  \       /   \
      8R    15B    25B   35B   Case 2                  6B   10R   25B   35B
    /  \    ^----Remove    left rotate                    /   \
    6B  9B                     on 10                      9B   |15B|



    Parent is red                                  ---20B---
    Sibling is black      CASE 4                  /         \
    s.children are black   ===>                  8B        30B
    switch the colors of the parent            /  \       /   \
    and the sibling                          6B   10B   25B   35B
                                                  /   \
                                                9R     X
    "
    (setq node-20 (get rb-tree 'root))
    (assert-eq node-20 'value 20)
    (assert-eq node-20 'color 'black)
    (assert-eq node-20 'parent NIL)
    (assert-eq node-20 'left  'value 8)
    (assert-eq node-20 'right  'value 30)
    # right subtree
    (setq node-30 (get node-20 'right))
    (assert-eq node-30 'value 30)
    (assert-eq node-30 'color 'black)
    (assert-eq node-30 'parent node-20)
    (assert-eq node-30 'left  'value 25)
    (assert-eq node-30 'right  'value 35)
    (setq node-25 (get node-30 'left))
    (assert-eq node-25 'value 25)
    (assert-eq node-25 'color 'black)
    (assert-eq node-25 'parent node-30)
    (assert-eq node-25 'left *nil-leaf)
    (assert-eq node-25 'right *nil-leaf)
    (setq node-35 (get node-30 'right))
    (assert-eq node-35 'value 35)
    (assert-eq node-35 'color 'black)
    (assert-eq node-35 'parent node-30)
    (assert-eq node-35 'left *nil-leaf)
    (assert-eq node-35 'right *nil-leaf)
    # left subtree
    (setq node-8 (get node-20 'left))
    (assert-eq node-8 'value 8)
    (assert-eq node-8 'parent node-20)
    (assert-eq node-8 'color 'black)
    (assert-eq node-8 'left  'value 6)
    (assert-eq node-8 'right  'value 10)
    (setq node-6 (get node-8 'left))
    (assert-eq node-6 'value 6)
    (assert-eq node-6 'color 'black)
    (assert-eq node-6 'parent node-8)
    (assert-eq node-6 'left *nil-leaf)
    (assert-eq node-6 'right *nil-leaf)
    (setq node-10 (get node-8 'right))
    (assert-eq node-10 'value 10)
    (assert-eq node-10 'color 'black)
    (assert-eq node-10 'parent node-8)
    (assert-eq node-10 'left node-9)
    (assert-eq node-10 'right *nil-leaf)
    (setq node-9 (get node-10 'left))
    (assert-eq node-9 'value 9)
    (assert-eq node-9 'color 'red)
    (assert-eq node-9 'parent node-10)
    (assert-eq node-9 'left *nil-leaf)
    (assert-eq node-9 'right *nil-leaf))


(de test-delete-tree-one-by-one ()
    (setq rb-tree (new '(+Tree)))
    (setq root (new '(+RBNode) 20 'black NIL *nil-leaf *nil-leaf))
    # left subtree
    (setq node-10 (new '(+RBNode) 10 'black root *nil-leaf *nil-leaf))
    (setq node-5 (new '(+RBNode) 5 'red node-10 *nil-leaf *nil-leaf))
    (setq node-15 (new '(+RBNode) 15 'red node-10 *nil-leaf *nil-leaf))
    (put node-10 'left node-5)
    (put node-10 'right node-15)
    # right subtree
    (setq node-38 (new '(+RBNode) 38 'red root *nil-leaf *nil-leaf))
    (setq node-28 (new '(+RBNode) 28 'black node-38 *nil-leaf *nil-leaf))
    (setq node-48 (new '(+RBNode) 48 'black node-38 *nil-leaf *nil-leaf))
    (put node-38 'left node-28)
    (put node-38 'right node-48)
    # node-28 subtree
    (setq node-23 (new '(+RBNode) 23 'red node-28 *nil-leaf *nil-leaf))
    (setq node-29 (new '(+RBNode) 29 'red node-28 *nil-leaf *nil-leaf))
    (put node-28 'left node-23)
    (put node-28 'right node-29)
    # node-48 subtree
    (setq node-41 (new '(+RBNode) 41 'red node-48 *nil-leaf *nil-leaf))
    (setq node-49 (new '(+RBNode) 49 'red node-48 *nil-leaf *nil-leaf))
    (put node-48 'left node-41)
    (put node-48 'right node-49)

    (put root 'left node-10)
    (put root 'right node-38)
    "
                    ------20------
                    /              \
                  10B           ---38R---
                /   \         /         \
              5R    15R      28B         48B
                            /  \        /   \
                          23R  29R     41R   49R
    "
    (put rb-tree 'root root)
    (del> rb-tree 49)
    (del> rb-tree 38)
    (del> rb-tree 28)
    (del> rb-tree 10)
    (del> rb-tree 5)
    (del> rb-tree 15)
    (del> rb-tree 48)

    "
        We're left with
                        --23B--
                        /       \
                      20B       41B
                              /
                              29R
    "

    (setq node-23 (get rb-tree 'root))
    (assert-eq node-23 'value 23)
    (assert-eq node-23 'color 'black)
    (assert-eq node-23 'parent NIL)
    (assert-eq node-23 'left 'value 20)
    (assert-eq node-23 'right 'value 41)
    (setq node-20 (get node-23 'left))
    (assert-eq node-20 'color 'black)
    (assert-eq node-20 'parent node-23)
    (assert-eq node-20 'left *nil-leaf)
    (assert-eq node-20 'right *nil-leaf)
    (setq node-41 (get node-23 'right))
    (assert-eq node-41 'color 'black)
    (assert-eq node-41 'parent node-23)
    (assert-eq node-41 'value 41)
    (assert-eq node-41 'left 'value 29)
    (assert-eq node-41 'right *nil-leaf)
    (setq node-29 (get node-41 'left))
    (assert-eq node-29 'value 29)
    (assert-eq node-29 'color 'red)
    (assert-eq node-29 'left *nil-leaf)
    (assert-eq node-29 'right *nil-leaf)
    (del> rb-tree 20)
    "
        -29B-
        /     \
      23B    41B
    "
    (setq node-29 (get rb-tree 'root))
    (assert-eq node-29 'value 29)
    (assert-eq node-29 'color 'black)
    (assert-eq node-29 'parent NIL)
    (assert-eq node-29 'left  'value 23)
    (assert-eq node-29 'right  'value 41)
    (setq node-23 (get node-29 'left))
    (assert-eq node-23 'parent node-29)
    (assert-eq node-23 'color 'black)
    (assert-eq node-23 'left *nil-leaf)
    (assert-eq node-23 'right *nil-leaf)
    (setq node-41 (get node-29 'right))
    (assert-eq node-41 'parent node-29)
    (assert-eq node-41 'color 'black)
    (assert-eq node-41 'left *nil-leaf)
    (assert-eq node-41 'right *nil-leaf)
    (del> rb-tree 29)
    "
        41B
        /
      23R
    "
    (setq node-41 (get rb-tree 'root))
    (assert-eq node-41 'value 41)
    (assert-eq node-41 'color 'black)
    (assert-eq node-41 'parent NIL)
    (assert-eq node-41 'right *nil-leaf)
    (setq node-23 (get node-41 'left))
    (assert-eq node-23 'value 23)
    (assert-eq node-23 'color 'red)
    (assert-eq node-23 'parent node-41)
    (assert-eq node-23 'left *nil-leaf)
    (assert-eq node-23 'right *nil-leaf)
    (del> rb-tree 41)
    "
        23B
    "
    (setq node-23 (get rb-tree 'root))
    (assert-eq node-23 'value 23)
    (assert-eq node-23 'color 'black)
    (assert-eq node-23 'parent NIL)
    (assert-eq node-23 'left *nil-leaf)
    (assert-eq node-23 'right *nil-leaf)
    (del> rb-tree 23)
    (assert-eq rb-tree 'root NIL))


# ***************TEST DELETIONS***************

(de test-add-delete-random-order ()
    "
    What I add here I'll also add at a site for red black tree visualization
    https://www.cs.usfca.edu/~galles/visualization/RedBlack.html
    and then see if they're the same
    "
    (setq rb-tree (new '(+Tree)))
    (add> rb-tree 90)
    (add> rb-tree 70)
    (add> rb-tree 43)
    (del> rb-tree 70)
    (add> rb-tree 24)
    (add> rb-tree 14)
    (add> rb-tree 93)
    (add> rb-tree 47)
    (del> rb-tree 47)
    (del> rb-tree 90)
    (add> rb-tree 57)
    (add> rb-tree 1)
    (add> rb-tree 60)
    (add> rb-tree 47)
    (del> rb-tree 47)
    (del> rb-tree 1)
    (del> rb-tree 43)
    (add> rb-tree 49)
    "
    well the results aren't the same but I'll assume that the algorithms are different
    Nevertheless what we're left with is a perfectly valid RedBlack Tree and I'd argue even betterly
    balanced than the one from the visualization

                                VISUALIZATION TREE
                                    ----24B----
                                  /           \
                                14B           60R
                                              /   \
                                            57B    93B
                                          /
                                        49R

                                    OUR TREE
                                    ------57B------
                                  /               \
                              --24B--           --60B--
                              /       \                 \
                            14R       49R               93R
    "
    (setq expected-values (14 24 49 57 60 93))
    (setq values (list> rb-tree))
    (assert-eq-list values expected-values)

    (setq node-57 (get rb-tree 'root))
    (assert-eq node-57 'value 57)
    (assert-eq node-57 'parent NIL)
    (assert-eq node-57 'color 'black)
    (assert-eq node-57 'left  'value 24)
    (assert-eq node-57 'right  'value 60)
    # right subtree
    (setq node-60 (get node-57 'right))
    (assert-eq node-60 'value 60)
    (assert-eq node-60 'color 'black)
    (assert-eq node-60 'parent node-57)
    (assert-eq node-60 'right  'value 93)
    (assert-eq node-60 'left *nil-leaf)
    (setq node-93 (get node-60 'right))
    (assert-eq node-93 'value 93)
    (assert-eq node-93 'color 'red)
    (assert-eq node-93 'parent node-60)
    (assert-eq node-93 'left *nil-leaf)
    (assert-eq node-93 'right *nil-leaf)
    # left subtree
    (setq node-24 (get node-57 'left))
    (assert-eq node-24 'value 24)
    (assert-eq node-24 'parent node-57)
    (assert-eq node-24 'color 'black)
    (assert-eq node-24 'left  'value 14)
    (assert-eq node-24 'right  'value 49)
    (setq node-14 (get node-24 'left))
    (assert-eq node-14 'value 14)
    (assert-eq node-14 'parent node-24)
    (assert-eq node-14 'color 'red)
    (assert-eq node-14 'left *nil-leaf)
    (assert-eq node-14 'right *nil-leaf)
    (setq node-49 (get node-24 'right))
    (assert-eq node-49 'value 49)
    (assert-eq node-49 'parent node-24)
    (assert-eq node-49 'color 'red)
    (assert-eq node-49 'left *nil-leaf)
    (assert-eq node-49 'right *nil-leaf))


(de test-add-0-to-100-delete-100-to-0 ()
  (setq rb-tree (new '(+Tree)))
  (for (i 0 (< i 100) (inc i))
      (add> rb-tree i)
      (assert-eq rb-tree 'cnt (inc i)))
  (setq expected-values
    (make (for (i 0 (< i 100) (inc i)) (link i))))
  (setq values (list> rb-tree))
  (assert-eq-list values expected-values)
  (for (i 99 (> i -1) (dec i))
      (assert-T (in> rb-tree i))
      (del> rb-tree i)
      (assert-not (in> rb-tree i))
      (assert-eq rb-tree 'cnt i))
  (assert-not (get rb-tree 'root)))

(de test-add-delete-0-to-100-delete-0-to-100 ()
  (setq rb-tree (new '(+Tree)))
  (for (i 0 (< i 100) (inc i))
      (add> rb-tree i)
      (assert-eq rb-tree 'cnt (inc i)))
  (setq expected-values
    (make (for (i 0 (< i 100) (inc i)) (link i))))
  (setq values (list> rb-tree))
  (assert-eq-list values expected-values)
  (for (i 0 (< i 100) (inc i))
      (assert-T (in> rb-tree i))
      (del> rb-tree i)
      (assert-not (in> rb-tree i))
      (assert-eq rb-tree 'cnt (- 99 i)))
  (assert-not (get rb-tree 'root)))

# ***************TEST DELETIONS***************

# ***************MISC TESTS***************

(de test-ceil ()
  # add all the numbers 0-99 step 2
  # i.e 0 2 4
  (setq rb-tree (new '(+Tree)))
  (for (i 0 (< i 100) (+ i 2))
    (add> rb-tree i))
  # then search for the ceilings knowing theyre 1 up
  (for (i 1 (< i 99) (+ i 2))
    (assert-eq-num (ceil> rb-tree i) (inc i))))

(de test-ceil-same-value ()
  (setq rb-tree (new '(+Tree)))

  (add> rb-tree 10)
  (add> rb-tree 15)
  (add> rb-tree 20)
  (add> rb-tree 17)

  (for (i 0 (< i 11) (inc i))
      (assert-eq-num (ceil> rb-tree i) 10))
  (for (i 11 (< i 16) (inc i))
      (assert-eq-num (ceil> rb-tree i) 15))
  (for (i 16 (< i 18) (inc i))
      (assert-eq-num (ceil> rb-tree i) 17))
  (for (i 18 (< i 21) (inc i))
      (assert-eq-num (ceil> rb-tree i) 20)))

(de test-floor ()
  # add all the numbers 0-99 step 2
  # i.e 0 2 4
  (setq rb-tree (new '(+Tree)))
  (for (i 0 (< i 100) (+ i 2))
      (add> rb-tree i))
  # then search for the ceilings knowing theyre 1 up
  (for (i 1 (< i 99) (+ i 2))
      (assert-eq-num (floor> rb-tree i) (- i 1))))

(de test-floor-same ()
  (setq rb-tree (new '(+Tree)))

  (add> rb-tree 10)
  (add> rb-tree 15)
  (add> rb-tree 20)
  (add> rb-tree 17)

  (for (i 11 (< i 15) (inc i))
      (assert-eq-num (floor> rb-tree i) 10))
  (for (i 15 (< i 17) (inc i))
      (assert-eq-num (floor> rb-tree i) 15))
  (for (i 17 (< i 20) (inc i))
      (assert-eq-num (floor> rb-tree i) 17))
  (for (i 20 (< i 50) (inc i))
      (assert-eq-num (floor> rb-tree i) 20)))


# These tests take the bulk of the time for testing.

(de test-addition-performance ()
  "
  Add 25000 elements to the tree
  "
  (let (elements
          (make
            (do 25000
              (link (rand 1 1000000))))
        tree (new '(+Tree))
        start-time (usec))
    (for el elements
      (add> tree el))
    (prinl (/ (- (usec) start-time) 1000) " ms")))
  # (assert-T (< time-taken.seconds 1))


(de test-deletion-performance ()
  "
  Delete 25000 elements from the tree
  "
  # choose 25000 random num between 1 and 20000
  (let (elements
         (make
           (do 25000
             (link (rand 1 200000))))
        tree (new '(+Tree)))
    (for el elements
        (add> tree el))
    (let start-time (usec)
      (for el elements
          (del> tree el))
      (prinl (/ (- (usec) start-time) 1000) " ms"))))
  # (assert-T (< time-taken.seconds 1))


(de test-deletion-and-addition-performance ()
  (let (elements
          (make
            (do 25000
              (link (rand 1 1000000))))
        first-part (nth elements 12500)
        second-part (nth elements 12500)
        deletion-part (head (- 16666 8333) (nth first-part 8333)) # 6+4
        tree (new '(+Tree))
        start-time (usec))
    # fill up the tree 1/2
    (for el first-part
        (add> tree el))
    # delete 1/2 of the tree
    (for del-el deletion-part
        (del> tree del-el))
    (for el second-part
        (add> tree el))
    (prinl (/ (- (usec) start-time) 1000) " ms")))
  # (assert-T (< time-taken.seconds 1))
