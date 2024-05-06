{-# OPTIONS -Wall #-}

--------------------------------------------------------------------------------

module AATree (
  AATree,        -- type of AA search trees
  emptyTree,     -- AATree a
  get,           -- Ord a => a -> AATree a -> Maybe a
  insert,        -- Ord a => a -> AATree a -> AATree a
  inorder,       -- AATree a -> [a]
  remove,        -- Ord a => a -> AATree a -> AATree a
  size,          -- AATree a -> Int
  height,        -- AATree a -> Int
  checkTree      -- Ord a => AATree a -> Bool
 ) where

--------------------------------------------------------------------------------

-- AA search trees
data AATree a 
  = Empty
  | Node Level (AATree a) a (AATree a)
  deriving (Eq, Show, Read)

emptyTree :: AATree a
emptyTree = Empty

get :: Ord a => a -> AATree a -> Maybe a
get _ Empty  = Nothing
get toGet (Node _ l v r) = case compare toGet v of
  LT -> get toGet l
  GT -> get toGet r
  EQ -> Just v


-- You may find it helpful to define

--
split :: AATree a -> AATree a
split x@(Node xk a xv y@(Node yk b yv z)) 
  = if xk == yk && xk == level z 
    then let newX = Node xk a xv b in 
      Node (yk+1) newX yv z
    else x -- not a 4 node
-- if not a 4 node given, just return tree unchanged
split tree = tree

skew  :: AATree a -> AATree a
-- if malformed 3-node
skew y@(Node yk x@(Node xk a xv b) yv c) 
  = if yk == xk 
    then let newY = Node yk b yv c in 
      Node xk a xv newY
    else y
-- a malformed 4-node will be caught by
skew a = a

-- and call these from insert.
insert :: Ord a => a -> AATree a -> AATree a
insert toInsert = split . skew . insert' toInsert
  where 
    insert' = undefined

inorder :: AATree a -> [a]
inorder = error "inorder not implemented"

size :: AATree a -> Int
size = error "size not implemented"

height :: AATree a -> Int
height = error "height not implemented"

--------------------------------------------------------------------------------
-- Optional function

remove :: Ord a => a -> AATree a -> AATree a
remove = error "remove not implemented"
--------------------------------------------------------------------------------

type Level = Int

level :: AATree a -> Level
level Empty          = 0
level (Node k _ _ _) = k

singleton :: a -> AATree a
singleton v = Node 1 Empty v Empty

--------------------------------------------------------------------------------
-- Check that an AA tree is ordered and obeys the AA invariants

checkTree :: Ord a => AATree a -> Bool
checkTree root =
  isSorted (inorder root) &&
  all checkLevels (nodes root)
  where
    nodes x
      | isEmpty x = []
      | otherwise = x:nodes (leftSub x) ++ nodes (rightSub x)

-- True if the given list is ordered
isSorted :: Ord a => [a] -> Bool
isSorted = error "isSorted not implemented"

-- Check if the invariant is true for a single AA node
-- You may want to write this as a conjunction e.g.
--   checkLevels node =
--     leftChildOK node &&
--     rightChildOK node &&
--     rightGrandchildOK node
-- where each conjunct checks one aspect of the invariant
checkLevels :: AATree a -> Bool
checkLevels = error "checkLevels not implemented"

isEmpty :: AATree a -> Bool
isEmpty = error "isEmpty not implemented"

leftSub :: AATree a -> AATree a
leftSub = error "leftSub not implemented"

rightSub :: AATree a -> AATree a
rightSub = error "rightSub not implemented"

--------------------------------------------------------------------------------

