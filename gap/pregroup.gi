#
# anatph: A new approach to proving hyperbolicity
#
# Pregroup code
#

# Define a pregroup by giving a list of generator names and
# a (partial) multiplication table
InstallGlobalFunction(PregroupByTableNC,
function(enams, inv, table)
    local r;

    r := rec( enams := enams
            , inv := inv
            , table := table );
    r.fam := NewFamily( "PregroupElementsFamily", IsElementOfPregroup );
    r.elt_t := NewType( r!.fam, IsElementOfPregroupRep );

    return Objectify(PregroupByTableType, r);
end);

InstallGlobalFunction(PregroupByTable,
function(enams, inv, table)
    local nels, row, e, f, g, h;

    # We assume that the length of the list of
    # element names is the number of elements
    nels := Length(enams);

    if Length(table) <> nels then
        Error("PregroupByTable: Length of enams does not match number of rows in table");
    fi;
    for row in table do
        if Length(row) <> nels then
            Error("PregroupByTable: Multiplication table is not square");
        fi;
        for e in row do
            if (not IsInt(e)) or (e < 0) or (e > nels) then
                Error("PregroupByTable: Table entry ", e, " is invalid, needs to be an integer between 0 and ", nels);
            fi;
        od;
    od;
    for e in [1..nels] do
        if inv(inv(e)) <> e then
            Error("PregroupByTable: inv needs to be an involution");
        fi;
    od;
    for e in [1..nels] do
        if (table[1][e] <> e) or (table[e][1] <> e) then
            Error("PregroupByTable: ",e,"*1 = ", e, " or 1*", e, " = ", e, " not satisfied");
        fi;
        if (table[e][inv(e)] <> 1) or (table[inv(e)][e] <> 1) then
            Error("PregroupByTable: inverses");
        fi;
    od;

    for e in [1..nels] do
        for f in [1..nels] do
            for g in [1..nels] do
                if table[e][f] > 0 and table[f][g] > 0 then
                    if (table[table[e][f]][g] = 0 and table[e][table[f][g]] > 0) or
                       (table[table[e][f]][g] > 0 and table[e][table[f][g]] = 0) then
                        Error("PregroupByTable: associativity");
                    fi;
                fi;
            od;
        od;
    od;

    for e in [1..nels] do
        for f in [1..nels] do
            if table[e][f] > 0 then
                for g in [1..nels] do
                    if table[f][g] > 0 then
                        for h in [1..nels] do
                            if table[g][h] > 0 then
                                if table[table[e][f]][g] = 0 and table[table[f][g]][h] = 0 then
                                    Error("PregroupByTable: P5 violated");
                                fi;
                            fi;
                        od;
                    fi;
                od;
            fi;
        od;
    od;
    return PregroupByTableNC(enams, inv, table);
end);

InstallMethod(\[\]
             , "for a pregroup in table rep"
             , [IsPregroupTableRep, IsInt],
function(f,a)
    return Objectify(f!.elt_t, rec( parent := f, elt := a ));
end);

InstallMethod(Iterator
             , "for a pregroup"
             , [IsPregroupTableRep],
function(pgp)
    local r;

    r := rec( pgp := pgp
            , pos := 0
            , NextIterator := function(iter)
                if iter!.pos < Size(iter!.pgp) then
                    iter!.pos := iter!.pos + 1;
                    return iter!.pgp[iter!.pos];
                else
                    return fail;
                fi;
            end
            , IsDoneIterator := iter -> iter!.pos = Size(iter!.pgp)
            , ShallowCopy := iter -> rec( pgp := iter!.pgp, pos := iter!.pos )
            );

    return IteratorByFunctions(r);
end);

InstallMethod(ViewString
             , "for a pregroup in table rep"
             , [IsPregroupTableRep],
function(pg)
    return STRINGIFY("<pregroup with ", Length(pg!.enams), " elements in table rep>");
end);

InstallMethod(Size
             , "for a pregroup in table rep"
             , [IsPregroupTableRep],
function(pg)
    return Length(pg!.enams);
end);

InstallMethod(IntermultPairs
             , "for a pregroup in table rep"
             , [IsPregroupTableRep],
function(pg)
    local i, j, k, pairs;

    pairs := [];
    for i in [1..Length(pg!.enams)] do
        for j in [1..Length(pg!.enams)] do
            if (i <> j) and
               (pg!.table[i] <> pg!.sigma(j)) then
                if pg!.table[i][j] > 0 then
                    Add(pairs, [i,j]);
                else
                    for k in [1..Length(pg!.enams)] do
                        if (pg!.table[i][k] > 0) and
                           (pg!.table[pg!.sigma(k)][j]) then
                            Add(pairs, [i,j]);
                            break;
                        fi;
                    od;
                fi;
            fi;
        od;
    od;

    return pairs;
end);

#
# Pregroup elements
#
InstallMethod(ViewString
             , "for a pregroup element"
             , [IsElementOfPregroupRep],
function(pge)
    if pge!.elt > 0 then
        return String(pge!.parent!.enams[pge!.elt]);
    else
        return "undefined";
    fi;
end);

InstallMethod(\*
             , "for pregroup elements"
             , IsIdenticalObj
             , [IsElementOfPregroupRep, IsElementOfPregroupRep]
             , 0,
function(x,y)
    local pg, r;

    pg := x!.parent;

    r := pg!.table[x!.elt][y!.elt];

    return Objectify(pg!.elt_t, rec( parent := pg, elt := r ));
end);

InstallMethod(\=
             , "for pregroup elements"
             , IsIdenticalObj
             , [IsElementOfPregroupRep, IsElementOfPregroupRep]
             , 0,
function(x,y)
    return x!.elt = y!.elt;
end);

InstallMethod(PregroupOf
             , "for pregroup elements"
             , [ IsElementOfPregroupRep ]
             , 0,
function(a)
    return a!.parent;
end);

InstallMethod(PregroupInverse
             , "for pregroup elements"
             , [ IsElementOfPregroupRep ]
             , 0,
function(a)
    local pg;

    pg := PregroupOf(a);

    return Objectify(pg!.elt_t, rec( parent := pg, elt := pg!.inv(a!.elt) ) );
end);

InstallMethod(IsDefinedMultiplication
             , "for pregroup elements"
             , IsIdenticalObj
             , [IsElementOfPregroup, IsElementOfPregroup]
             , 0,
function(a,b)
    local pg;

    pg := PregroupOf(a);

    return pg!.table[a!.elt][b!.elt] > 0;
end);

# We could cache intermult pairs,
# or predetermine them, depending
# on the number of intermult lookups
# that could benefit runtime
#T Find an example of a pregroup that has an intermult pair
#T That covers the last case
InstallMethod(IsIntermultPair
             , "for pregroup elements"
             , IsIdenticalObj
             , [IsElementOfPregroup, IsElementOfPregroup]
             , 0,
function(a,b)
    local x;

    if a = PregroupInverse(b) then
        return false;
    elif IsDefinedMultiplication(a, b) then
        return true;
    else
        for x in PregroupOf(a) do
            if IsDefinedMultiplication(a,x)
               and IsDefinedMultiplication(PregroupInverse(x), b) then
                return true;
            fi;
        od;
        return false;
    fi;
    # Should not be reached
    Error("This shouldn't happen.");
end);