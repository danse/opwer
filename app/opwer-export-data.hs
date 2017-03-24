{-# LANGUAGE OverloadedStrings #-}

import Upwork
import qualified Data.ByteString.Lazy.Char8 as C
import Data.Either( partitionEithers )
import Text.Read( readEither )
import System.IO( stderr, hPutStrLn )
import Opwer
import Data.List (intercalate)
import Text.Printf( printf )

formatProfile :: JobProfile -> String
formatProfile profile = intercalate "," [cand, inte, tier, char, aver, eng, weeks, amou]
  where cand = (show . numberOfCandidates) profile
        inte = ((printf "%.2f") . interestRatio) profile
        tier = opContractorTier profile
        char = (opTotCharge . buyer) profile
        amou = amount profile
        aver = (show . averageAssignmentRate) profile
        eng = opEngagement profile
        weeks = engagementWeeks profile

format :: [JobProfile] -> String
format = unlines . ("cand,inte,tier,char,aver,eng,weeks,amou":) . map formatProfile

main = do
  contents <- C.getContents
  let (l,r) = partitionEithers (map (readEither . C.unpack) (C.lines contents))
    in putStr (format r)
