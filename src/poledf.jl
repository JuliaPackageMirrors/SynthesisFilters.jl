# All pole digital filter for speech synthesis from LPC

poledf_delay(order::Int) = zeros(order)

type AllPoleDF <: MelLinearPredictionSynthesisFilter
    delay::Vector{Float64}

    function AllPoleDF(order::Int)
        new(poledf_delay(order))
    end
end

function filter!(f::AllPoleDF, x::Float64, a::Vector{Float64})
    d = delay(f)
    order = length(a) - 1

    y = x
    @inbounds for m=order:-1:2
        y -= a[m+1] * d[m]
        d[m] = d[m-1]
    end

    y -= a[2] * d[1]
    d[1] = y

    return y
end

function to_filtcoef(f::AllPoleDF, lpc::MelLinearPredictionCoef)
    isa(lpc, LinearPredictionCoef) || throw(ArgumentError("unexpected LPC form"))
    if lpc.loggain
        return rawdata(lpc)
    end

    b = copy(rawdata(lpc))
    for i=1:size(b, 2)
        b[1,i] = log(b[1,i])
    end
    b
end
