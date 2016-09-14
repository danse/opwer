{-# LANGUAGE PartialTypeSignatures #-}
import Opwer
import Upwork
import Web.Authenticate.OAuth( Credential )
import qualified Data.ByteString as B
import qualified Data.ByteString.Lazy as L
import Data.String( fromString )
import Data.Maybe( Maybe( Just ) )
import System.Environment( getArgs )
import Control.Exception( catch )
import Data.Aeson( decode )
import Network.HTTP.Client( responseBody )
import Control.Applicative( (<$>) )


readQuery :: String -> [(String, String)]
readQuery = read

adaptQuery :: (String, String) -> (B.ByteString, Maybe B.ByteString)
adaptQuery (a,b) = (fromString a, (Just . fromString) b)

convertQuery = (map adaptQuery) . readQuery

askAndPrint :: _ -> _ -> _ -> IO ()
askAndPrint oauth credential id = do
  resp <- askForJob oauth credential id
  L.putStrLn (responseBody resp)

main = do
  [arg] <- getArgs
  queryContents <- readFile arg
  OpwerCredential oauth credential <- readCredential
  resp <- askForJobs oauth credential (convertQuery queryContents)
  case (decode (responseBody resp) :: Maybe SearchResult) of
    Nothing -> putStrLn "The input does not seem valid"
    Just result -> do
      mapM (\ (JobResult id) -> catch (askAndPrint oauth credential id) printException) (jobs result)
      return ()
