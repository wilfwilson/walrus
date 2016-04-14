#
# anatph: A new approach to proving hyperbolicity
#
# Implementations
#
InstallGlobalFunction(PregroupPresentation,
function(pg, rels)
    local res;

    res := rec();

    res.pg := pg;
    res.rels := rels;

    return Objectify(PregroupPresentationType, res);
end);

InstallMethod(ViewString
             , "for a pregroup presentation"
             , [IsPregroupPresentationRep],
function(pgp)
    # Note that we do not really regard 1 as a generator
    local res;

    return STRINGIFY("<pregroup presentation with "
                    , Size(pgp!.pg)-1, " generators and "
                    , Length(pgp!.rels), " relators>");
end);

InstallMethod(Pregroup
             , "for a pregroup presentation"
             , [IsPregroupPresentation],
             pgp -> pgp!.pg);

InstallMethod(Generators
             , "for a pregroup presentation"
             , [IsPregroupPresentation],
function(pres)
    local gens;
 
    gens := List(Pregroup(pres), x->x);
    Remove(gens, 1);
    return gens;
end);

InstallMethod(Relations
             , "for a pregroup presentation"
             , [IsPregroupPresentation],
             pgp -> pgp!.rels);

InstallMethod(GeneratorsOfPregroupPresentation
             , "for a pregroup presentation"
             , [IsPregroupPresentation],
             x -> fail);

####################################
#
#
# Assumptions
#  I(Rels) only contains cyclic conjugates of R in Rels


# we have a bijection between \underline{\abs{P}} and P, i.e. number
# the elements of P.
# we also have an involution sigma : P -> P which inverts elements
# notational convention -i = sigma(i)
#
# We also have names for elements of P for better readability
#
# relations are (compressed?) strings over P, i.e. lists of pairs
# [i,e]

#
# Rels rep'd as a list of ints, for instance x^2y^-2 -> [[1,2],[2, -2]]
# unfortunately of course [x,-2] = [-x,2]
#


# MaxPowerK: Input a word v over X, output w such that w^k = v, k maximal with this property
#
# in the following w is the output of MaxPowerK
#
# location (i,a,b) where i in [1..Length(w)] a = w[i-1] and b = w[i] (so a
# location on R can be represented by just  the, well, location on w (?))
# R(i,a,b) if the relator is R, and so this involved MaxPowerK(R) as well!

# Place (R(i,a,b), c, C, B) R(i,a,b) is a place c is a generator C in [G,B], B
# in [true,false]


# If input is Rels then?

# A pregroup presentation will be a structure that has
# Generators(pres) (elements of pregroup except 1)
# Pregroup(pres)   (the pregroup structure)
# Relations(pres)  (the set \mathcal{R})

# An R-letter is a letter that occurs in any (intersperse) of
# a relation (Definition 7.4)
# XXX: Note that the code below does not do intersperses yet!
# XXX: Colva said we can go without intersperse I think
# XXX: Check
InstallGlobalFunction(IsRLetter,
function(pres, x)
    # determine whether x occurs in I(R)
    local r,l;

    for r in Relations(pres) do
        for l in r do
            return true;
        od;
    od;
    return false;
end);

# MaxPowerK: Input a word (relator) v over X, output w such that w^k = v, k maximal with this property
# There might be a better way of doing this? Colva mentioned that it's in one
# of Derek's books?
InstallGlobalFunction(MaxPowerK,
function(rel)
    local len, d, divs, isrep,
          checkrep;

    len := Length(rel);
    divs := ShallowCopy(DivisorsInt(len));
    Remove(divs, 1);

    checkrep := function(d)
        local j,k;
        for j in [1..d] do
            for k in [1..(len / d) - 1] do
                if rel[j] <> rel[j + k*d] then
                    return false;
                fi;
            od;
        od;
        return true;
    end;

    for d in divs do
        if checkrep(d) then
            return [ rel{[1..d]}, len / d ];
        fi;
    od;

    return [ rel, 1 ];
end);

