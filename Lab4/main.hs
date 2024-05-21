import Route
import RouteGUI
import Graph  -- Create a module and use a sensible graph representation
import PrioSkew
import qualified PrioSkew as PQ -- OBS: a max-heap
import Data.Map (Map)
import qualified Data.Map as M
import Data.Maybe (isNothing, fromJust)


-- A djusktra node with a node, its predecessor and the cost to get there
data Dijk a b
  = Dijk {
    to :: a,
    dist :: b,
    from :: a} deriving (Eq, Show)

instance (Ord a, Ord b) => Ord (Dijk a b) where
  compare d1 d2 = compare (dist d2) (dist d1)
-- higher priority on shorter distance


shortestPath :: (Ord a, Ord b, Num b) => Graph a b -> a -> a -> Maybe ([a], b)
shortestPath g from to = findShortest from to (dijkstra g M.empty (PQ.insert (Dijk from 0 from) PQ.empty))
 -- TODO: implement Dijkstra's algorithm

findShortest :: a -> a -> Map a (b,a) -> Maybe ([a],b)
findShortest s = undefined

dijkstra :: (Ord a, Ord b, Num b) => Graph a b -> Map a (b, a) -> SkewHeap (Dijk a b) -> Map a (b, a)
dijkstra g s q
  -- if queue is empty return the set of all Djikstra nodes
  | isNothing $ PQ.rootOf q = s
  -- otherwise check if we already have seen the node
  | otherwise = if  x `M.notMember` s
    -- if we have'nt seen the node then we add it to the set of Djikstra nodes
    -- and add all adjacent nodes to the queue (as Djikstra nodes) 
    then dijkstra g (M.insert x (d, z) s) (foldr (insert . toDijk d) q' (adj x g))
    -- if we have seen the node already then do nothing
    else dijkstra g s q'
    where
      -- dequeue operation
      (Dijk x d z) = fromJust $ PQ.rootOf q
      q' = PQ.removeRoot q

-- help function to convert the output of adj to Djikstra nodes
toDijk :: (Num b) => b -> Edge a b -> Dijk a b
toDijk d e = Dijk (dst e) (d + label e) (src e)


main :: IO ()
main = undefined  -- TODO: read arguments, build graph, output shortest path

startGUI :: IO ()
startGUI = do
  Right stops <- readStops "data/stops-gbg.txt"
  Right lines <- readLines "data/lines-gbg.txt"
  let graph = undefined -- TODO: build your graph here using stops and lines
  runGUI stops lines graph shortestPath