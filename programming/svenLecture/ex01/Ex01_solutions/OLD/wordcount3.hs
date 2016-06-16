{-# LANGUAGE TupleSections #-}
{--
  Example provided by Christian Hoener zu Siederdissen, 2012-03-21

  buid: ghc --make -O2 wordcount3.hs
  run:  wordcount3 < FOO.txt
--}

-- | In Haskell, we spend almost all our time combining small functions. That
-- is no problem, the compiler knows how to optimize stuff. In this case, we
-- have of course opted for a simple algorithmic description instead of being
-- "fastest".

module Main where

import Control.Category ((>>>))
import Data.Char (toLower, isAlpha)
import Data.List
import Data.Ord (comparing)
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Lazy.Char8 as C
import qualified Data.List as L
import qualified Data.Map as M



-- just being pointless, at least in fmap.
--
-- (>>>) :: Category cat => cat a b -> cat b c -> a c
-- f >>> g = g . f

(>$>) = flip fmap

          -- read whole stdin lazily
main  =   B.getContents
      -- take the function in brackets (on the right) and fmap it over the
      -- monadic contents on the left (getContents is IO ByteString)
            -- make every uppercase letter lowercase
      >$> ( C.map toLower
            -- split at each whitespace into words (is list of words now)
            >>> C.words
            -- keep only alphabetic characters in each word
            >>> L.map (C.filter isAlpha)
            -- remove all zero-character words
            >>> L.filter (not . C.null)
            -- tuple up each word with a count of 1: list of (word,1)
            >>> L.map (,1)
            -- create a map from this list of (word,1), adding up the 1's
            -- the map maps words to counts
            >>> M.fromListWith (+)
            -- make a sorted list of (word,count)
            >>> M.toList
            -- lets sort by the second element, or count (stable sort)
            >>> L.sortBy (comparing snd)
          )
      -- at this point we have a sorted list of words and counts which we now
      -- print. The value, or count, first. Then the word.
      >>= mapM_ (\(k,v) -> putStr (show v) >> putStr " " >> C.putStrLn k)

-- End of file
