main :: IO ()
main = putStrLn "Test suite not yet implemented"

{-

#### Some test ideas

let p = number of proposals
    i = interest ratio
    r = probability of getting attention

if the client interviews only one applicant, let's say that the
probability of getting attention is inversely proportional to the
number of proposals:

    r = 1 / p

but if the client interviews everyone who sends a proposal, the
probability of getting attention is 1

with other parameters staying constant, the probability of getting
attention is equal to the number of interviewed applicants versus all
applicants, which is how i calculate the interest rate

-}
