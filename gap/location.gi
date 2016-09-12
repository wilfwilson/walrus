#
# anatph: A new approach to proving hyperbolicity
#
## Locations

# NewLocation : IsPregroupRelator -> Int -> IsPregroupLocation
InstallGlobalFunction(NewLocation,
function(R,i)
    return Objectify(IsPregroupLocationType, [R,i]);
end);

InstallMethod(Relator, "for a location",
              [ IsPregroupLocationRep ],
              l -> l![1]);

InstallMethod(Position, "for a location",
              [ IsPregroupLocationRep ],
              l -> l![2]);

InstallMethod(InLetter, "for a location",
              [ IsPregroupLocationRep ],
              l -> l![1][l![2] - 1]);

InstallMethod(OutLetter, "for a location",
              [ IsPregroupLocationRep ],
              l -> l![1][l![2]]);

#X Get rid of this
InstallMethod(__ID, "for a location",
              [ IsPregroupLocationRep ],
              l -> l![5]);

# Return list of Places that have this location
InstallMethod(Places, "for a location",
              [ IsPregroupLocationRep ],
function(l)
    local p, places;
    places := [];
    for p in Places(Presentation(l)) do
        if Location(p) = l then
            Add(places, p);
        fi;
    od;
    return places;
end);

# Two locations are the same if they are on the same
# relator at the same index
InstallMethod(\=, "for a location and a location",
              [ IsPregroupLocationRep, IsPregroupLocationRep],
function(l,r)
    return (l![1] = r![1])
           and (l![2] = r![2]);
end);

InstallMethod(Presentation, "for a location",
              [ IsPregroupLocationRep ],
              l -> Presentation(l![1]));

InstallMethod(ViewString, "for a location",
              [ IsPregroupLocationRep ],
function(l)
    return STRINGIFY(ViewString(l![1]), "("
                     , l![2], ","
                     , ViewString(InLetter(l)), ","
                     , ViewString(OutLetter(l)), ")"
                    );
end);
