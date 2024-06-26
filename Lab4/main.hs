import Route
import RouteGUI
import Graph  -- Create a module and use a sensible graph representation
import Data.PSQueue (PSQ)
import qualified Data.PSQueue as PQ
import Data.Map (Map)
import qualified Data.Map as M
import Data.Maybe (isNothing, fromJust)
import System.Environment


-- use the djukstra function to compute the set of nodes we can reach and the cost to do so 
-- and then compute the shortest path between two given nodes, returns nothing if there is no path
shortestPath :: (Ord a, Ord b, Num b) => Graph a b -> a -> a -> Maybe ([a], b)
shortestPath g from to = findShortest from to (dijkstra g M.empty (PQ.singleton (from , from) 0))
 -- TODO: implement Dijkstra's algorithm

-- find the shortest path between two nodes given a set of Djikstra nodes
findShortest :: (Ord a, Ord b, Num b) => a -> a -> Map a (b, a) -> Maybe ([a],b)
findShortest from to set
  -- if the end node "to" is not present in the set we cannot reach it and return nothing
  | isNothing $ M.lookup to set = Nothing
  -- if the to node is present we compute the list of nodes taken to reach the end node
  | otherwise = Just (stops, totDist)
  where
    (totDist, _) = fromJust $ M.lookup to set
    stops = reverse $ gatherStops [] from to set

-- compute the list of nodes needed to reach the end node
gatherStops :: Ord t => [t] -> t -> t -> Map t (a, t) -> [t]
gatherStops stops from to set
      | from == to = from:stops
      | otherwise  = let (_, prevTo) = fromJust $ M.lookup to set
        in to : gatherStops stops from prevTo set

-- computes the set of nodes we can rach from any given node along with its cost
dijkstra :: (Ord a, Ord b, Num b) => Graph a b -> Map a (b, a) -> PSQ (a, a) b -> Map a (b, a)
dijkstra g s q
  -- if queue is empty return the set of all nodes
  | isNothing $ PQ.findMin q = s
  -- otherwise check if we already have seen the node
  | otherwise = if  x `M.notMember` s
    -- if we have'nt seen the node then we add it to the set of Djikstra nodes
    -- and add all adjacent nodes to the queue (as Djikstra nodes) 
    then dijkstra g (M.insert x (d, z) s) (foldr (insertQ . toKeyValuePair d) q' (adj x g))
    -- if we have seen the node already then do nothing
    else dijkstra g s q'
    where
      -- dequeue operation
      ((x , z) PQ.:->  d) = fromJust $ PQ.findMin q
      q' = PQ.deleteMin q

-- help function to convert the output of adj to Djikstra nodes
toKeyValuePair :: (Num b) => b -> Edge a b -> ((a,a), b)
toKeyValuePair d e = ((dst e, src e) , d + label e)

-- insert our touple of values into a PSQ correctly
insertQ :: (Ord a, Ord b) => ((a,a), b) -> PSQ (a,a) b -> PSQ (a,a) b
insertQ (value, prio) = PQ.insert value prio

graphBuilder :: [Stop] -> [LineTable] -> Graph String Integer
graphBuilder stops = foldr insertLineTable (foldr (addVertex . name) Graph.empty stops)

-- insert a LineTable of edges into a graph
insertLineTable :: LineTable -> Graph String Integer -> Graph String Integer
insertLineTable lt = lineStopListInsert (stops lt)
  where
    lineStopListInsert :: [LineStop] -> Graph String Integer -> Graph String Integer
    lineStopListInsert (x:y:ys) graph  = lineStopListInsert (y:ys) (addEdge (stopName x) (stopName y) (time y) graph)
    lineStopListInsert _  graph        = graph

-- format the raw output string
outputParse :: Maybe([String], Integer) -> String
outputParse Nothing              = "0\n"
outputParse (Just (stops, time)) = show time ++ "\n" ++ unlines stops


main :: IO ()
main = do 
  [stopsFile, linesFile, from, to] <- getArgs
  Right stops       <- readStops stopsFile
  Right lineTables  <- readLines linesFile
  let graph = graphBuilder stops lineTables
  let rawOutput = shortestPath graph from to
  putStr (outputParse rawOutput)
  return ()

-- this gives an unised warning but since its part of 
-- the original skeleton we presume its fine
startGUI :: IO ()
startGUI = do
  Right stops <- readStops "data/stops-nopath.txt"
  Right lineTables <- readLines "data/lines-nopath.txt"
  let graph = graphBuilder stops lineTables
  runGUI stops lineTables graph shortestPath

