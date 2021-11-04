#{

  Based on:
  https://github.com/stanislavkozlovski/Red-Black-Tree

  A non-intrusive non-left-leaning Red-Black Tree implementation,
  supporting addition and deletion.

  Node colors: 'black 'red 'white

}#

(symbols 'rbtree 'pico) # (local) (value color parent left right)

(class +RBNode)
(dm T (Value Color Parent Left Right Any)
  (=: value  Value)
  (=: color  Color)
  (=: parent Parent)
  (=: left   Left)
  (=: right  Right)
  (=: any Any))

(dm text> ()
  (text
    "@1 @2"
    (: color) (sym (: value))))

(dm eq> (Other)
  (if (= 'white (: color) (get Other 'color))
      T
      (and
        (= (: value) (get Other 'value))
        (= (: color) (get Other 'color))
        (if (or
              (not (: parent))
              (not (get Other 'parent)))
            (and
              (not (: parent))
              (not (get Other 'parent)))
            (and
              (= (get (: parent) 'value) (get Other 'parent 'value))
              (= (get (: parent) 'color) (get Other 'parent 'color)))))))

(dm children?> ()
  (gt0 (cnt-children> This)))

(dm cnt-children> ()
  # Returns the number of NOT NIL children the node has
  (if (= (: color) 'white)
      0
      (+
        (if (= (get (: left) 'color) 'white) 0 1)
        (if (= (get (: right) 'color) 'white) 0 1))))


# every node has null nodes as children initially,
# create one such object for easy management
(def '*nil-leaf (new '(+RBNode) NIL 'white))

# Used for deletion and uses the sib's relationship with his parent
# as a guide to the rotation
(def '*rots
  (list
    (cons 'left  'rot-r>)
    (cons 'right 'rot-l>)))

(class +Tree)
(dm T ()
  (=: cnt 0)
  (=: root NIL))

(dm list> ()
  (make
    (let N (: root)
      (recur (N)
        (when (get N 'left) (recurse @))
        (when (get N 'value) (link @))
        (when (get N 'right) (recurse @))))))

(dm add> (Value Any)

  (if (: root)

      (let ((Parent . Node-Dir) (find-parent> This Value))
        (when Node-Dir
          (prog1
            (new '(+RBNode)
              Value
              'red
              Parent
              *nil-leaf
              *nil-leaf
              Any)
            (put Parent Node-Dir @)
            (bal> This @)
            (inc (:: cnt)))))

      (prog1
        (=: root
          (new '(+RBNode)
            Value
            'black
            NIL
            *nil-leaf
            *nil-leaf
            Any))
        (inc (:: cnt)))))


(dm del> (Value)
  # Try to get a node with 0 or 1 children.
  # Either the node we're given has 0 or 1 children or we get its successor.
  (let? Node-Remove (find-node> This Value)
    (when (= 2 (cnt-children> Node-Remove))
      (let Successor (-find-in-order-successor> This Node-Remove)
        (put Node-Remove 'value (get Successor 'value))
        (setq Node-Remove Successor)))
    (del-2> This Node-Remove)
    (dec (:: cnt))))

(dm in> (Value)
  # Returns a boolean indicating if the given value is present in the tree
  (find-node> This Value))

(dm ceil> (Value)
  # Given a value, return the closest value that is equal or bigger than it,
  # returning NIL when no such exists
  (when (: root)
    (let (Node (: root)
          Val-Last
            (when (> (get (: root) 'value) Value)
              (get (: root) 'value)))
      (recur (Node)
        (cond
          ((eq> Node *nil-leaf))
          ((= (get Node 'value) Value)
            (setq Val-Last (get Node 'value)))
          ((< (get Node 'value) Value)
            (recurse (get Node 'right)))
          (T
            (setq Val-Last (get Node 'value))
            (recurse (get Node 'left)))))
      Val-Last)))


(dm floor> (Value)
  # Given a value, return the closest value that is equal or less than it,
  # returning NIL when no such exists
  (when (: root)
    (let (Node (: root)
          Val-Last
            (unless (> (get (: root) 'value) Value)
              (get (: root) 'value)))
      (recur (Node)
        (cond
          ((eq> Node *nil-leaf))
          ((= (get Node 'value) Value)
            (setq Val-Last (get Node 'value)))
          ((< (get Node 'value) Value)
            (setq Val-Last (get Node 'value))
            (recurse (get Node 'right)))
          (T
            (recurse (get Node 'left)))))
      Val-Last)))


(dm del-2> (Node)
  #{

    Receives a node with 0 or 1 children (typically some sort of successor)
    and removes it according to its color/children

    Node with 0 or 1 children

  }#
  (let (Left-Child (get Node 'left)
        Right-Child (get Node 'right)
        Not-Nil-Child (if (= Left-Child *nil-leaf) Right-Child Left-Child))
    (cond
      ((eq> Node (: root))
        (if (= Not-Nil-Child *nil-leaf)
            (=: root NIL)
            # if we're removing the root and it has one valid child,
            # simply make that child the root
            (prog
              (=: root Not-Nil-Child)
              (put (: root) 'parent NIL)
              (put (: root) 'color 'black))))

      ((= (get Node 'color) 'red)
        (if (children?> Node)
             #{
              Since the node is red he cannot have a child.
              If he had a child, it'd need to be black, but that would mean that
              the black height would be bigger on the one side and that would make our tree invalid
            }#
            (quit "Unexpected behavior")
            (del-leaf> This Node)))

      (T # node is black
        # The red child of a black node with 0 or 1 children
        # cannot have children, otherwise the black height of the tree becomes invalid!
        ~(assert
          (and
            (not (children?> Right-Child))
            (not (children?> Right-Child))))
        (if (= (get Not-Nil-Child 'color) 'red)
            (with Node
              (=: value (get Not-Nil-Child 'value))
              (=: left  (get Not-Nil-Child 'left))
              (=: right (get Not-Nil-Child 'right)))
            # 6 cases :o
            (del-node-black> This Node))))))


(dm del-leaf> (Leaf)
  # Simply removes a leaf node by making it's parent point to a NIL leaf
  (if (>= (get Leaf 'value) (get Leaf 'parent 'value))
      (put Leaf 'parent 'right *nil-leaf)
      (put Leaf 'parent 'left *nil-leaf)))


(dm del-node-black> (Node)
  #{

    Loop through each case recursively until we reach a terminating case.
    What we're left with is a leaf node which is ready to be deleted without consequences

  }#
  (case-1> This Node)
  (del-leaf> This Node))


(dm case-1> (Node)
  #{

        Case 1 is when there's a double black node on the root
        Because we're at the root, we can simply remove it
        and reduce the black height of the whole tree.
            --|10B|--                  --10B--
           /         \      ==>       /       \
          9B         20B            9B        20B

  }#
  (if (eq> (: root) Node)
      (put Node 'color 'black)
      (case-2> This Node)))


(dm case-2> (Node)
  #{

        Case 2 applies when
            the parent is BLACK
            the sib is RED
            the sib's children are BLACK or NIL
        It takes the sib and rotates it
                         40B                                              60B
                        /   \       --CASE 2 ROTATE-->                   /   \
                    |20B|   60R       LEFT ROTATE                      40R   80B
    DBL BLACK IS 20----^   /   \      SIBLING 60R                     /   \
                         50B    80B                                |20B|  50B
            (if the sib's direction was left of it's parent, we would RIGHT ROTATE it)
        Now the original node's parent is RED
        and we can apply case 4 or case 6

  }#
  (let (Parent (get Node 'parent)
        Go-3 T
        (Sib . Dir) (sib> This Node))
    (when
      (and
        (= (get Sib 'color) 'red)
        (= (get Parent 'color) 'black)
        (<> (get Sib 'left 'color) 'red)
        (<> (get Sib 'right 'color) 'red))
      ((get *rots Dir) This
        NIL
        Sib
        Parent)
      (put Parent 'color 'red)
      (put Sib 'color 'black)
      (case-1> This Node)
      (off Go-3))
    (when Go-3
      (case-3> This Node))))
        
        
(dm case-3> (Node)
  #{

    Case 3 deletion is when:
        the parent is BLACK
        the sib is BLACK
        the sib's children are BLACK
    Then, we make the sib red and
    pass the double black node upwards
                        Parent is black
           ---50B---    Sib is black                       ---50B---
          /         \   Sib's children are black          /         \
       30B          80B        CASE 3                       30B        |80B|  Continue with other cases
      /   \        /   \        ==>                        /  \        /   \
    20B   35R    70B   |90B|<---REMOVE                   20B  35R     70R   X
          /  \                                               /   \
        34B   37B                                          34B   37B

  }#
  (let (Parent (get Node 'parent)
        Go-4 T)
    (let Sib (car (sib> This Node))
      (when
        (and
          (= (get Sib 'color) 'black)
          (= (get Parent 'color) 'black)
          (<> (get Sib 'left 'color) 'red)
          (<> (get Sib 'right 'color) 'red))
        (put Sib 'color 'red)
        (case-1> This Parent)
        (off Go-4)))
    (when Go-4
      (case-4> This Node))))
      

(dm case-4> (Node)
  #{
    If the parent is red and the sib is black with no red children,
    simply swap their colors
    DB-Double Black
            --10R--                   --10B--        The black height of the left subtree has been incremented
           /       \                 /       \       And the one below stays the same
         DB        15B      ===>    X        15R     No consequences, we're done!
                  /   \                     /   \
                12B   17B                 12B   17B
  }#
  (let (Parent (get Node 'parent)
        Go-5 T)
    (when (= (get Parent 'color) 'red)
      (let ((Sib . Dir) (sib> This Node))
        (when 
          (and
            (=  (get Sib 'color) 'black)
            (<> (get Sib 'left  'color) 'red)
            (<> (get Sib 'right 'color) 'red))
          (let (Col-P (get Parent 'color)
                Col-S (get Sib 'color))
            (put Parent 'color Col-S)
            (put Sib 'color Col-P))
          (off Go-5))))
    (when Go-5
      (case-5> This Node))))
  

(dm case-5> (Node)
  #{

    Case 5 is a rotation that changes the circumstances so that we can do a case 6
    If the closer node is red and the outer BLACK or NIL, we do a left/right rotation, depending on the orientation
    This will showcase when the CLOSER NODE's direction is RIGHT
          ---50B---                                                    --50B--
         /         \                                                  /       \
       30B        |80B|  <-- Double black                           35B      |80B|        Case 6 is now
      /  \        /   \      Closer node is red (35R)              /   \      /           applicable here,
    20B  35R     70R   X     Outer is black (20B)               30R    37B  70R           so we redirect the node
        /   \                So we do a LEFT ROTATION          /   \                      to it :)
      34B  37B               on 35R (closer node)           20B   34B

  }#
  (let ((Sib . Dir) (sib> This Node)
        Closer-Node (get Sib (if (= Dir 'left) 'right 'left))
        Out-Node (get Sib (if (= Dir 'left) 'left 'right)))
    (when
      (and
        (= (get Closer-Node 'color) 'red)
        (<> (get Out-Node 'color) 'red)
        (= (get Sib 'color) 'black))

      ((if (= Dir 'left)
            'rot-l>
            'rot-r>)
        This NIL Closer-Node Sib)

      (put Closer-Node 'color 'black)
      (put Sib 'color 'red))

    (case-6> This Node)))


(dm case-6> (Node)
  #{

    Case 6 requires
        SIBLING to be BLACK
        OUTER NODE to be RED
    Then, does a right/left rotation on the sib
    This will showcase when the SIBLING's direction is LEFT
                        Double Black
                --50B--       |                               --35B--
               /       \      |                              /       \
  SIBLING--> 35B      |80B| <-                             30R       50R
            /   \      /                                  /   \     /   \
         30R    37B  70R   Outer node is RED            20B   34B 37B    80B
        /   \              Closer node doesn't                           /
     20B   34B                 matter                                   70R
                           Parent doesn't
                               matter
                           So we do a right rotation on 35B!

  }#
  (let ((Sib . Dir) (sib> This Node)
        Out-Node (get Sib (if (= Dir 'left) 'left 'right)))

    (if (and
          (= (get Sib 'color) 'black)
          (= (get Out-Node 'color) 'red))

        (recur (Dir)
          (let Parent-Color (get Sib 'parent 'color)
            ((get *rots Dir) This
              NIL
              Sib
              (get Sib 'parent))
            (put Sib 'color Parent-Color)
            (put Sib 'right 'color 'black)
            (put Sib 'left 'color 'black)))

        (quit "Case 6 error"))))


(dm bal> (Node)
  #{

    Given a red child node, determine if there is a need to rebalance
    (if the parent is red)

    If there is, rebalance it

  }#
  (let (Parent (get Node 'parent)
        Value (get Node 'value))
    
    (if (or
          (not Parent)
          (not (get Parent 'parent))
          (<> (get Node 'color) 'red)
          (<> (get Parent 'color) 'red))
              
        (nil)
        
        (let (Grand (get Parent 'parent)
              Node-Dir (if (> (get Parent 'value) Value) 'left 'right)
              Parent-Dir (if (> (get Grand 'value) (get Parent 'value)) 'left 'right)
              Uncle (get Grand 
                      (if (= Parent-Dir 'left) 'right 'left))
              Gen-Dir (pack Node-Dir Parent-Dir))
           
          (if (or
                (eq> Uncle *nil-leaf)
                (= (get Uncle 'color) 'black))
           
              (cond
              
                # rotate
                ((and (= Node-Dir 'left) (= Parent-Dir 'left))
                  (rot-r> This Node Parent Grand T))

                ((and (= Node-Dir 'right) (= Parent-Dir 'right))
                  (rot-l> This Node Parent Grand T))

                ((and (= Node-Dir 'left) (= Parent-Dir 'right))
                  (rot-r> This NIL Node Parent)
                  # due to the prev rotation, our node is now the parent
                  (rot-l> This Parent Node Grand T))

                ((and (= Node-Dir 'right) (= Parent-Dir 'left))
                  (rot-l> This NIL Node Parent)
                  # due to the prev rotation, our node is now the parent
                  (rot-r> This Parent Node Grand T))

                (T
                  (quit "Invalid direction")))
                  
              (recol> This Grand))))))
            
        
(dm update-parent> (Node Parent-Old-Child New-Parent)
  #{

    Our node 'switches' places with the old child
    Assigns a new parent to the node.
    If the new-parent is NIL, this means that our node becomes the root of the tree

  }#
  (put Node 'parent New-Parent)
  (if New-Parent
      (put New-Parent
        (if (>
              (get New-Parent 'value)
              (get Parent-Old-Child 'value))
            'left
            'right)
        Node)
      (=: root Node)))


(dm rot-r> (Node Parent Grand To-Recolor)
  (let Great (get Grand 'parent)
    (update-parent> This
      Parent
      Grand
      Great)
    (let Old-Right (get Parent 'right)
      (put Parent 'right Grand)
      (put Grand 'parent Parent)
      (put Grand 'left Old-Right)
      (put Old-Right 'parent Grand))
    (when To-Recolor
      (put Parent 'color 'black)
      (when Node (put Node 'color 'red))
      (put Grand 'color 'red))))


(dm rot-l> (Node Parent Grand To-Recolor)
  (let Great (get Grand 'parent)
    (update-parent> This
      Parent
      Grand
      Great)
    (let Old-Left (get Parent 'left)
      (put Parent 'left Grand)
      (put Grand 'parent Parent)
      (put Grand 'right Old-Left)
      (put Old-Left 'parent Grand))
    (when To-Recolor
      (put Parent 'color 'black)
      (when Node (put Node 'color 'red))
      (put Grand 'color 'red))))
            

(dm recol> (Grand)
  (put Grand 'right 'color 'black)
  (put Grand 'left 'color 'black)
  (unless (eq> Grand (: root))
    (put Grand 'color 'red))
  (bal> This Grand))


(dm find-parent> (Value)
  # Finds a place for the value in our binary tree
  # Return the appropriate parent node for our new node
  # as well as the side it should be on
  (let Parent (: root)
    (recur (Parent)
      (cond
        ((= Value (get Parent 'value)))
        ((< (get Parent 'value) Value)
          (if (= (get Parent 'right 'color) 'white)
              (cons Parent 'right)
              (recurse (get Parent 'right))))
        ((< Value (get Parent 'value))
          (if (= (get Parent 'left 'color) 'white)
              (cons Parent 'left)
              (recurse (get Parent 'left))))))))

(dm find-node> (Value)
  (let Root (: root)
    (recur (Root)
      (cond
        ((or
          (not Root)
          (eq> Root *nil-leaf)))
        ((> Value  (get Root 'value))
          (recurse (get Root 'right)))
        ((< Value  (get Root 'value))
          (recurse (get Root 'left)))
        (T Root)))))


(dm -find-in-order-successor> (Node)
  (let (Right-Node (get Node 'right)
        Left-Node (get Right-Node 'left))
    (if (eq> Left-Node *nil-leaf)
        Right-Node
        (until (= (get Left-Node 'left) *nil-leaf)
          (setq Left-Node (get Left-Node 'left)))
        Left-Node)))
        
        
(dm sib> (Node)
  #{

    Returns the sib of the node, as well as the side it is on
    e.g
        20 (A)
      /     \
    15(B)    25(C)
    -get-sib(25(C)) => 15(B), 'R'

  }#
  (let Parent (get Node 'parent)
    (if (>= (get Node 'value) (get Parent 'value))
        (cons (get Parent 'left) 'left)
        (cons (get Parent 'right) 'right))))