InstallGlobalFunction(MaxPowerK2,
function(rel)
    local len, divs, checkrep, w, k, d, r;

    len := Length(rel);
    divs := Reversed(DivisorsInt(len));
    Remove(divs,1);

    checkrep := function(d)
        local j,k;
        for j in [1..d] do
            for k in [1..(len / d) - 1] do
                if rel[j] <> rel[j + k*d] then
                    return false;
                fi;
            od;
        od;
        return true;
    end;

    w := rel;
    k := divs[1];

    for d in divs do
        if not checkrep(d) then
            return [w,k];
        else
            r := MaxPowerK(w{[1..d]});
            k := k * r[2];
            w := r[1];
        fi;
    od;
end);

# at the moment a relation is just a list
# of integers referring to elements of the
# pregroup underlying the pregroup presentation
#
# for the moment a location is triple [i,a,b]. This is of course redundant, since
# we know a and b from i and R.
#XXX cleanup
# Locations are tied to relations
InstallMethod(Locations, "for a pregroup presentation",
              [IsPregroupPresentation and IsPregroupPresentationRep],
function(pres)
    local rel, locs, ls, r, w, k, i;

    locs := [];

    for rel in Relations(pres) do
        r := MaxPowerK(rel);
        w := r[1];

        ls := [[1, w[Length(w)], w[1]]];
        Append(ls, List([2..Length(w)], i -> [i, w[i-1], w[i]]));
        Add(locs, ls);
    od;
    return locs;
end);

#InstallGlobalFunction(Locations,
#function(rel)
#    local res, r, w, k, i;
#
#    res := [];
#
#    r := MaxPowerK(rel);
#    w := r[1];
#
#    res := List([2..Length(w)], i -> [i, w[i-1], w[i]]);
#    Add(res, [1, w[Length(w)], w[1]]);
#
#    return res;
#end);

# Definition 3.3: A diagram is semi-reduced, if no distinct adjacent faces
# are labelled by ww_1 and w_1^{-1}w for a relator ww_1 and have a common
# consolidated edge labelled by w and w^-1
# it is reduced if this also holds for a face incident with itself.
#XXX When is a face "incident with itself" again?)
#XXX Is this then just checking that the two relators do not behave like
#    above?
#XXX Check correctness, but this is confirmed correct behaviour
InstallGlobalFunction(CheckReducedDiagram,
function(r1, l1, r2, l2)
    local i, j;

    i := l1[1];
    j := l2[1];

    repeat
        i := i + 1;
        if i > Length(r1) then i := 1; fi;
        j := j - 1;
        if j = 0 then j := Length(r2); fi;

        if r1[i] <> PregroupInverse(r2[j]) then
            return true;
        fi;
    until (i = l1[1]) or (j = l2[1]);
    return false;
end);

# Given a pregroup presentation as the input, find all places
# Pregroup presentations consist of a pregroup and a list of relations

# A place is a 4-tuple (location, letter, colour, boundary)
# such that
#
#XXX I think places on a relation are better, so this function should take a relation
#XXX note though that for the check whether there exists a reduced diagram, we have
#    to access all other Locations (i.e. relations)
InstallMethod(Places, "for a pregroup presentation",
              [IsPregroupPresentation and IsPregroupPresentationRep],
function(pres)
    local loc, loc2, c, C, B, X,
          places, a, b,
          gens, rels, rel, rel2,
          locs,
          places_for_rel,
          r,l;

    rels := Relations(pres);
    locs := Locations(pres);
    places := [];

    for rel in [1..Length(rels)] do
        for loc in locs[rel] do
            a := loc[2];
            b := loc[3];
            for c in Generators(pres) do
                # C = 'B', i.e. red, I still find this confusing
                if IsIntermultPair(PregroupInverse(b), c) then
                    if IsRLetter(pres, c) then
                        Add(places, [loc,c, "red",false]);
                    fi;
                    Add(places, [loc, c, "red", true] );
                fi;
                # C = 'G'
                # find location R'.
                for rel2 in [1..Length(rels)] do
                    for loc2 in locs[rel2] do
                        if loc2[2] = PregroupInverse(b) and loc2[3] = c then
                            # Is this really just checking that rel starting at b is
                            # not equal to rel2
                            if CheckReducedDiagram(rels[rel], loc, rels[rel2], loc2) then
                                Add(places, [loc, c, "green", true]);
                            else
                                Add(places, [loc, c, "green", false]);
                            fi;
                        fi;
                    od;
                od;
            od;
        od;
    od;

    return places;
end);

