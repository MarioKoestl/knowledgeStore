{--
  Last changed Time-stamp: <2009-03-17 20:36:16 xtof>
  $Id$

  Example provided by Christian Hoener zu Siederdissen, 2012-03-21

  buid: ghc --make -O2 wordcount2.hs
  run:  wordcount2 < FOO.txt
--}

module Main where

import Data.List
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Lazy.Char8 as C
import qualified Data.Map as M
import qualified Data.List as L
import Data.Char (toLower, isAlpha)
import Data.Ord (comparing)

main = do
  -- read input lazily from stdin
  cnts <- B.getContents
  -- start understanding at the bottom...
  --
  -- take (key = word, value = count), print count then word
  mapM_ (\(k,v) -> putStr (show v) >> putStr " " >> C.putStrLn k)
          -- sort using the second tuple element (word count) (stable sort)
          $ L.sortBy (comparing snd)
          -- create list from map sorted by word
          $ M.toList
          -- start with empty map, for each word in list use the inner function:
          --  \m k with 'm' the accumulator (map), k the current word or key:
          --    insert into the map 'm' the current word 'k' with value '1'.
          --    if 'k' is already in the map, then update the value with (+1).
          $ foldl' (\m k -> M.insertWith' (+) k 1 m) M.empty
          -- filter out all empty words
          $ L.filter (not . C.null)
          -- keep only alphabetic characters from each word
          $ L.map (C.filter isAlpha)
          -- take the input string and make many words out of it
          $ C.words
          -- all uppercase letters become lowercase letters
          $ C.map toLower
          -- original input
          $ cnts

-- End of file
