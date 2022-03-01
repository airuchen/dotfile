module XMonad.Prompt.SaferPrompts
  (
    saferManPrompt,
    saferSshPrompt,
    saferSftpPrompt,
    safeTermProg,
    getAllManEntries,
    ManEntry
  ) where

import XMonad
import XMonad.Prompt
import XMonad.Util.Run
import Data.List (isPrefixOf, isSuffixOf, elemIndex)
import Control.Monad (liftM2)
import Control.Exception (catch)
import System.Exit
import System.Process (readProcessWithExitCode) -- run whatis

-- Pass all parameters as args so no shell expansion happens
safeTermProg :: MonadIO m => String -> [String] -> m()
safeTermProg prog args = safeSpawn "st" $ ["-e", prog] ++ words (concat args)

-- This should be used to filter the completion
type Predicate = String -> String -> Bool

-- This controls the prefix for the prompt
newtype CustomPrompt = CustomPrompt String
instance XPrompt CustomPrompt where
  showXPrompt (CustomPrompt s) = s ++ ": "
--
-- TODO make completion
getFakeCompletion :: Predicate -> String -> IO [String]
getFakeCompletion p s = return []

saferPrompt :: String -> XPConfig -> X ()
saferPrompt prog config = mkXPrompt (CustomPrompt prog) config (getFakeCompletion $ searchPredicate config) run
  where run = safeTermProg prog . return

-- Attempt to parse a section from a string
getSection :: String -> Maybe Char
getSection s
  | isSection s = Just $ head s
  | otherwise = Nothing

-- Is the string a section
isSection :: String -> Bool
isSection [] = False
isSection [s] = s `elem` "123456789"
isSection (_:_) = False

-- Parse current completion candidates stuff from words, may be just a candidate or a section and candidate
getManPair :: [String] -> (Maybe Char, Maybe String)
getManPair [] = (Nothing, Nothing)
getManPair [s] = (Nothing, Just s)
getManPair [a, b] = (getSection a, Just b)
getManPair ( _:b:c) = getManPair $ b : c

-- | Program section, name description
data ManEntry = ManEntry { section     :: Char
                         , name        :: String
                         , desc :: String
                         }

instance Show ManEntry where
  --show e = name e ++ " (" ++ [section e] ++ ") - " ++ desc e
  --show e = [section e] ++ " " ++ name e ++ " - " ++ desc e
  show e = [section e] ++ " " ++ name e

-- | Man entry from whatis line
parseManEntry :: [String] -> ManEntry
parseManEntry (name:secstr:_:desc) = ManEntry sec name (unwords desc)
  where
    (_:sec:_) = secstr

-- | Run whatis and get all entries
getAllRawManEntries :: IO [String]
getAllRawManEntries = do
  ret <- runProcessWithInput "/usr/bin/whatis" ["-w", "*"] ""
  return $ lines ret

-- | Sort and parse output of whatis
parseManEntries :: [String] -> [ManEntry]
parseManEntries lines = map (parseManEntry . words) (uniqSort lines)

getAllManEntries :: IO [ManEntry]
getAllManEntries = fmap parseManEntries getAllRawManEntries

-- | Filter by section if there's one
sectionFilter :: Maybe Char -> ManEntry -> Bool
sectionFilter Nothing _ = True
sectionFilter (Just s) e = section e == s

-- | Filter by name if there's one
nameFilter :: Maybe String -> ManEntry -> Bool
nameFilter Nothing _ = True
nameFilter (Just s) e = s `isPrefixOf` name e

makeFilter :: (Maybe Char, Maybe String) -> ManEntry -> Bool
makeFilter (Nothing, Nothing) e = False
makeFilter (sec, name) e = sectionFilter sec e && nameFilter name e

-- | Attempt to split query into section and command and filter the candidates based on that
manCompl :: [ManEntry] -> String -> IO [String]
manCompl candidates str = do
  let candidate = getManPair $ words str
  let f = makeFilter candidate
  return $ map show $ filter f candidates

-- | Modified version of getNextOfLastWord because we had to modify the commandToComplete for section
-- parsing but we only complete against the last element
-- I guess to do this properly I'd have to put man (7) in the completion list and
-- properly convert between command and completion
nextCompletionForMan :: XPrompt t => t -> String -> [String] -> String
nextCompletionForMan t c l = skipLastWord c ++ completionToCommand t (l !! ni)
    where ni = case getLastWord c `elemIndex` map getLastWord l of
                 Just i -> if i >= length l - 1 then 0 else i + 1
                 Nothing -> 0

getNextCompletion' :: XPrompt t => t -> String -> [String] -> String
getNextCompletion' t c l = completionToCommand t $ getNextCompletion c l


-- For man, we need to pass the last 2 words to the complete function so we can get possible sections
getLast2Words :: String -> String
getLast2Words s = unwords $ reverse $ take 2 $ reverse $ words s

first2Words :: String -> String
first2Words s = unwords $ take 2 $ words s

dropLast2 :: String -> String
dropLast2 s = reverse $ drop 2 $ reverse s

-- TODO make this work for multiple manpages in one command
data ManPrompt = ManPrompt
instance XPrompt ManPrompt where
  showXPrompt ManPrompt = "Man pages for: "
  commandToComplete _   = getLast2Words
  --commandToComplete _   = id
  --nextCompletion        = nextCompletionForMan
  nextCompletion      = getNextCompletion'
  --completionToCommand _ s = head $ words s
  --completionToCommand _ = first2Words
  --completionToCommand _ = id

saferManPrompt :: [ManEntry] -> XPConfig -> X ()
saferManPrompt candidates config = mkXPrompt ManPrompt config (manCompl candidates) run
  where run = safeTermProg "man" . return



-- split user and hostname from user@host construct
splitUserHost :: String -> (String, String)
splitUserHost str = splitHost c str
  where splitHost (Just x) str = (take x str, drop (x + 1) str)
        splitHost _ str        = ("", str)
        c                      = elemIndex '@' str -- index of @, returns (Maybe Int)

-- Make user@host if there's a username, otherwise just host
recombineHost :: String -> String -> String
recombineHost [] str = str
recombineHost usr host = usr ++ "@" ++ host

-- Get all the hostnames from ssh config file (gets tripped up on comment lines after Host statement.)
grepHosts :: [String] -> [String]
grepHosts lines = concatMap (tail . words) $ filter (isPrefixOf "Host ") lines

-- Find autocomplete in list of hosts, attempting to complete the host if a username is given
findHostMatches :: [String] -> Predicate -> String -> [String]
findHostMatches list pred str = map (recombineHost usr) $ filter (liftM2 (&&) (isPrefixOf host) (pred host)) list
  where (usr,host) = splitUserHost str

noFileHandler :: IOError -> IO String
noFileHandler _ = return ""

sshConfigCompl :: Predicate -> String -> String -> IO [String]
sshConfigCompl pred config str = do
  contents <- readFile config `catch` noFileHandler
  let hosts = grepHosts $ lines contents
  return $ findHostMatches hosts pred str

saferSshPrompt :: String -> XPConfig -> X ()
saferSshPrompt = saferSshPrompt' "ssh"

saferSftpPrompt :: String -> XPConfig -> X ()
saferSftpPrompt = saferSshPrompt' "sftp"

-- Run ssh/sftp with completion from .ssh/config
saferSshPrompt' :: String -> String -> XPConfig -> X ()
saferSshPrompt' subprog ssh_config config = mkXPrompt (CustomPrompt subprog) config (sshConfigCompl (searchPredicate config) ssh_config) run
  where run = safeTermProg subprog . return
