import Opwer
import Upwork
import Web.Authenticate.OAuth( Credential )
import Data.Aeson( decode )
import qualified Data.ByteString.Lazy as L
import Control.Exception( catch, SomeException )

askAndPrint oauth credential id = do
  resp <- askForJob oauth credential id
  printResponse resp

main = do
  OpwerCredential oauth credential <- readCredential
  contents <- L.getContents
  case (decode contents :: Maybe SearchResult) of
    Nothing -> putStrLn "The input does not seem valid"
    Just result -> do
      mapM (\ (JobResult id) -> catch (askAndPrint oauth credential id) printException) (jobs result)
      return ()
