import Opwer
import Upwork
import Web.Authenticate.OAuth( Credential )

readCredential :: IO OpwerCredential
readCredential = do
  s <- readFile credentialFileName
  return (read s)

main = do
  OpwerCredential oauth credential <- readCredential
  askForJobs oauth credential
