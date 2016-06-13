import Opwer
import Upwork

main = do
  OpwerCredential oauth credential <- readCredential
  askForCategories oauth credential
