import Opwer
import Upwork
import Web.Authenticate.OAuth( Credential )

main = do
  OpwerCredential oauth credential <- readCredential
  askForJobs oauth credential
