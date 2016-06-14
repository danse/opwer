{-# LANGUAGE DeriveGeneric #-}
module Opwer where

import Web.Authenticate.OAuth
import qualified Data.ByteString.Lazy.Char8 as C
import Data.Aeson( eitherDecode )
import Control.Monad( mapM )
import Data.Either( rights, lefts )
import Network.HTTP.Client( responseBody )
import Control.Exception( SomeException )
import Upwork

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
  where r = rights decoded
        l = lefts decoded
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
  mapM putStrLn (map show (fun (map (read . C.unpack) (C.lines contents))))

printResponse = C.putStrLn . responseBody

printException :: SomeException -> IO ()
printException e = putStrLn (show e)


