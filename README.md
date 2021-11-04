# rb-tree

Red-black tree in PicoLisp. There remains potential for optimization.

## Data

    (symbols 'rbtree 'pico)

    (class +RBNode)
    (dm T (Value Color Parent Left Right)
      (=: value  Value)
      (=: color  Color)
      (=: parent Parent)
      (=: left   Left)
      (=: right  Right))

    (class +Tree)
    (dm T ()
      (=: cnt 0)
      (=: root NIL))

## Code

    # Copy to a file or REPL

    (symbols '(rbtree pico))

    (let Rbt (new '(+Tree))

      # Add the value/num 90, then 70, etc
      # Then remove them

      (add> Rbt 90)
      (add> Rbt 70)
      (add> Rbt 43)
      (del> Rbt 70)
      (add> Rbt 24)
      (add> Rbt 14)
      (add> Rbt 93)
      (add> Rbt 47)
      (del> Rbt 47)
      (del> Rbt 90)
      (add> Rbt 57)
      (add> Rbt 1)
      (add> Rbt 60)
      (add> Rbt 47)
      (del> Rbt 47)
      (del> Rbt 1)
      (del> Rbt 43)
      (add> Rbt 49)

      # Return a linked list of all elements
      # in-order traversed,
      # i.e go left, save node, go right
      (list> Rbt)

      Rbt)

## Test

    # CLI invocation for tests

    pil test.l -rbtree~run-tests +
