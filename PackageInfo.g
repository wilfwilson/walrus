#
# anatph: A new approach to proving hyperbolicity
#
SetPackageInfo( rec(

PackageName := "anatph",
Subtitle := "A new approach to proving hyperbolicity",
Version := "0.5",
Date := "20/06/2018", # dd/mm/yyyy format

Persons := [
  rec(
       IsAuthor := true,
       IsMaintainer := true,
       FirstNames := "Markus",
       LastName := "Pfeiffer",
       WWWHome := "http://www.morphism.de/~markusp/",
       Email := "markus.pfeiffer@st-andrews.ac.uk",
       PostalAddress := Concatenation(
                                       "School of Computer Science\n",
                                       "University of St Andrews\n",
                                       "Jack Cole Building, North Haugh\n",
                                       "St Andrews, Fife, KY16 9SX\n",
                                       "United Kingdom" ),
       Place := "St Andrews",
       Institution := "University of St Andrews",
      ),
],

PackageWWWHome := "https://gap-packages.github.io/anatph/",


SourceRepository := rec( 
  Type := "git", 
  URL := "https://github.com/gap-packages/anatph"
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := "https://gap-packages.github.io/anatph",
README_URL      := Concatenation( ~.PackageWWWHome, "/README.md" ),
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/anatph-", ~.Version ),

ArchiveFormats := ".tar.gz",

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "submitted"     for packages submitted for the refereeing
##    "deposited"     for packages for which the GAP developers agreed
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages
##    "other"         for all other packages
##
Status := "dev",

AbstractHTML   :=  
"""An implementation of hyperbolicity testing using an ideas
by Richard Parker, Derek Holt, Colva Roney-Dougal, Max Neunhöffer,
and probably quite a few more""",

PackageDoc := rec(
  BookName  := "anatph",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "A new approach to proving hyperbolicity",
),

Dependencies := rec(
  GAP := ">= 4.8",
  NeededOtherPackages := [ [ "GAPDoc", ">= 1.5" ],
                           [ "datastructures", "0.1.2" ],
                           [ "digraphs", ">= 0.10" ],
                           [ "kbmag", ">= 1.5.4" ]],
  SuggestedOtherPackages := [ [ "profiling", " >= 1.3.0"] ],
  ExternalConditions := [ ],
),

AvailabilityTest := function()
        return true;
    end,

TestFile := "tst/testall.g",

#Keywords := [ "TODO" ],

));


