module Arrow

const UINT8NULL = UInt8[]

abstract ArrowColumn{T} <: AbstractVector{T}

immutable Column{T} <: ArrowColumn{T}
    buffer::Vector{UInt8} # potential reference to mmap
    length::Int32
    null_count::Int32
    nulls::BitVector # null == 0 == false, not-null == 1 == true; always padded to 64-byte alignments
    data::Vector{T} # always padded to 64-byte alignments
end

immutable ListColumn{T} <: ArrowColumn{T}
    buffer::Vector{UInt8}
    length::Int32
    null_count::Int32
    nulls::BitVector
    offsets::Vector{Int32}
    data::Union{Vector{T},ListColumn{T}}
end

# StructColumn

# DenseUnionColumn

# SparseUnionColumn

# AbstractVector interface
Base.size(A::ArrowColumn) = (Int(A.length),)
Base.linearindexing{T<:ArrowColumn}(::Type{T}) = Base.LinearFast()

Base.getindex{T}(A::Column{T}, i::Int) = A.nulls[i] ? Nullable{T}(A.data[i]) : Nullable{T}()
Base.setindex!(A::Column, v, i::Int) = (setindex!(A.data, v, i); return A)

Base.getindex{T<:UInt8}(A::ListColumn{T}, i::Int) = A.nulls[i] ?
    Nullable{String}(String(pointer(A.data) + A.offsets[i], A.offsets[i+1] - A.offsets[i])) : Nullable{String}()

#TODO:
 # make sure ListColumn{ListColumn{UInt8}} is viable

end # module
