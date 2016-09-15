{-# LANGUAGE DeriveGeneric #-}
module Opwer where

import Web.Authenticate.OAuth
import qualified Data.ByteString.Lazy.Char8 as C
import Data.Aeson( eitherDecode )
import Control.Monad( mapM )
import Data.Either( partitionEithers )
import Network.HTTP.Client( responseBody )
import Control.Exception( SomeException )
import System.IO( stderr, hPutStrLn )
import Text.Read( readEither )
import Upwork hiding( id )

credentialFileName = "opwer-credential"

data OpwerCredential = OpwerCredential {
  oauth :: OAuth,
  credential :: Credential
  } deriving (Show, Read)

readCredential :: IO OpwerCredential
readCredential = do
  s <- readFile credentialFileName
  return (read s)

sortContents :: C.ByteString -> ([JobProfile] -> [JobProfile]) -> [String]
sortContents cont sort_ = (((map show) . sort_ . (map profile)) r) ++ l
  where (l,r) = partitionEithers decoded
        decoded = map eitherDecode (C.lines cont)

parseJobDetails :: C.ByteString -> String
parseJobDetails det = either id (show . profile) (eitherDecode det)

-- |Given a sorting function, reads lines with job profiles from
-- standard input, and outputs them sorted
sortJobDetails :: ([JobProfile] -> [JobProfile]) -> IO ([()])
sortJobDetails fun = do
  contents <- C.getContents
  mapM putStrLn (sortContents contents fun)

modifyList :: ([JobProfile] -> [JobProfile]) -> IO ([()])
modifyList fun = do
  contents <- C.getContents
  let (l,r) = partitionEithers (map (readEither . C.unpack) (C.lines contents))
    in do
      mapM putStrLn (map show (fun r))
      mapM (hPutStrLn stderr) l

printResponse = C.putStrLn . responseBody

printException :: SomeException -> IO ()
printException e = putStrLn (show e)

showException :: SomeException -> IO String
showException e = return (show e)

numberOfCandidates :: JobProfile -> Int
numberOfCandidates = length . candidatesWrapper . candidates

interestRatio :: JobProfile -> Float
interestRatio job = i / c
  where i = (read . intervieweesTotalActive) job
        c = (fromIntegral . numberOfCandidates) job

readFloat :: String -> Float
readFloat = read

-- > readRate "$35.4"
-- 35.4
readRate :: String -> Float
readRate s = read (drop 1 s)

oneOrManyToMany :: OneOrMany a -> [a]
oneOrManyToMany (One a) = [a]
oneOrManyToMany (Many aa) = aa

averageRate assignments
  | totalPaid == 0 = 0
  | otherwise = totalPaid / totalHours
  where totalPaid = sum (map paid assignments)
        totalHours = sum (map hours assignments)
        hours = readFloat . asTotalHours
        paid a = ((readRate . asRate) a) * (hours a)

averageAssignmentRate = averageRate . oneOrManyToMany . assignmentsWrapper . assignments
