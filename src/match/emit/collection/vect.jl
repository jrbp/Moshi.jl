function decons(::Type{Pattern.Ref}, ctx::PatternContext, pat::Pattern.Type)
    # NOTE: we generate both cases here, because Julia should
    # be able to eliminate one of the branches during compile
    # NOTE: ref syntax <symbol> [<elem>...] has the following cases:
    # 1. <symbol> is defined, and is a type, typed vect
    # 2. <symbol> is not defined in global scope as type,
    #    but is defined as a variable, getindex, the match
    #    will try to find the index that returns the input
    #    value.
    # 2 is not supported for now because I don't see any use case.
    coll = CollectionDecons(ctx, pat, pat.args) do _
        :($Base.Vector{<:$(pat.head)})
    end
    set_view_type_check!(coll) do view, eltype
        # For the pattern
        #   AP[_, v::VP..., _]
        # matching on some vector of the form
        #   A[_, V[...]..., _]
        # the vector is illegal unless V <: A
        # and the match fails elsewhere unless A <: AP
        # so V <: A <: AP
        # want to return V <: VP
        (pat.head == eltype # if AP == VP we know at macro time
         || :(eltype($view) <: $eltype # if A <: VP can avoid iteration
              || all(Base.Fix2(isa, $eltype), $view)))
    end
    return coll
end

function decons(::Type{Pattern.Vector}, ctx::PatternContext, pat::Pattern.Type)
    coll = CollectionDecons(ctx, pat, pat.xs) do _
        :($Base.Vector)
    end
    set_view_type_check!(coll) do view, eltype
        :(eltype($view) <: $eltype
          || all(Base.Fix2(isa, $eltype), $view))
    end
    return coll
end
