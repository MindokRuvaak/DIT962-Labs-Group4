{-# OPTIONS -Wall #-}
{-# OPTIONS_GHC -Wno-unused-matches #-}

--------------------------------------------------------------------------------

module AATree
  ( AATree, -- type of AA search trees
    emptyTree, -- AATree a
    get, -- Ord a => a -> AATree a -> Maybe a
    insert, -- Ord a => a -> AATree a -> AATree a
    inorder, -- AATree a -> [a]
    remove, -- Ord a => a -> AATree a -> AATree a
    size, -- AATree a -> Int
    height, -- AATree a -> Int
    checkTree, -- Ord a => AATree a -> Bool
  )
where

--------------------------------------------------------------------------------

-- AA search trees
data AATree a
  = Empty
  | Node Level (AATree a) a (AATree a)
  deriving (Eq, Show, Read)

-- return an empty tree
emptyTree :: AATree a
emptyTree = Empty

-- return the value specific or Nothing if the value is not present
get :: Ord a => a -> AATree a -> Maybe a
get _ Empty = Nothing
get toGet (Node _ l v r) = case compare toGet v of
  LT -> get toGet l
  GT -> get toGet r
  EQ -> Just v

-- You may find it helpful to define

-- split any 4 nodes into 2 nodes again
split :: AATree a -> AATree a
split x@(Node xk a xv y@(Node yk b yv z@(Node {}))) =
  if xk == yk && xk == level z
    then
      let newX = Node xk a xv b
       in Node (yk + 1) newX yv z
  else x -- not a 4 node
    -- if not a 4 node given, just return tree unchanged
-- if we dont have at least 3 nodes we cant have a 4 node and we do nothing
split tree = tree

skew :: AATree a -> AATree a
-- if malformed 3-node
skew y@(Node yk x@(Node xk a xv b) yv c) =
  if yk == xk
    then
      let newY = Node yk b yv c
       in Node xk a xv newY
    else y
-- a malformed 4-node will be fixed by algorithm for malformed 3-node
skew a = a

-- and call these from insert.
insert :: Ord a => a -> AATree a -> AATree a
insert toInsert = split . skew . insert' toInsert
  where
    insert' _ Empty = leaf toInsert
    insert' val (Node k l v r) = case compare val v of
      LT -> Node k (insert val l) v r
      EQ -> Node k l val r
      GT -> Node k l v (insert val r)

-- | increasing order
inorder :: AATree a -> [a]
inorder Empty = []
inorder t = go t []
  where
    go Empty acc = acc
    go (Node _ l v r) acc = go l (v:go r acc)

size :: AATree a -> Int
size = error "size not implemented"

height :: AATree a -> Int
height = level

--------------------------------------------------------------------------------
-- Optional function

remove :: Ord a => a -> AATree a -> AATree a
remove _ Empty = Empty
remove toRemove t@(Node k l v r) = case compare toRemove v of
  LT -> Node k (remove toRemove l) v r
  EQ -> error "remove not implemented"
  GT -> Node k l v (remove toRemove r)


--------------------------------------------------------------------------------
-- other help functions
type Level = Int

level :: AATree a -> Level
level Empty = 0
level (Node k _ _ _) = k

leaf :: a -> AATree a
leaf v = Node 1 Empty v Empty

--------------------------------------------------------------------------------
-- Check that an AA tree is ordered and obeys the AA invariants

checkTree :: Ord a => AATree a -> Bool
checkTree root =
  isSorted (inorder root)
    && all checkLevels (nodes root)
  where
    nodes x
      | isEmpty x = []
      | otherwise = x : nodes (leftSub x) ++ nodes (rightSub x)

-- True if the given list is ordered
isSorted :: Ord a => [a] -> Bool
isSorted list = go list True
  where
    go []        b = b
    go [x]       b = b
    go (x:y:lst) b = (x < y) && b && go (y:lst) b

-- Check if the invariant is true for a single AA node
-- You may want to write this as a conjunction e.g.
--   checkLevels node =
--     leftChildOK node &&
--     rightChildOK node &&
--     rightGrandchildOK node
-- where each conjunct checks one aspect of the invariant
checkLevels :: AATree a -> Bool
checkLevels node =
  leftChildOK node &&
  rightChildOK node &&
  rightRightGrandchildOK node

leftChildOK :: AATree a -> Bool
leftChildOK node = level node - level (leftSub node) == 1
-- leftChildOK Empty = True
-- leftChildOK (Node k l _ _) = k - level l == 1


rightChildOK :: AATree a -> Bool
rightChildOK node = (level node - level (rightSub node)) `elem` [0,1]
-- rightChildOK Empty = True
-- rightChildOK (Node k _ _ r) = k - level r == 0 || k - level r == 1

rightRightGrandchildOK :: AATree a -> Bool
rightRightGrandchildOK node = level node > level (rightSub $ rightSub node)
-- rightRightGrandchildOK Empty = True
-- rightRightGrandchildOK (Node k _ _ Empty) = True
-- rightRightGrandchildOK (Node k _ _ (Node _ _ _ rr)) = k > level rr

isEmpty :: AATree a -> Bool
isEmpty Empty = True
isEmpty _     = False

leftSub :: AATree a -> AATree a
leftSub (Node _ l _ _) = l
leftSub Empty          = Empty

rightSub :: AATree a -> AATree a
rightSub (Node _ _ _ r) = r
rightSub Empty          = Empty

--------------------------------------------------------------------------------
