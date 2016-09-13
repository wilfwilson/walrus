#
# anatph: A new approach to proving hyperbolicity
#

InstallGlobalFunction(NewPregroupRelator,
function(pres, word, id)
    local maxk;
    maxk := MaxPowerK(word);
    return Objectify(IsPregroupRelatorType,
                     rec( pres := pres
                        , base := maxk[1]
                        , exponent := maxk[2]
                        , __ID := id)
                    );
end);

InstallMethod(Base, "for a pregroup relator",
              [IsPregroupRelator],
              r -> r!.base);

InstallMethod(Exponent, "for a pregroup relator",
              [IsPregroupRelator],
              r -> r!.exponent);

InstallMethod(Inverse, "for a pregroup relator",
              [IsPregroupRelator],
              r -> Objectify(IsPregroupRelatorType,
                             rec( pres := r!.pres
                                , base := List(Reversed(r!.base), PregroupInverse)
                                , exponent := r!.exponent
                                , __ID := -r!.__ID)
                            ));
InstallMethod(Presentation,
              "for pregroup relators",
              [IsPregroupRelator],
              r -> r!.pres);

InstallMethod(Locations, "for a pregroup relator",
              [IsPregroupRelator],
function(r)
    return List([1..Length(Base(r))], i -> NewLocation(r, i));
end);

InstallMethod(\[\], "for a pregroup relator",
              [IsPregroupRelator and IsPregroupRelatorRep, IsInt],
function(r, p)
    local i, l;
    l := Length(r!.base);
    i := RemInt(p - 1, l);
    if i < 0 then
        i := i + l;
    fi;
    return r!.base[i + 1];
end);

InstallMethod(Length, "for a pregroup relator",
    [IsPregroupRelator],
function(r)
    return Length(r!.base) * r!.exponent;
end);

# we could possibly store this on creation
# But this is run at most once anyway
InstallMethod(Places, "for a pregroup relator",
              [IsPregroupRelator],
function(r)
    local P, res;

    res := [];

    for P in Places(Presentation(r)) do
        if Relator(P) = r then
            Add(res, P);
        fi;
    od;
    return res;
end);

InstallMethod(ViewString, "for a pregroup relator",
    [IsPregroupRelator],
function(r)
    if Exponent(r) > 1 then
        return STRINGIFY("<pregroup relator ("
                        , List(r!.base, ViewString)
                        , ")^", r!.exponent, ">");
    else
        return STRINGIFY("<pregroup relator "
                        , List(r!.base, ViewString)
                        , ">");
    fi;
end);

InstallMethod(\=, "for a pregroup relator, and a pregroup relator",
              [IsPregroupRelator, IsPregroupRelator],
function(l,r)
    # id is uniqe wrt pregroup presentation. We should probably
    # make a family of relators for each presentation etc
    # return l!.__ID = r!.__ID;
    return (l!.exponent = r!.exponent)
           and (l!.base = r!.base);
end);

InstallMethod(\in, "for a generator and a pregroup relator",
              [ IsElementOfPregroup, IsPregroupRelator and IsPregroupRelatorRep],
function(e,r)
    return e in r!.base;
end);