# Location blob graph
# vertices: locations and intermult pairs
# directed edges:
#  - I(a,b) -> R(j,b^(-1),c)
#  - R(i,a,b) -> I(b^(-1),c)
#  - R(i,a,b) -> R'(j,b^(-1),c) if there is a reduced diagram that has
#                               faces labelled R and R'
#XXX This might be horribly inefficient
InstallGlobalFunction(LocationBlobGraph,
function(pres)
    local vertices, edges;

    vertices := List(Locations(pres), x->['L', x]);
    Append(vertices, List(IntermultPairs(pres), x -> ['I', x]));

    edges := function(a,b)
        if a[1] = 'L' then
            if b[1] = 'L' then
                if a[2][3] = PregroupInverse(b[2][2]) and
                   CheckReducedDiagram(a[2][1], b[2][1]) then
                    return true;
                fi;
            elif b[1] = 'I' then
                if a[2][3] = PregroupInverse(b[2][2]) then
                    return true;
                fi;
            else
                Error("This shouldn't happen");
            fi;
        elif a[1] = 'I' then
            if b[1] = 'L' then
                if a[2][3] = PregroupInverse(b[2][2]) then
                    return true;
                fi;
            fi;
        fi;

        return false;
    end;

    return [vertices, Digraph(vertices, edges)];
end);

InstallGlobalFunction(ComputePlaceTriples,
function(pres)
    local p, ps, lp, lps;

#    ps := Places(pres);
#    lps := [];
#
#    for locations in LBG do
#    od;
#
#    for p in ps do
#        lp := [];
#    od;
end);

InstallGlobalFunction(Vertex,
function(nu1, P, nu2)
    local x;
    
    

end);


InstallGlobalFunction(ShortBlobWords,
function()
    Error("short blob words not implemented yet");
end);

InstallGlobalFunction(Blob,
function()
    Error("Blob not implemented yet");
end);

LengthEps := function(eps, rel, l)
    return (1 + eps)/Length(rel) * l;
end;

StepCurvature := function(places, P, Q)
end;

OneStepReachable := function()
    Error("OneStepReachable not implemented yet");
    
end;

InitStepsCurve := function(places, p)
    local i, j, res, nplaces;
    nplaces := Length(places);
    res := [];
    for i in [1..nplaces] do
        res[i] := [];
        for j in [1..nplaces] do
            res[i][j] := [-1,0];
        od;
        res[i][i] := [0,0];
    od;
    return res;
end;

# The RSym tester
InstallGlobalFunction(RSymTester,
function(pres, eps)
    local i, j, rel,
          places, Ps, P, Q,
          stepscurve,   # Steps and curvature
          zeta,
          Xi;
    zeta := Int(Ceil(6 * (1 + eps)));

    for rel in Relations(pres) do
        places := Places(pres, rel);
        for Ps in places do
            stepscurve := InitStepsCurve(places, Ps);

            for i in [1..zeta] do
                for P in [1..Length(places)] do
                    if stepscurve[j][1] = i - 1 then
                        for Q in OneStepReachable(places[P]) do
                            Xi := stepscurve[P][2]
                                  + StepCurvature(places, P, Q)
                                  + LengthEps(eps, rel, P, Q);

                            if (Xi >= 0) and (Ps = Q) then
                                return [fail, stepscurve];
                            fi;

                            if (Xi > stepscurve[Q][1]) then
                                stepscurve[Q][1] := i;
                                stepscurve[Q][2] := Xi;
                            fi;
                        od;
                    fi;
                od;
            od;
        od;
    od;

    return true;
end);
