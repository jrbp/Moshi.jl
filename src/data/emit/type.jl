@pass 2 function emit_type(info::EmitInfo)
    union_params = [:($(storage.name){$(info.params...)}) for storage in info.storages]
    jl = JLStruct(;
        name=:Type,
        fields=[JLField(; name=:data, type=:(Union{$(union_params...)}))],
        typevars=info.whereparams,
    )
    return codegen_ast(jl)
end
