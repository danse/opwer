{-# LANGUAGE OverloadedStrings #-}

import Control.Monad( forM_ )
import Text.Blaze.Html5 as H hiding( map, main )
import Text.Blaze.Html5.Attributes as A
import Text.Blaze.Renderer.String( renderHtml )
import Upwork
import qualified Data.ByteString.Lazy.Char8 as C
import Data.Either( partitionEithers )
import Text.Read( readEither )
import System.IO( stderr, hPutStrLn )
import Opwer
import Text.Printf( printf )
import WebOutput (toTheBrowser)

formatProfile :: JobProfile -> Html
formatProfile profile = H.div $ do
  H.a ! A.target "_blank" ! A.href (toValue ref) $ do
    (H.span . toHtml) (((show . numberOfCandidates) profile) ++ " ")
    (H.span . toHtml) ((((printf "%.2f") . interestRatio) profile) ++ " ":: [Char])
    -- (H.span . toHtml) ("(" ++ (opTotCand profile) ++ ") ")
    (H.span . toHtml) ((opTitle profile) ++ " ") ! A.class_ "job-title"
    (H.span . toHtml) ("tier: " ++ opContractorTier profile ++ " ")
    (H.span . toHtml) ("average: " ++ (show . averageAssignmentRate) profile ++ " ")
    (H.span . toHtml) ("total: " ++ (show . opTotCharge . buyer) profile ++ " ")
    (H.span . toHtml) ("fixed: " ++ (show . amount) profile ++ " ")
  where ref = "https://www.upwork.com/jobs/_"++(Upwork.id profile)

format :: [JobProfile] -> Html
format profiles = docTypeHtml $ do
  H.head $ do
    H.title "Results"
    H.style "a:visited { color: #bfbfbf; }"
    H.style "a:hover { color: #e473bb; }"
    H.style "a { text-decoration: none }"
    H.style ".job-title { font-size: 19pt; line-height: 40pt; margin: 26pt; }"
  body $ do
    p "Results:"
    H.div (forM_ profiles formatProfile)

main = do
  contents <- C.getContents
  let (l,r) = partitionEithers (map (readEither . C.unpack) (C.lines contents))
    in do
      toTheBrowser (renderHtml (format r))
      mapM (hPutStrLn stderr) l

