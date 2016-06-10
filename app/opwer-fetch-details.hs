import Opwer
import Upwork
import Web.Authenticate.OAuth( Credential )
import Data.Aeson( decode )
import qualified Data.ByteString.Lazy as L
import Control.Exception( catch, SomeException )

printException :: SomeException -> IO ()
printException e = putStrLn (show e)

main = do
  OpwerCredential oauth credential <- readCredential
  contents <- L.getContents
  case (decode contents :: Maybe SearchResult) of
    Nothing -> putStrLn "The input does not seem valid"
    Just result -> do
      mapM (\ (JobResult id) -> catch (askForJob oauth credential id) printException) (jobs result)
      return ()
